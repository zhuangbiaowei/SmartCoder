# frozen_string_literal: true

require_relative "lib/smartcoder/version"

Gem::Specification.new do |spec|
  spec.name = "smartcoder"
  spec.version = SmartCoder::VERSION
  spec.authors = ["SmartCoder Contributors"]
  spec.email = ["dev@example.com"]

  spec.summary = "Console coding agent with traceable, reversible steps for DevContainer workflows."
  spec.description = "SmartCoder is a Ruby-based console coding agent that executes software tasks with traceable steps, Git checkpoints, and DevContainer support."
  spec.homepage = "https://example.com/smartcoder"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/changelog"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select { |path| File.file?(path) }
  end
  spec.bindir = "bin"
  spec.executables = ["smartcoder"]
  spec.require_paths = ["lib"]
end
