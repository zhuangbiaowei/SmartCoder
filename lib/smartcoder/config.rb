# frozen_string_literal: true

require "yaml"

module SmartCoder
  class Config
    DEFAULTS = {
      "mode" => "host",
      "verify_command" => nil,
      "auto_commit" => true,
    }.freeze

    def self.default_path
      File.join(Dir.pwd, ".smartcoder.yml")
    end

    def self.write_default!(path)
      File.write(path, DEFAULTS.to_yaml)
    end

    def self.load_or_default
      if File.exist?(default_path)
        new(YAML.safe_load(File.read(default_path)) || {})
      else
        new(DEFAULTS.dup)
      end
    end

    def initialize(values)
      @values = DEFAULTS.merge(values || {})
    end

    def [](key)
      @values[key]
    end

    def mode
      @values["mode"]
    end

    def verify_command
      @values["verify_command"]
    end

    def auto_commit?
      @values["auto_commit"]
    end
  end
end
