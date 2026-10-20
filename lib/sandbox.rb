# frozen_string_literal: true

require "open3"
require "tmpdir"
require "timeout"

# Runs model-written Ruby inside a throwaway container: no network, capped memory and CPU.
module Sandbox
  IMAGE = ENV.fetch("BENCH_RUBY_IMAGE", "ruby:3.4-slim-bookworm")
  # Docker Desktop doesn't share /tmp or /var/folders, so work dirs live inside the repo.
  WORK = File.expand_path("../tmp", __dir__)

  def self.mktmpdir(prefix, &)
    Dir.mkdir(WORK) unless Dir.exist?(WORK)
    Dir.mktmpdir(prefix, WORK, &)
  end

  # Runs `cmd` (array) with `dir` mounted at /w. Returns [ok, output].
  def self.run(dir, cmd, seconds: 30)
    docker = ["docker", "run", "--rm", "--network", "none", "--memory", "512m", "--cpus", "1",
              "-v", "#{dir}:/w", "-w", "/w", IMAGE, "timeout", seconds.to_s, *cmd]
    out, status = Open3.capture2e(*docker)
    [status.success?, out]
  end
end
