# frozen_string_literal: true

require "fileutils"
require "securerandom"
require_relative "step_journal"

module SmartCoder
  Run = Struct.new(:id, :root, :journal, keyword_init: true)

  class RunManager
    def initialize(config:)
      @config = config
    end

    def start_run
      run_id = "#{Time.now.utc.strftime("%Y%m%d%H%M%S")}-#{SecureRandom.hex(4)}"
      root = File.join(Dir.pwd, ".smartcoder", "runs", run_id)
      FileUtils.mkdir_p(File.join(root, "logs"))
      journal = StepJournal.new(File.join(root, "journal.jsonl"))

      Run.new(id: run_id, root: root, journal: journal)
    end
  end
end
