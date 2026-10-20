# frozen_string_literal: true

require "json"
require "tmpdir"
require_relative "../sandbox"

# MultiPL-E HumanEval-Ruby. The model works through a fixed, seeded problem order.
#
# Screen mode (default): stop starting new problems once `box` seconds have passed.
# Extended mode: carry on through all 161 problems, testing in batches of 10 so the running
# pass rate and projected finish time are known, and stop early when either
#   - the projected total exceeds `max_minutes`, or
#   - after `min_attempts`, the running pass rate is below `min_pass_rate`.
module Screens
  class Coding
    DATA = File.expand_path("../../data/multipl-e-humaneval-rb.jsonl", __dir__)
    SYSTEM = "You are an expert Ruby programmer. Reply with only the complete Ruby method " \
             "in a single ```ruby code block. No explanation."
    BATCH = 10

    def initialize(client, box:, max_tokens: 1024, extended: false, max_minutes: 60,
                   min_pass_rate: 0.5, min_attempts: 20, progress: nil)
      @client = client
      @box = box
      @max_tokens = max_tokens
      @extended = extended
      @max_minutes = max_minutes
      @min_pass_rate = min_pass_rate
      @min_attempts = min_attempts
      @progress = progress
    end

    def problems
      @problems ||= File.readlines(DATA).map { JSON.parse(_1) }.shuffle(random: Random.new(42))
    end

    def run
      started = now
      done = []
      pending = []
      stop = "completed"
      problems.each do |p|
        elapsed = now - started
        if !@extended && elapsed > @box
          stop = "time_box"
          break
        end
        if @extended && (reason = early_stop(done, elapsed))
          stop = reason
          break
        end

        res = @client.chat([{ role: "system", content: SYSTEM }, { role: "user", content: p["prompt"] }],
                           max_tokens: @max_tokens, timeout: 900)
        tokens = res.dig(:usage, "completion_tokens")
        pending << { name: p["name"], seconds: res[:seconds]&.round(1), error: res[:error], tokens: tokens,
                     hit_cap: tokens.to_i >= @max_tokens, finish_reason: res[:finish_reason],
                     code: res[:error] ? nil : program(p, res[:content]) }
        next unless @extended && pending.size >= BATCH

        done.concat(test(pending))
        pending = []
        report(done, now - started)
      end
      done.concat(test(pending)) unless pending.empty?
      passed = done.count { _1[:passed] }
      secs = done.sum { _1[:seconds].to_f }
      { mode: @extended ? "extended" : "screen", stop: stop, attempted: done.size, passed: passed,
        total_problems: problems.size, pass_rate: done.empty? ? 0 : (passed.to_f / done.size).round(3),
        gen_seconds: (now - started).round(1), seconds_per_problem: done.empty? ? nil : (secs / done.size).round(1),
        solved_per_hour: secs.positive? ? (passed * 3600 / secs).round(1) : nil,
        hit_cap: done.count { _1[:hit_cap] }, max_tokens: @max_tokens, box_seconds: @box, problems: done }
    end

    private

    def early_stop(done, elapsed)
      return nil if done.empty?

      rate = done.count { _1[:passed] }.to_f / done.size
      return "low_pass_rate (#{(rate * 100).round}% after #{done.size})" if done.size >= @min_attempts && rate < @min_pass_rate
      return "time_cap (#{@max_minutes} min)" if elapsed / 60 >= @max_minutes

      nil
    end

    def report(done, elapsed)
      return unless @progress

      passed = done.count { _1[:passed] }
      per = elapsed / done.size
      eta = (problems.size - done.size) * per / 60
      @progress.call(format("coding %d/%d, pass %d%% (%d), %.1f s/problem, ~%.0f min left at this pace",
                            done.size, problems.size, passed * 100 / done.size, passed, per, eta))
    end

    # Prefer the model's full method; fall back to prompt + body when it returned only a body.
    def program(problem, content)
      code = content[/```(?:ruby|rb)?\s*\n(.*?)```/m, 1] || content
      name = problem["prompt"][/^def (\w+[?!]?)/, 1]
      code = "#{problem['prompt']}#{code}\nend\n" unless name && code =~ /^\s*def #{Regexp.escape(name)}\b/
      "#{code}\n\n#{problem['tests']}"
    end

    def test(answers)
      Sandbox.mktmpdir("coding") do |dir|
        answers.each_with_index do |a, i|
          File.write(File.join(dir, format("p%03d.rb", i)), a[:code]) if a[:code]
        end
        script = 'for f in p*.rb; do if timeout 10 ruby "$f" >/dev/null 2>&1; then echo "PASS $f"; else echo "FAIL $f"; fi; done'
        _ok, out = Sandbox.run(dir, ["sh", "-c", script], seconds: 600)
        verdicts = out.scan(/(PASS|FAIL) p(\d+)\.rb/).to_h { |v, i| [i.to_i, v == "PASS"] }
        answers.each_with_index.map do |a, i|
          a.merge(passed: verdicts.fetch(i, false))
        end
      end
    end

    def now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
