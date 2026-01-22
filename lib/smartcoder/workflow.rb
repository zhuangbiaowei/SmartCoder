# frozen_string_literal: true

require "fileutils"
require "json"
require "securerandom"
require_relative "container_runner"
require_relative "git_client"
require_relative "step"
require_relative "tui"

module SmartCoder
  class Workflow
    def initialize(config:, run:)
      @config = config
      @run = run
      @tui = TUI.new
      @git = GitClient.new
      @runner = ContainerRunner.new(config: config)
      @step_counter = 0
      @previous_step_id = nil
    end

    def run_chat(task:, verify_command:)
      @tui.render_header(@run.id)

      task ||= prompt_task
      patch_step = record_step(intent: "patch", summary: "Patch task: #{task}")
      write_log(patch_step.step_id, "Applied patch placeholder for: #{task}")
      finalize_step(patch_step)

      verify_cmd = verify_command || @config.verify_command
      verify_step = record_step(intent: "verify", summary: verify_cmd ? "Verify with #{verify_cmd}" : "Verify skipped")
      if verify_cmd
        stdout, stderr, status = @runner.run(verify_cmd)
        write_log(verify_step.step_id, stdout.to_s + stderr.to_s)
        verify_step.summary = "Verify #{status.success? ? "passed" : "failed"}"
      else
        write_log(verify_step.step_id, "No verify command configured.")
      end
      finalize_step(verify_step)

      @tui.render_footer
    end

    private

    def prompt_task
      print "Describe your task: "
      $stdin.gets.to_s.strip
    end

    def record_step(intent:, summary:)
      @step_counter += 1
      step = Step.new(
        step_id: @step_counter.to_s,
        parent_step_id: @previous_step_id,
        intent: intent,
        repo_commit: nil,
        container_ref: container_ref,
        actions: [],
        artifacts: [],
        summary: summary
      )
      @run.journal.append(step.to_h)
      @tui.render_step(step, log_path(step.step_id))
      step
    end

    def finalize_step(step)
      if @config.auto_commit?
        step.repo_commit = @git.commit_all("smartcoder step #{step.step_id}: #{step.intent}")
      else
        step.repo_commit = @git.current_commit
      end
      @run.journal.append(step.to_h)
      @previous_step_id = step.step_id
    end

    def container_ref
      ENV.fetch("DEVCONTAINER_ID", "host")
    end

    def log_path(step_id)
      File.join(@run.root, "logs", "step-#{step_id}.log")
    end

    def write_log(step_id, content)
      File.write(log_path(step_id), content)
    end
  end
end
