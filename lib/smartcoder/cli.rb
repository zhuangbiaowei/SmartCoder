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

      init_data = collect_init_preferences
      Config.write_default!(config_path)
      FileUtils.mkdir_p(".smartcoder")
      write_smart_agreements(init_data)
      puts "Initialized SmartCoder at #{config_path}"
    end

    def chat(task:, verify_command:)
      config = Config.load_or_default
      run_manager = RunManager.new(config: config)
      run = run_manager.start_run

      workflow = Workflow.new(config: config, run: run)
      workflow.run_chat(task: task, verify_command: verify_command)
    end

    private

    def collect_init_preferences
      puts "SmartCoder 初始化前需要确认一些约定。"
      puts "请按提示输入，直接回车将使用默认值。"
      puts ""

      git_defaults = {
        repo_name: File.basename(Dir.pwd),
        default_branch: "main",
        remote_url: "",
      }

      git_info = {
        repo_name: prompt("Git 仓库名称", default: git_defaults[:repo_name]),
        default_branch: prompt("默认分支", default: git_defaults[:default_branch]),
        remote_url: prompt("远程地址（可留空）", default: git_defaults[:remote_url]),
        git_status: git_status_answer,
      }

      license = prompt_choice(
        "License 选择",
        ["MIT", "Apache-2.0", "GPL-3.0", "BSD-3-Clause", "Proprietary", "其他"],
        default: "MIT",
        allow_other: true
      )

      dev_styles = prompt_multi_choice(
        "后续开发风格（可多选）",
        ["瀑布模型", "敏捷迭代", "逐步追加需求", "测试驱动开发", "其他"],
        default: ["敏捷迭代"],
        allow_other: true
      )

      language = prompt("主要编程语言", default: "待定")
      interaction_language = prompt_choice(
        "交互用的主语言",
        ["中文", "英文", "其他"],
        default: "中文",
        allow_other: true
      )

      must_do = prompt_multiline("必须做的事情（每行一条，空行结束）：")
      must_not = prompt_multiline("绝对不能做的事情（每行一条，空行结束）：")
      other_rules = prompt_multiline("其他需要写入 SMART.md 的关键约定（每行一条，空行结束）：")

      {
        git_info: git_info,
        license: license,
        dev_styles: dev_styles,
        language: language,
        interaction_language: interaction_language,
        must_do: must_do,
        must_not: must_not,
        other_rules: other_rules,
      }
    end

    def write_smart_agreements(init_data)
      path = File.join(Dir.pwd, "SMART.md")
      if File.exist?(path)
        puts "SMART.md already exists at #{path}, skipping write."
        return
      end

      content = []
      content << "# SMART 项目约定"
      content << ""
      content << "## Git 仓库配置"
      content << "- 仓库名称：#{init_data[:git_info][:repo_name]}"
      content << "- 默认分支：#{init_data[:git_info][:default_branch]}"
      content << "- 远程地址：#{init_data[:git_info][:remote_url].empty? ? "未填写" : init_data[:git_info][:remote_url]}"
      content << "- 仓库状态：#{init_data[:git_info][:git_status]}"
      content << ""
      content << "## License 选择"
      content << "- #{init_data[:license]}"
      content << ""
      content << "## 开发风格"
      content << init_data[:dev_styles].map { |style| "- #{style}" }
      content << ""
      content << "## 编程语言"
      content << "- #{init_data[:language]}"
      content << ""
      content << "## 交互主语言"
      content << "- #{init_data[:interaction_language]}"
      content << ""
      content << "## 必须做的事情"
      content << bullet_or_placeholder(init_data[:must_do])
      content << ""
      content << "## 绝对不能做的事情"
      content << bullet_or_placeholder(init_data[:must_not])
      content << ""
      content << "## 其他关键约定"
      content << bullet_or_placeholder(init_data[:other_rules])
      content << ""

      File.write(path, content.flatten.join("\n"))
    end

    def bullet_or_placeholder(lines)
      return "- 无" if lines.empty?

      lines.map { |line| "- #{line}" }
    end

    def prompt(message, default: nil)
      prompt_text = default.to_s.empty? ? "#{message}: " : "#{message} [#{default}]: "
      print prompt_text
      input = $stdin.gets
      return default.to_s if input.nil?

      stripped = input.strip
      stripped.empty? ? default.to_s : stripped
    end

    def prompt_multiline(message)
      puts message
      lines = []
      loop do
        line = $stdin.gets
        break if line.nil?

        stripped = line.chomp
        break if stripped.empty?

        lines << stripped
      end
      lines
    end

    def prompt_choice(message, choices, default:, allow_other: false)
      puts "#{message}:"
      choices.each_with_index do |choice, index|
        puts "  #{index + 1}. #{choice}"
      end
      default_index = choices.index(default) || 0
      print "请选择编号 [#{default_index + 1}]: "
      input = $stdin.gets
      selection = input.nil? ? "" : input.strip
      selection = (default_index + 1).to_s if selection.empty?

      if selection.match?(/^\d+$/)
        index = selection.to_i - 1
        choice = choices[index] || default
      else
        choice = selection
      end

      if allow_other && choice == "其他"
        return prompt("请输入自定义选项", default: "")
      end

      choice
    end

    def prompt_multi_choice(message, choices, default:, allow_other: false)
      puts "#{message}:"
      choices.each_with_index do |choice, index|
        puts "  #{index + 1}. #{choice}"
      end
      default_indices = default.map { |value| choices.index(value).to_i + 1 }
      print "请选择编号（多选用逗号分隔） [#{default_indices.join(", ")}]: "
      input = $stdin.gets
      selection = input.nil? ? "" : input.strip
      selection = default_indices.join(",") if selection.empty?

      selected = selection.split(",").map(&:strip).reject(&:empty?).flat_map do |token|
        if token.match?(/^\d+$/)
          choice = choices[token.to_i - 1]
          if allow_other && choice == "其他"
            custom = prompt("请输入自定义选项", default: "")
            custom.empty? ? nil : custom
          else
            choice
          end
        else
          token
        end
      end.compact

      selected.empty? ? default : selected
    end

    def git_status_answer
      if File.directory?(".git")
        "已存在"
      elsif prompt_yes_no("当前目录未检测到 Git 仓库，是否计划初始化？", default: true)
        "计划初始化"
      else
        "暂不初始化"
      end
    end

    def prompt_yes_no(message, default: false)
      suffix = default ? "Y/n" : "y/N"
      print "#{message} [#{suffix}]: "
      input = $stdin.gets
      return default if input.nil?

      value = input.strip.downcase
      return default if value.empty?

      %w[y yes].include?(value)
    end
  end
end
