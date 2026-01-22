# SmartCoder 架构说明

## 目录

- [1. 总体架构](#1-总体架构)
- [2. 技术选择](#2-技术选择)
- [3. 核心模块](#3-核心模块)
- [4. 数据流](#4-数据流)
- [5. 设计模式](#5-设计模式)
- [6. 存储结构](#6-存储结构)
- [7. 与现有项目的关系](#7-与现有项目的关系)

---

## 1. 总体架构

### 1.1 分层架构

SmartCoder 采用清晰的分层架构，各层职责明确：

```
┌─────────────────────────────────────────────────────────┐
│                    用户交互层                            │
│  CLI (init/chat)  ←→  TUI (terminal display)          │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│                    编排层                                │
│  Workflow (工作流引擎)  ←→  RunManager (运行管理)       │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│                   工作层 / 工具层                         │
│  StepJournal (记录)  │  GitClient (版本控制)            │
│  ContainerRunner (执行)  │  Config (配置)               │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│                  外部系统 / 存储                          │
│  DevContainer (容器)  │  Git (仓库)  │  文件系统         │
└─────────────────────────────────────────────────────────┘
```

### 1.2 模块职责划分

- **CLI 层**: 处理用户输入，解析命令行参数
- **UI 层**: 渲染终端界面，显示进度和日志
- **编排层**: 协调工作流，管理运行生命周期
- **工作层**: 执行具体任务（容器操作、Git 操作）
- **存储层**: 持久化配置、步骤记录和日志

---

## 2. 技术选择

### 2.1 为什么选择 Ruby？

**优势**:

1. **简洁的语法**
   - 代码可读性高，适合快速开发
   - 动态类型系统减少样板代码

2. **强大的标准库**
   - 无需额外依赖即可实现核心功能
   - 内置 JSON/YAML 支持
   - 强大的进程管理（Open3）

3. **良好的生态**
   - 丰富的 Gems（未来可扩展）
   - DevContainer CLI 等工具集成方便

4. **适合脚本化**
   - 天生适合命令行工具开发
   - 快速迭代和原型验证

**决策**: Ruby 3.2+ 确保了现代语言特性和性能优化

### 2.2 为什么使用 DevContainer？

**一致性保证**:
- 开发环境与生产环境完全一致
- 避免依赖版本冲突问题
- 支持多语言项目

**隔离性**:
- 命令在容器内执行，不影响宿主机
- 可安全运行测试和构建命令
- 支持容器快照（未来功能）

**标准化**:
- `.devcontainer/` 配置标准化
- VS Code / GitHub Codespaces 原生支持
- 团队协作无需配置本地环境

### 2.3 为什么选择 JSONL 格式？

**JSONL (JSON Lines) 优势**:
- 每行一个完整的 JSON 对象
- 适合流式写入（append-only）
- 易于解析和人类阅读
- 支持增量处理和部分读取

**对比其他格式**:
- **JSON Array**: 必须读取整个文件
- **SQLite**: 引入数据库依赖
- **普通文本**: 结构化解析困难

---

## 3. 核心 模块

### 3.1 CLI 层

#### `cli.rb` - 命令行接口

**职责**:
- 解析命令行参数（init, chat）
- 验证用户输入
- 协调 Config、RunManager 和 Workflow

**关键方法**:
```ruby
def init                    # 初始化配置和目录
def chat(task:, verify_command:)  # 启动对话式开发
```

**设计原则**:
- 薄 CLI 层：仅处理入口逻辑
- 业务逻辑委托给下层模块
- 提供友好的错误提示

---

### 3.2 UI 层

#### `tui.rb` - 终端用户界面

**职责**:
- 渲染运行进度
- 显示步骤信息
- 输出日志文件路径

**当前实现**:
- 简单的文本输出（v0.1.0）
- 基于 `ruby_rich`（未来增强）

**渲染格式**:
```
SmartCoder Run: 20240122153045-a3b2
----------------------------------------
[1] patch - Patch task: fix bug
  Log: .smartcoder/runs/.../logs/step-1.log
[2] verify - Verify passed
  Log: .smartcoder/runs/.../logs/step-2.log
----------------------------------------
```

**未来扩展** (v0.2+):
- Rich UI 组件（进度条、表格、树形视图）
- 交互式步骤选择
- Diff 预览和确认界面

---

### 3.3 编排层

#### `workflow.rb` - 工作流引擎

**职责**:
- 协调 Patch → Verify 循环
- 管理步骤生命周期
- 集成 Git 和容器执行

**工作流阶段**:
1. **Plan**: 理解任务（未来集成 LLM）
2. **Retrieve**: 检索代码（未来 RAG）
3. **Patch**: 生成并应用补丁
4. **Verify**: 运行验证命令
5. **Iterate**: 根据结果迭代

**关键方法**:
```ruby
def run_chat(task:, verify_command:)  # 主入口
def record_step(intent:, summary:)     # 创建步骤
def finalize_step(step)                # 完成步骤（Git 提交）
```

**设计模式**:
- **Builder 模式**: 逐步构建和完成步骤
- **Strategy 模式**: 根据 config.mode 选择执行策略

---

#### `run_manager.rb` - 运行管理器

**职责**:
- 创建和管理运行会话
- 生成唯一 Run ID
- 初始化目录结构

**Run 数据结构**:
```ruby
Run = Struct.new(:id, :root, :journal, keyword_init: true)
```

**目录结构**:
```
.smartcoder/runs/<run_id>/
├── journal.jsonl    # 步骤记录
└── logs/
    ├── step-1.log
    ├── step-2.log
    └── ...
```

**Run ID 格式**: `YYYYMMDDHHMMSS-{4-char-hex}`
- 示例: `20240122153045-a3b2`

---

### 3.4 数据模型层

#### `step.rb` - 步骤模型

**职责**:
- 定义步骤数据结构
- 提供不可变数据封装

**字段说明**:
```ruby
Step = Struct.new(
  :step_id,         # 步骤 ID（字符串："1", "2"...）
  :parent_step_id,  # 父步骤 ID（用于分叉和回退）
  :intent,          # 意图："patch", "verify", "plan"
  :repo_commit,     # Git 提交 SHA（步骤后的状态）
  :container_ref,   # 容器引用："host" 或容器 ID
  :actions,         # 操作记录（工具调用等）
  :artifacts,       # 产物（文件、日志）
  :summary,         # 人类可读的摘要
  keyword_init: true
)
```

**不可变性**:
- Ruby Struct 提供基本不可变性
- 步骤创建后不应修改
- 记录在 journal.jsonl 中

---

#### `step_journal.rb` - 步骤记录

**职责**:
- 以 JSONL 格式持久化步骤
- 提供追加式写入接口

**关键方法**:
```ruby
def append(step)  # 追加步骤到 JSONL 文件
```

**JSONL 示例**:
```jsonl
{"step_id":"1","parent_step_id":null,"intent":"patch","repo_commit":"abc123","container_ref":"host","actions":[],"artifacts":[],"summary":"Patch task: fix bug"}
{"step_id":"2","parent_step_id":"1","intent":"verify","repo_commit":"def456","container_ref":"host","actions":[],"artifacts":[],"summary":"Verify passed"}
```

**设计考虑**:
- **Append-only**: 不支持更新，确保不可变性
- **简单读取**: 每行一个对象，易于解析
- **审计友好**: 适合回溯和复现

---

### 3.5 工具层

#### `config.rb` - 配置管理

**职责**:
- 加载和管理配置
- 提供默认值
- 支持 YAML 文件配置

**配置文件位置**: `.smartcoder.yml`

**默认配置**:
```yaml
mode: host              # 执行模式：host 或 container
verify_command: null    # 验证命令（如 "bundle exec rspec"）
auto_commit: true       # 是否自动提交
```

**关键方法**:
```ruby
def default_path              # 返回配置文件路径
def write_default!(path)      # 写入默认配置
def load_or_default           # 加载或使用默认
def mode / verify_command / auto_commit?  # 访问器
```

---

#### `git_client.rb` - Git 操作封装

**职责**:
- 封装 Git 命令
- 管理提交和状态检查

**关键方法**:
```ruby
def status_clean?        # 检查工作区是否干净
def commit_all(message)  # 提交所有更改
def current_commit       # 获取当前 HEAD SHA
```

**安全性**:
- 使用 `Shellwords.escape` 防止命令注入
- 仅在状态非空时创建提交

---

#### `container_runner.rb` - 容器执行器

**职责**:
- 在 DevContainer 或宿主机执行命令
- 抽象容器层差异

**执行策略**:
1. **Container 模式**: 直接执行命令（已在容器内）
2. **Host 模式 + DevContainer**: 使用 `devcontainer exec` 包装
3. **Host 模式**: 直接执行命令

**关键方法**:
```ruby
def run(command)  # 执行命令，返回 stdout, stderr, status
```

**实现细节**:
```ruby
def container_command(command)
  if @config.mode == "container"
    command
  elsif devcontainer_available?
    "devcontainer exec --workspace-folder . #{command}"
  else
    command
  end
end
```

---

## 4. 数据流

### 4.1 初始化流程

```
用户执行: smartcoder init
    ↓
CLI.init()
    ↓
├─ Config.write_default!(.smartcoder.yml)
│   └─ 创建 .smartcoder.yml 配置文件
└─ FileUtils.mkdir_p(.smartcoder/)
    └─ 创建 .smartcoder/ 目录
    ↓
用户看到: "Initialized SmartCoder at .smartcoder.yml"
```

### 4.2 对话执行流程

```
用户执行: smartcoder chat --task "fix bug" --verify-cmd "bundle test"
    ↓
CLI.chat(task: "fix bug", verify_command: "bundle test")
    ↓
├─ Config.load_or_default()
│   ├─ 读取 .smartcoder.yml（如果存在）
│   └─ 或使用默认配置
│
├─ RunManager.start_run()
│   ├─ 生成 run_id: "20240122153045-a3b2"
│   ├─ 创建目录: .smartcoder/runs/<run_id>/logs/
│   └─ 创建 StepJournal(journal.jsonl)
│
└─ Workflow.new(config, run)
    ├─ TUI.new()
    ├─ GitClient.new()
    └─ ContainerRunner.new(config)
    ↓
Workflow.run_chat()
    ├─ TUI.render_header(run_id)
    │
    ├─ 创建 PATCH 步骤:
    │   ├─ Step.new(intent: "patch", summary: "Patch task: fix bug")
    │   ├─ StepJournal.append(step.to_h)
    │   ├─ TUI.render_step(step, log_path)
    │   ├─ write_log(step_id, "Applied patch placeholder...")
    │   └─ finalize_step(step)
    │       └─ GitClient.commit_all() → step.repo_commit
    │
    ├─ 创建 VERIFY 步骤:
    │   ├─ Step.new(intent: "verify", summary: "Verify with bundle test")
    │   ├─ ContainerRunner.run("bundle test")
    │   │   └─ 返回 stdout, stderr, status
    │   ├─ write_log(step_id, stdout + stderr)
    │   ├─ step.summary = "Verify passed/failed" (根据 status)
    │   ├─ StepJournal.append(step.to_h)
    │   ├─ TUI.render_step(step, log_path)
    │   └─ finalize_step(step)
    │       └─ GitClient.commit_all() → step.repo_commit
    │
    └─ TUI.render_footer()
```

### 4.3 步骤生命周期

```
Step 创建 → StepJournal.append() → TUI.render()
    ↓
执行动作（patch / verify）
    ↓
write_log(step_id, content)
    ↓
finalize_step(step)
    ↓
GitClient.commit_all() → step.repo_commit
    ↓
StepJournal.append(step.to_h) (更新后的状态)
    ↓
更新 previous_step_id
```

### 4.4 数据依赖图

```
Config (配置中心)
    ↓
RunManager (创建运行)
    ↓
Workflow (工作流协调)
    ├─→ TUI (显示)
    ├─→ GitClient (版本控制)
    ├─→ ContainerRunner (执行)
    │       ↓
    │   输出 → write_log() → 日志文件
    └─→ StepJournal (记录)
            ↓
        JSONL 文件
```

---

## 5. 设计模式

### 5.1 使用的模式

#### 1. **Builder 模式** (Workflow)
- 逐步构建完整的步骤
- 分离创建和最终化逻辑
- 支持复杂的多阶段构建

#### 2. **Strategy 模式** (ContainerRunner)
- 根据 config.mode 选择执行策略
- 抽象不同的执行环境
- 易于扩展新的执行方式

#### 3. **Struct 模式** (Step, Run)
- 不可变数据结构
- 简洁的数据封装
- 支持 to_h 序列化

#### 4. **Singleton 模式** (Config)
- 全局配置访问点
- 延迟加载和默认值
- 避免重复初始化

#### 5. **Facade 模式** (CLI)
- 简化的用户入口
- 隐藏内部复杂性
- 提供友好的接口

### 5.2 设计原则

#### 1. **单一职责原则 (SRP)**
- 每个模块只有一个变更理由
- 例如：GitClient 只处理 Git 操作

#### 2. **开闭原则 (OCP)**
- 对扩展开放，对修改关闭
- 例如：ContainerRunner 易于添加新的执行模式

#### 3. **依赖倒置原则 (DIP)**
- 高层模块不依赖低层模块
- 通过接口/抽象进行交互

#### 4. **接口隔离原则 (ISP)**
- 模块只暴露必要的接口
- 最小化公共 API

---

## 6. 存储结构

### 6.1 文件系统布局

```
.smartcoder/
├── .smartcoder.yml              # 配置文件（项目根）
└── runs/
    ├── <run_id>/                # 运行会话目录
    │   ├── journal.jsonl        # 步骤记录（JSONL 格式）
    │   └── logs/                # 执行日志
    │       ├── step-1.log
    │       ├── step-2.log
    │       └── ...
    └── ...
```

### 6.2 配置文件格式 (YAML)

```yaml
# .smartcoder.yml
mode: host                      # 执行模式
verify_command: bundle exec rspec  # 验证命令
auto_commit: true               # 自动提交
```

### 6.3 Journal 格式 (JSONL)

每行一个完整的 JSON 对象：

```jsonl
{"step_id":"1","parent_step_id":null,"intent":"patch","repo_commit":"abc123def","container_ref":"host","actions":[],"artifacts":[],"summary":"Patch task: fix authentication bug"}
{"step_id":"2","parent_step_id":"1","intent":"verify","repo_commit":"def456ghi","container_ref":"host","actions":[],"artifacts":[],"summary":"Verify passed"}
```

### 6.4 日志文件格式

纯文本格式，记录命令输出：

```
Step 1: Patch task: fix authentication bug
=========================================
Running: git apply patch.diff
Applied successfully.

Step 2: Verify with bundle exec rspec
========================================
Running: bundle exec rspec
..........

Finished in 0.456 seconds
10 examples, 0 failures
```

---

## 7. 与现有项目的关系

### 7.1 依赖的外部系统

| 系统 | 用途 | 集成方式 |
|------|------|----------|
| **Ruby 3.2+** | 运行时环境 | 核心语言支持 |
| **Git** | 版本控制 | GitClient 封装 |
| **DevContainer** | 容器化开发 | ContainerRunner 集成 |
| **VS Code** | 编辑器支持 | DevContainer 配置 |

### 7.2 未来依赖（规划中）

| 项目 | 用途 | 版本 |
|------|------|------|
| **smart_agent** | 多 Agent 工作流 | v0.2+ |
| **smart_prompt** | LLM 交互 | v0.2+ |
| **smart_rag** | 代码检索 | v0.2+ |
| **ruby_rich** | Rich TUI | v0.2+ |

### 7.3 集成策略

#### 现有实现 (v0.1.0)
- 完全自包含，无外部 Gem 依赖
- 仅使用 Ruby 标准库
- 最小化依赖，易于安装

#### 未来扩展 (v0.2+)
- 渐进式引入依赖
- 保持可选依赖
- 向后兼容 v0.1.0

---

## 8. 架构演进

### 8.1 当前状态 (v0.1.0)

**已实现**:
- ✅ CLI 入口（init, chat）
- ✅ DevContainer 执行支持
- ✅ Step Journaling（JSONL）
- ✅ Git 自动提交
- ✅ 基础 TUI
- ✅ Patch + Verify 闭环

**限制**:
- ❌ 步骤分叉/回退未实现
- ❌ Diff 预览未实现
- ❌ LLM 集成未实现
- ❌ RAG 检索未实现

### 8.2 短期计划 (v0.2)

**新增功能**:
- [ ] Step 分叉 / 回退命令
- [ ] Diff 预览与确认
- [ ] 危险命令拦截
- [ ] RAG 检索代码
- [ ] Replay verify

**架构改进**:
- 增强 Workflow 支持多路径
- 扩展 Step 模型支持分支
- 引入 LLM 集成层

### 8.3 长期愿景 (v1.0)

**完整功能**:
- [ ] 多 Agent 并行执行
- [ ] 轨迹写入 RAG
- [ ] 容器快照
- [ ] Headless 模式（CI/CD）
- [ ] MCP 协议集成
- [ ] PR 自动生成
- [ ] 多 Run 管理

**架构演进**:
- 引入 Agent 协调层
- 支持分布式执行
- 增强 TUI 交互能力

---

## 9. 性能考虑

### 9.1 当前性能特征

- **启动速度**: 快速（Ruby 脚本，无重型依赖）
- **内存占用**: 低（< 50MB）
- **磁盘 I/O**: 适中（JSONL 追加写入）
- **网络依赖**: 无（除非调用远程 API）

### 9.2 优化方向

1. **并发执行** (v0.3+)
   - 多步骤并行
   - 多 Agent 并行

2. **缓存策略**
   - 缓存 Git 状态
   - 缓存配置加载

3. **增量处理**
   - 流式日志处理
   - 增量 Journal 解析

---

## 10. 安全考虑

### 10.1 当前安全措施

1. **命令注入防护**
   - 使用 `Shellwords.escape`
   - 避免直接字符串拼接

2. **Git 操作安全**
   - 仅在状态非空时提交
   - 显式提交消息

3. **文件系统隔离**
   - 使用 `.smartcoder/` 隔离目录
   - 不越界访问

### 10.2 未来增强

1. **危险命令拦截** (v0.2)
   - 检测 rm、dd 等危险命令
   - 二次确认机制

2. **权限控制**
   - 限制可执行命令范围
   - 容器权限隔离

3. **审计日志**
   - 记录所有命令执行
   - 支持审计追踪

---

## 附录

### A. 相关文档

- [README.md](../README.md) - 用户指南
- [technical-spec.md](technical-spec.md) - 技术规格
- [requirements.md](requirements.md) - 产品需求
- [TODO.md](TODO.md) - 开发路线图

### B. 代码位置

- 源码: `lib/smartcoder/*.rb`
- 入口: `bin/smartcoder`
- 文档: `docs/*.md`
- 配置: `.smartcoder.yml`

### C. 贡献指南

请参阅 [CONTRIBUTING.md](../CONTRIBUTING.md) 了解如何贡献。

---

**最后更新**: 2026-01-22
**版本**: 0.1.0
