# SmartCoder

[![Ruby Version](https://img.shields.io/badge/ruby-3.2+-ff69b4?logo=ruby)](https://www.ruby-lang.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Gem Version](https://img.shields.io/badge/version-0.1.0-green.svg)](https://rubygems.org/gems/smartcoder)
[![Documentation](https://img.shields.io/badge/docs-complete-brightgreen.svg)](docs/)

**SmartCoder** 是一个基于 Ruby 的 **控制台 Coding Agent**，用于在真实研发环境（DevContainer）中，**可追溯、可回退、可分叉**地执行软件开发任务。

它不仅"写代码"，而是像一名工程师一样：
- 理解需求或 Issue
- 阅读与检索代码
- 生成最小化补丁（diff）
- 在 DevContainer 中运行测试与验证
- 记录完整执行轨迹
- 支持任意步骤回退或选择其他实现路径

SmartCoder 适合用于：
- 复杂代码库中的增量修改
- Bug 修复与重构
- AI 辅助的工程实验与探索
- 可审计、可复现的软件研发流程

## ✨ 核心特性

- **DevContainer 原生支持**
  - 所有开发步骤均在一致的研发环境中执行
  - 支持容器内运行

- **可回退 / 可分叉的开发轨迹**
  - 每一步都是一个可回放的 Step
  - 基于的 Git 的自动保存点
  - 支持从任意步骤创建新路径

- **Agent 化软件工程工作流**
  - Plan → Retrieve → Patch → Verify → Iterate
  - 多 Agent 分工（Planner / Coder / Verifier / Retriever）

- **结构化执行日志（Execution Trace）**
  - 记录提示词、工具调用、命令输出、diff、测试结果
  - 适合审计、复盘与复现

- **Rich TUI 交互体验**
  - 基于基于 `ruby_rich`
  - Step 树 / Diff 预览 / 测试日志 / 路径选择

## 🚀 快速开始

### 安装

使用 gem 安装：

```bash
gem install smartcoder
```

### 使用流程

1. **初始化配置**
   ```bash
   smartcoder init
   ```

2. **开始与 AI 对话**
   ```bash
   smartcoder chat
   ```

3. **完成开发后**
   - 按照提示完成每个步骤
   - 查看步骤日志和 diff
   - 测试并验证修改
   - 使用 `git log` 查看完整的开发轨迹

### 基本使用

```bash
# 安装
gem install smartcoder

# 初始化配置（会自动创建 .smartcoder/ 目录）
smartcoder init

# 开始编码
smartcoder chat
```

### 从源码安装

1. **克隆仓库**
   ```bash
   git clone https://github.com/your-org/smartcoder.git
   cd smartcoder
   ```

2. **安装依赖**
   ```bash
   # 安装 Ruby 3.2 或更高版本
   # 确保已安装 devtools
   gem install bundler
   bundle install
   ```

3. **本地安装**
   ```bash
   gem build smartcoder.gemspec
   gem install ./smartcoder-0.1.0.gem
   ```

### 系统要求

- Ruby ≥ 3.2
- Git
- Docker 或 Docker Compose（用于 DevContainer）
- bash（用于脚本执行）

## 📋 功能特性

### ✅ 核心功能 (v0.1.0)

- **DevContainer 原生支持**
  - 所有开发步骤均在一致的研发环境中执行
  - 支持容器内运行

- **可回退 / 可分叉的开发轨迹**
  - 每一步都是一个可回放的 Step
  - 基于的 Git 的自动保存点
  - 支持从任意步骤创建新路径

- **Agent 化软件工程工作流**
  - Plan → Retrieve → Patch → Verify → Iterate
  - 多 Agent 分工（Planner / Coder / Verifier / Retriever）

- **结构化执行日志（Execution Trace）**
  - 记录提示词、工具调用、命令输出、diff、测试结果
  - 适合审计、复盘与复现

- **Rich TUI 交互体验**
  - 基于基于 `ruby_rich`
  - Step 树 / Diff 预览 / 测试日志 / 路径选择

### 🚧 计划中的功能

- **v0.2**
  - Step 分叉 / 回退命令
  - Diff 预览与确认
  - 危险命令拦截
  - RAG 检索代码
  - Replay verify

  **[查看完整路线图](./docs/TODO.md)**

## 🏗️ 架构

### 模块设计

SmartCoder 采用模块化设计，主要包含以下核心模块：

- **config.rb** - 配置管理
- **step.rb** - 步骤模型
- **step_journal.rb** - 步骤记录
- **git_client.rb** - Git 操作封装
- **container_runner.rb** - 容器执行器
- **tui.rb** - TUI 界面
- **workflow.rb** - 工作流引擎
- **run_manager.rb** - 运行管理器
- **cli.rb** - 命令行接口

### 工作原理

1. **初始化配置** - 创建 `.smartcoder/` 配置目录和配置文件
2. **执行任务** - 接收用户任务，逐步执行
3. **记录步骤** - 为每个步骤创建 JSONL 记录
4. **Git 保存** - 每步完成后自动提交到 Git
5. **TUI 交互** - 实时显示步骤和日志

### 使用示例

#### 示例 1: 修复 Bug

```bash
# 1. 初始化
smartcoder init

# 2. 修复 bug
smartcoder chat

# 3. 查看修改
git diff
git log --oneline
```

#### 示例 2: 重构代码

```bash
# 开始重构任务
smartcoder chat

# 逐步验证每一步
smartcoder chat

# 确认最终修改
git diff
```

## 🧪 测试

```bash
# 运行测试
bundle exec rspec

# 运行测试覆盖率
COVERAGE=1 bundle exec rspec
```

## 🔧 故障排除

### 常见问题

#### 1. Ruby 版本不匹配

**问题**: `smartcoder: Ruby version 3.2.0 or higher required`

**解决方案**:
```bash
# 检查当前 Ruby 版本
ruby --version

# 使用 RVM 安装 Ruby 3.2+
rvm install 3.2
rvm use 3.2

# 或使用 rbenv
rbenv install 3.2.0
rbenv local 3.2.0
```

#### 2. DevContainer 命令未找到

**问题**: DevContainer 相关命令无法执行

**解决方案**:
```bash
# 安装 DevContainer CLI
npm install -g @devcontainers/cli

# 验证安装
devcontainer --version
```

#### 3. Git 状态检查失败

**问题**: Git 提交时出现错误

**解决方案**:
```bash
# 确保 Git 已初始化
git init

# 配置 Git 用户（如果未配置）
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

#### 4. 配置文件冲突

**问题**: `.smartcoder.yml` 配置不生效

**解决方案**:
```bash
# 删除现有配置并重新初始化
rm .smartcoder.yml
smartcoder init

# 手动检查配置文件
cat .smartcoder.yml
```

#### 5. 权限问题

**问题**: 无法写入 `.smartcoder/` 目录

**解决方案**:
```bash
# 检查目录权限
ls -la .smartcoder/

# 修复权限（如需要）
chmod -R 755 .smartcoder/
```

### 调试模式

启用详细日志输出以调试问题：

```bash
# 设置环境变量以启用调试
export SMARTCODER_DEBUG=1

# 运行命令
smartcoder chat
```

### 获取帮助

如果遇到其他问题，请：

1. 查看 [架构文档](docs/architecture.md) 了解系统设计
2. 检查 [技术规格](docs/technical-spec.md) 了解实现细节
3. 提交 [Issue](https://github.com/your-org/smartcoder/issues) 报告问题
4. 查看 [贡献指南](CONTRIBUTING.md) 了解如何贡献

## 🤝 贡献

欢迎贡献！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详情。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

**贡献指南包括**:
- 开发环境设置
- 代码风格规范
- 提交信息格式
- 测试指南
- PR 流程

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 📚 相关链接

- [Issues](https://github.com/your-org/smartcoder/issues) - 问题追踪
- [贡献指南](CONTRIBUTING.md) - 如何参与
- [路线图](docs/TODO.md) - 开发计划
- [文档](docs/) - 详细文档

## 🙏 致谢

感谢所有贡献者！([贡献者名单](CONTRIBUTORS.md)](https://github.com/your-org/smartcoder/blob/main/CONTRIBUTORS.md))

---

**[SmartCoder](https://github.com/your-org/smartcoder)**
