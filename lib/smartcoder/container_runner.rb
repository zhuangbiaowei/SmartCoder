# frozen_string_literal: true

require "open3"

module SmartCoder
  class ContainerRunner
    def initialize(config:)
      @config = config
    end

    def run(command)
      full_command = container_command(command)
      Open3.capture3(full_command)
    end

    private

    def container_command(command)
      if @config.mode == "container"
        command
      elsif devcontainer_available?
        "devcontainer exec --workspace-folder . #{command}"
      else
        command
      end
    end

    def devcontainer_available?
      @devcontainer_available ||= system("which devcontainer > /dev/null 2>&1")
    end
  end
end
