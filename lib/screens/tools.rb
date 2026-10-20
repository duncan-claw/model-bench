# frozen_string_literal: true

require "json"

# Single-turn tool calling: right tool (or none), right arguments, right types.
module Screens
  class Tools
    def self.fn(name, desc, props, required)
      { type: "function", function: { name: name, description: desc,
                                      parameters: { type: "object", properties: props, required: required } } }
    end

    S = { type: "string" }.freeze
    TOOLS = [
      fn("get_weather", "Current weather for a city", { city: S, unit: { type: "string", enum: %w[celsius fahrenheit] } }, %w[city]),
      fn("create_calendar_event", "Create a calendar event", { title: S, start: { type: "string", description: "ISO 8601 local datetime" },
                                                               duration_minutes: { type: "integer" } }, %w[title start]),
      fn("send_email", "Send an email", { to: S, subject: S, body: S }, %w[to subject body]),
      fn("read_file", "Read a file from the project", { path: S }, %w[path]),
      fn("search_web", "Search the web", { query: S }, %w[query]),
      fn("run_tests", "Run the project's test suite", { path: { type: "string", description: "optional file or dir" } }, []),
      fn("create_issue", "Create a GitHub issue", { repo: S, title: S, labels: { type: "array", items: S } }, %w[repo title]),
      fn("create_reminder", "Create a reminder", { text: S, time: { type: "string", description: "HH:MM 24h" } }, %w[text time]),
      fn("list_orders", "List a customer's orders", { customer_id: { type: "integer" }, limit: { type: "integer" } }, %w[customer_id])
    ].freeze

    has = ->(v, s) { v.to_s.downcase.include?(s) }
    CASES = [
      ["What's the weather in Melbourne right now, in celsius?", [["get_weather", ->(a) { has.(a["city"], "melbourne") && a["unit"] == "celsius" }]]],
      ["Put 'Roadmap review' in my calendar on 2026-10-21 at 15:00 for 30 minutes.",
       [["create_calendar_event", ->(a) { has.(a["title"], "roadmap") && has.(a["start"], "2026-10-21") && has.(a["start"], "15:00") && a["duration_minutes"].to_i == 30 }]]],
      ["Email leah@example.com with the subject 'Invoice' and the body 'Attached is the invoice.'",
       [["send_email", ->(a) { a["to"] == "leah@example.com" && a["subject"] == "Invoice" && has.(a["body"], "attached is the invoice") }]]],
      ["What is 17 times 3?", []],
      ["Show me what's in config/database.yml.", [["read_file", ->(a) { a["path"].to_s.end_with?("config/database.yml") }]]],
      ["Search the web for news about the Rails 8.1 release.", [["search_web", ->(a) { has.(a["query"], "rails") && has.(a["query"], "8.1") }]]],
      ["Run the tests in test/models.", [["run_tests", ->(a) { has.(a["path"], "test/models") }]]],
      ["What's the weather in Sydney and in Perth?",
       [["get_weather", ->(a) { has.(a["city"], "sydney") }], ["get_weather", ->(a) { has.(a["city"], "perth") }]]],
      ["Tell me a short joke about Ruby programmers.", []],
      ["Open an issue on duncan-claw/outlook-tools titled 'Sender filter dry-run' and label it bug.",
       [["create_issue", ->(a) { a["repo"] == "duncan-claw/outlook-tools" && has.(a["title"], "sender filter dry-run") && Array(a["labels"]).map(&:downcase).include?("bug") }]]],
      ["Remind me to call Mum at 6pm.", [["create_reminder", ->(a) { has.(a["text"], "mum") && a["time"].to_s.start_with?("18:00") }]]],
      ["Get the 5 most recent orders for customer 1042.",
       [["list_orders", ->(a) { a["customer_id"] == 1042 && a["limit"] == 5 }]]]
    ].freeze

    SYSTEM = "You are an assistant with tools. Call a tool when one is needed; otherwise answer directly. " \
             "Today is 2026-10-19 in Australia/Melbourne."

    def initialize(client, box:)
      @client = client
      @box = box
    end

    def run
      started = now
      rows = []
      CASES.each_with_index do |(prompt, expected), i|
        break if now - started > @box

        res = @client.chat([{ role: "system", content: SYSTEM }, { role: "user", content: prompt }],
                           tools: TOOLS, max_tokens: 768, timeout: 120)
        calls = parse_calls(res)
        rows << { case: i + 1, seconds: res[:seconds]&.round(1), error: res[:error],
                  calls: calls.map { |n, a| "#{n}(#{JSON.generate(a)[0, 120]})" }, passed: !res[:error] && match?(calls, expected) }
      end
      passed = rows.count { _1[:passed] }
      { attempted: rows.size, passed: passed, total_cases: CASES.size, box_seconds: @box,
        gen_seconds: (now - started).round(1), cases: rows }
    end

    private

    # Structured tool_calls first; fall back to <tool_call>{json}</tool_call> text some templates emit.
    def parse_calls(res)
      calls = Array(res[:tool_calls]).map do |c|
        f = c["function"] || {}
        args = f["arguments"]
        args = (JSON.parse(args) rescue {}) if args.is_a?(String)
        [f["name"], args || {}]
      end
      return calls unless calls.empty?

      res[:raw_content].to_s.scan(%r{<tool_call>\s*(\{.*?\})\s*</tool_call>}m).filter_map do |(json)|
        j = JSON.parse(json) rescue next
        [j["name"], j["arguments"] || {}]
      end
    end

    def match?(calls, expected)
      return calls.empty? if expected.empty?
      return false unless calls.size == expected.size

      remaining = calls.dup
      expected.all? do |name, check|
        idx = remaining.index { |n, a| n == name && (check.call(a) rescue false) }
        idx && remaining.delete_at(idx)
      end
    end

    def now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
