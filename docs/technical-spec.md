# SmartCoder 技术规格说明书

## 1. 运行模式

### 1.1 Host 模式（默认）
- SmartCoder 在宿主机运行
- 命令通过 `devcontainer exec` 执行

### 1.2 In-Container 模式
- SmartCoder 运行在 DevContainer 内
- 文件系统与依赖完全一致

---

## 2. 执行模型

### 2.1 Run
- 一次完整任务执行
- 对应一个 Git 分支：`smartcoder/run/<run_id>`

### 2.2 Step
- Run 中的一个执行单元
- 原子、可回放、可分叉

#### Step 最小字段
```json
{
  "step_id": "3",
  "parent_step_id": "2",
  "intent": "verify",
  "repo_commit": "abc123",
  "container_ref": "sha256:...",
  "actions": [],
  "artifacts": [],
  "summary": ""
}

