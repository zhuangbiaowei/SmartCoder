# 需求规格说明书（requirements.md）

```markdown
# SmartCoder 需求规格说明书

## 1. 产品目标

SmartCoder 是一个控制台 Coding Agent，其目标是：
- 在真实研发环境中执行开发任务
- 对每一步开发过程进行记录、回退与分叉
- 输出可审查、可验证的工程成果（diff / commit）

---

## 2. 用户角色

### 2.1 开发者（Primary）
- 希望在现有代码库中高效修改
- 需要可控、可回退的 AI 辅助
- 熟悉 Git / DevContainer

### 2.2 研究与实验用户
- 探索多种实现路径
- 对比不同策略或模型输出
- 需要完整执行轨迹

---

## 3. 功能需求

### 3.1 初始化
- `smartcoder init`
  - 生成 `.smartcoder.yml`
  - 探测 devcontainer 配置
  - 探测测试命令候选

### 3.2 交互式开发
- `smartcoder chat`
  - 启动 TUI
  - 接受自然语言任务
  - 显示 Step 树与执行状态

### 3.3 Agent 工作流
- 自动执行以下阶段：
  - 任务理解（Plan）
  - 代码/文档检索（Retrieve）
  - 代码修改（Patch）
  - 测试与验证（Verify）
  - 失败后迭代（Iterate）

### 3.4 DevContainer 执行
- 所有 shell / test 命令在 DevContainer 中执行
- 支持 host 模式与 container 模式

### 3.5 回退与分叉
- 每个 Step 自动生成 Git 保存点
- 支持从任意 Step：
  - 回退
  - 分叉新路径
  - 重新执行验证

### 3.6 执行轨迹记录
- 记录以下信息：
  - 提示词与上下文摘要
  - 工具调用参数
  - 命令 stdout / stderr
  - 代码 diff
  - 测试结果

---

## 4. 非功能需求

- **可复现性**：任意 Step 可在另一台机器复现
- **安全性**：危险命令需二次确认
- **可扩展性**：支持 MCP / 自定义工具
- **低侵入性**：不破坏用户现有 Git 流程

---

## 5. 不在范围内（v0.x）

- 自动代码合并到主分支
- 大规模 CI/CD 编排
- GUI（非 TUI）
