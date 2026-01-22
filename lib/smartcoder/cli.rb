# frozen_string_literal: true

require "fileutils"
require_relative "config"
require_relative "run_manager"
require_relative "workflow"

module SmartCoder
  class CLI
    def init
      config_path = Config.default_path
      if File.exist?(config_path)
        puts "Config already exists at #{config_path}"
        return
      end

      Config.write_default!(config_path)
      FileUtils.mkdir_p(".smartcoder")
      puts "Initialized SmartCoder at #{config_path}"
    end

    def chat(task:, verify_command:)
      config = Config.load_or_default
      run_manager = RunManager.new(config: config)
      run = run_manager.start_run

      workflow = Workflow.new(config: config, run: run)
      workflow.run_chat(task: task, verify_command: verify_command)
    end
  end
end
