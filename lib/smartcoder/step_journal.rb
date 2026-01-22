# frozen_string_literal: true

require "json"

module SmartCoder
  class StepJournal
    def initialize(path)
      @path = path
    end

    def append(step)
      File.open(@path, "a") do |file|
        file.puts(JSON.dump(step))
      end
    end
  end
end
