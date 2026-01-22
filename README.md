# SmartCoder

SmartCoder 是一个基于 Ruby 的 **控制台 Coding Agent**，用于在真实研发环境（DevContainer）中，**可追溯、可回退、可分叉**地执行软件开发任务。

它不仅“写代码”，而是像一名工程师一样：
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

---

## ✨ 核心特性

- **DevContainer 原生支持**
  - 所有开发步骤均在一致的研发环境中执行
  - 支持 `devcontainer exec` 或容器内运行

- **可回退 / 可分叉的开发轨迹**
  - 每一步都是一个可回放的 Step
  - 基于 Git 的自动保存点
  - 支持从任意步骤创建新路径

- **Agent 化软件工程工作流**
  - Plan → Retrieve → Patch → Verify → Iterate
  - 多 Agent 分工（Planner / Coder / Verifier / Retriever）

- **结构化执行日志（Execution Trace）**
  - 记录提示词、工具调用、命令输出、diff、测试结果
  - 适合审计、复盘与复现

- **Rich TUI 交互体验**
  - 基于 `ruby_rich`
  - Step 树 / Diff 预览 / 测试日志 / 路径选择

---

## 🧱 技术栈

- Ruby ≥ 3.2
- smart_agent
- smart_prompt
- smart_rag
- ruby_rich
- Docker / DevContainer
- Git

---

## 🚀 快速开始

```bash
gem install smartcoder
cd your-repo
smartcoder init
smartcoder chat

