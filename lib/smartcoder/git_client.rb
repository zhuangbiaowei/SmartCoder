# frozen_string_literal: true

require "open3"
require "shellwords"

module SmartCoder
  class GitClient
    def status_clean?
      stdout, _stderr, _status = Open3.capture3("git status --porcelain")
      stdout.strip.empty?
    end

    def commit_all(message)
      return current_commit if status_clean?

      system("git add -A")
      system("git commit -m #{Shellwords.escape(message)}")
      current_commit
    end

    def current_commit
      stdout, _stderr, _status = Open3.capture3("git rev-parse HEAD")
      stdout.strip
    end
  end
end
