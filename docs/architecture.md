# 架构说明（architecture.md）

# SmartCoder 架构说明

## 1. 总体架构
```
UI (ruby_rich)
↓
Orchestrator (smart_agent)
↓
Workers (smart_prompt)
↓
Tools / RAG / DevContainer
```
---

## 2. 核心模块

### 2.1 CLI
- smartcoder init
- smartcoder chat
- smartcoder run

### 2.2 UI 层
- Step Tree Renderer
- Diff Viewer
- Log Viewer
- Input Handler

### 2.3 Orchestrator
- RunManager
- StepManager
- WorkflowEngine
- EventBus

### 2.4 Workers（Agent 角色）
- PlannerWorker
- RetrieverWorker
- CoderWorker
- VerifierWorker
- ExplainerWorker

### 2.5 Tooling
- Tool::Repo
- Tool::Git
- Tool::Container
- Tool::Test
- Tool::Rag

### 2.6 Storage
- `.smartcoder/runs/*`
- Journal（JSONL）
- Artifacts（diff / logs）

---

## 3. 与现有项目的关系

- smart_agent：工作流与多 Agent
- smart_prompt：LLM worker 模板
- smart_rag：代码与轨迹检索
- ruby_rich：TUI 渲染
