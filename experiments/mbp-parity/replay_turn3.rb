# frozen_string_literal: true

# Replays the agentic task's turn 3 (after list_files and two read_file calls, the path every failed attempt took)
# with no per-turn token limit, N times, and records how long the model thinks and whether it ends in a tool call.
# Usage: ruby experiments/mbp-parity/replay_turn3.rb <host-key e.g. mbp16-omlx> <model> <n> <out.json>
require "json"
Encoding.default_external = Encoding::UTF_8
require "yaml"
require "open3"
require "net/http"
require "digest"
require_relative "../../lib/screens/agentic"

ROOT = File.expand_path("../..", __dir__)
host_key, model, n, out = ARGV
host = YAML.load_file(File.join(ROOT, "config/hosts.yml")).fetch("hosts").fetch(host_key)
key, = Open3.capture2("ssh", host["ssh"],
                      %q(python3 -c 'import json,os;print(json.load(open(os.path.expanduser("~/.omlx/settings.json")))["auth"]["api_key"])'))
key = key.strip
task = File.join(ROOT, "tasks/slugify")
files = Dir.glob("**/*", base: task).select { File.file?(File.join(task, _1)) }
call = ->(id, name, args) { { id: id, type: "function", function: { name: name, arguments: JSON.generate(args) } } }
messages = [
  { role: "user", content: Screens::Agentic::PROMPT },
  { role: "assistant", content: "", tool_calls: [call.("c1", "list_files", {})] },
  { role: "tool", tool_call_id: "c1", content: files.join("\n") },
  { role: "assistant", content: "", tool_calls: [call.("c2", "read_file", { path: "lib/slugify.rb" }),
                                                 call.("c3", "read_file", { path: "test/slugify_test.rb" })] },
  { role: "tool", tool_call_id: "c2", content: File.read(File.join(task, "lib/slugify.rb")) },
  { role: "tool", tool_call_id: "c3", content: File.read(File.join(task, "test/slugify_test.rb")) }
]
tools = Screens::Agentic.const_get(:TOOLS)
uri = URI("#{host['base']}/v1/chat/completions")
rows = (1..n.to_i).map do |i|
  body = { model: model, messages: messages, tools: tools, max_tokens: 32_768, temperature: 0.0, stream: false }
  http = Net::HTTP.new(uri.host, uri.port, nil)
  http.read_timeout = 1200
  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  res = http.post(uri.path, JSON.generate(body), "Content-Type" => "application/json", "Authorization" => "Bearer #{key}")
  secs = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0).round(1)
  d = JSON.parse(res.body)
  ch = d.dig("choices", 0) || {}
  msg = ch["message"] || {}
  u = d["usage"] || {}
  reasoning = msg["reasoning_content"] || msg["reasoning"] || ""
  row = { i: i, seconds: secs, finish_reason: ch["finish_reason"], completion_tokens: u["completion_tokens"],
          reasoning_tokens: u.dig("completion_tokens_details", "reasoning_tokens"), reasoning_chars: reasoning.size,
          tool_calls: Array(msg["tool_calls"]).map { _1.dig("function", "name") },
          content_head: msg["content"].to_s[0, 160], fingerprint: Digest::SHA256.hexdigest(reasoning + msg["content"].to_s)[0, 12] }
  puts row.to_json
  row
end
File.write(out, JSON.pretty_generate(host: host_key, model: model, rows: rows))
