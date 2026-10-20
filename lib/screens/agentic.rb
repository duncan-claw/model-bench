# frozen_string_literal: true

require "json"
require "fileutils"
require "tmpdir"
require_relative "../sandbox"

# A small multi-turn fix: the model gets file and test tools over a tiny Ruby project with
# failing tests and must make them pass. Measures whether it turns tool results into edits.
module Screens
  class Agentic
    TASK = File.expand_path("../../tasks/slugify", __dir__)
    DEFAULT_TURNS = 15

    def self.fn(name, desc, props = {}, required = [])
      { type: "function", function: { name: name, description: desc,
                                      parameters: { type: "object", properties: props, required: required } } }
    end

    TOOLS = [
      fn("list_files", "List all files in the project"),
      fn("read_file", "Read a file", { path: { type: "string" } }, %w[path]),
      fn("write_file", "Overwrite a file with new content", { path: { type: "string" }, content: { type: "string" } }, %w[path content]),
      fn("run_tests", "Run the test suite and return its output"),
      fn("finish", "Call when the tests pass", { summary: { type: "string" } }, %w[summary])
    ].freeze

    PROMPT = "The Ruby project in your workspace has failing tests. Use the tools to find and fix the bug in " \
             "the library code (do not edit the tests). Run the tests to confirm, then call finish."

    def initialize(client, box:, max_turns: DEFAULT_TURNS, max_tokens: 2048)
      @max_tokens = max_tokens
      @client = client
      @box = box
      @max_turns = max_turns
    end

    def run
      Sandbox.mktmpdir("agentic") do |dir|
        FileUtils.cp_r(Dir.glob("#{TASK}/*"), dir)
        @dir = dir
        loop_result = drive
        ok, out = tests
        loop_result.merge(solved: ok, final_tests: out.lines.last.to_s.strip, box_seconds: @box, max_turns: @max_turns, max_tokens: @max_tokens)
      end
    end

    private

    def drive
      started = now
      messages = [{ role: "user", content: PROMPT }]
      counts = Hash.new(0)
      turns = 0
      stop = "max_turns"
      while turns < @max_turns
        if now - started > @box
          stop = "time_box"
          break
        end
        turns += 1
        res = @client.chat(messages, tools: TOOLS, max_tokens: @max_tokens, timeout: 600)
        if res[:error]
          stop = "error: #{res[:error][0, 120]}"
          break
        end
        calls = Array(res[:tool_calls])
        messages << { role: "assistant", content: res[:raw_content].to_s, tool_calls: calls.empty? ? nil : calls }.compact
        if calls.empty?
          stop = "no_tool_call"
          break
        end
        finished = false
        calls.each do |c|
          name = c.dig("function", "name").to_s
          args = c.dig("function", "arguments")
          args = (JSON.parse(args) rescue {}) if args.is_a?(String)
          counts[name] += 1
          finished = true if name == "finish"
          messages << { role: "tool", tool_call_id: c["id"].to_s, content: execute(name, args || {}) }
        end
        if finished
          stop = "finish"
          break
        end
      end
      { turns: turns, stop: stop, seconds: (now - started).round(1), tool_counts: counts }
    end

    def execute(name, args)
      case name
      when "list_files" then Dir.glob("**/*", base: @dir).select { File.file?(File.join(@dir, _1)) }.join("\n")
      when "read_file" then File.read(safe(args["path"]))
      when "write_file"
        path = safe(args["path"])
        return "refused: tests are read-only" if path.include?("/test/")

        File.write(path, args["content"].to_s)
        "wrote #{args['path']}"
      when "run_tests" then tests.last[-2000..] || tests.last
      when "finish" then "ok"
      else "unknown tool #{name}"
      end
    rescue StandardError => e
      "error: #{e.message}"
    end

    def safe(rel)
      path = File.expand_path(rel.to_s, @dir)
      raise "path outside workspace" unless path.start_with?(@dir)

      path
    end

    def tests
      Sandbox.run(@dir, ["ruby", "-Ilib", "-e", 'Dir["test/*_test.rb"].each { |f| require "./#{f}" }'], seconds: 30)
    end

    def now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
