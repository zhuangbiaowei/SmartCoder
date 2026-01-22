# frozen_string_literal: true

module SmartCoder
  class TUI
    def initialize(io: $stdout)
      @io = io
    end

    def render_header(run_id)
      @io.puts("SmartCoder Run: #{run_id}")
      @io.puts("-" * 40)
    end

    def render_step(step, log_path)
      @io.puts("[#{step.step_id}] #{step.intent} - #{step.summary}")
      @io.puts("  Log: #{log_path}")
    end

    def render_footer
      @io.puts("-" * 40)
    end
  end
end
