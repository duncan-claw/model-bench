# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

# Minimal OpenAI-compatible chat client (oMLX, LM Studio).
# Proxies are bypassed on purpose: the Gateway egress proxy refuses Tailscale hosts.
class Client
  attr_reader :base, :model

  def initialize(base:, model:, api_key: nil)
    @base = base.chomp("/")
    @model = model
    @api_key = api_key
  end

  # Returns { content:, tool_calls:, usage:, seconds:, finish_reason:, error: }
  def chat(messages, tools: nil, max_tokens: 1024, temperature: 0.0, timeout: 300)
    body = { model: model, messages: messages, max_tokens: max_tokens, temperature: temperature, stream: false }
    body[:tools] = tools if tools
    started = now
    res = post("/v1/chat/completions", body, timeout)
    secs = now - started
    return { error: "HTTP #{res.code}: #{res.body.to_s[0, 300]}", seconds: secs } unless res.is_a?(Net::HTTPSuccess)

    data = JSON.parse(res.body)
    choice = data.dig("choices", 0) || {}
    msg = choice["message"] || {}
    { content: strip_think(msg["content"].to_s), raw_content: msg["content"].to_s,
      tool_calls: msg["tool_calls"] || [], usage: data["usage"] || {},
      finish_reason: choice["finish_reason"], seconds: secs }
  rescue StandardError => e
    { error: "#{e.class}: #{e.message}"[0, 300], seconds: now - started }
  end

  # Streaming call used for speed: time to first token and decode rate.
  def stream(messages, max_tokens: 400, timeout: 120)
    body = { model: model, messages: messages, max_tokens: max_tokens, temperature: 0.0, stream: true,
             stream_options: { include_usage: true } }
    started = now
    first = nil
    chunks = 0
    usage = nil
    text = +""
    uri = URI(base + "/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port, nil)
    http.read_timeout = timeout
    req = Net::HTTP::Post.new(uri, headers)
    req.body = JSON.generate(body)
    http.request(req) do |res|
      return { error: "HTTP #{res.code}", seconds: now - started } unless res.is_a?(Net::HTTPSuccess)

      buf = +""
      res.read_body do |part|
        buf << part
        while (i = buf.index("\n"))
          line = buf.slice!(0..i).strip
          next unless line.start_with?("data:")

          payload = line.sub(/\Adata:\s*/, "")
          next if payload == "[DONE]"

          ev = JSON.parse(payload) rescue next
          usage = ev["usage"] if ev["usage"]
          delta = ev.dig("choices", 0, "delta") || {}
          piece = delta["content"].to_s + delta["reasoning_content"].to_s + delta["reasoning"].to_s
          next if piece.empty?

          first ||= now
          chunks += 1
          text << piece
        end
      end
    end
    total = now - started
    tokens = usage&.dig("completion_tokens") || chunks
    gen = first ? total - (first - started) : nil
    { ttft: first && (first - started), total: total, completion_tokens: tokens,
      tok_per_s: gen && gen.positive? ? tokens / gen : nil, chars: text.size }
  rescue StandardError => e
    { error: "#{e.class}: #{e.message}"[0, 300], seconds: now - started }
  end

  private

  def post(path, body, timeout)
    uri = URI(base + path)
    http = Net::HTTP.new(uri.host, uri.port, nil)
    http.read_timeout = timeout
    http.open_timeout = 10
    req = Net::HTTP::Post.new(uri, headers)
    req.body = JSON.generate(body)
    http.request(req)
  end

  def headers
    h = { "Content-Type" => "application/json" }
    h["Authorization"] = "Bearer #{@api_key}" if @api_key
    h
  end

  def strip_think(text)
    text.gsub(%r{<think>.*?</think>}m, "").sub(%r{\A.*</think>}m, "").strip
  end

  def now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
end
