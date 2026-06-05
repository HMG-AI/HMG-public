# 贡献 Agent 适配器

本指南说明社区贡献者如何通过 [HMG-public](https://github.com/HMG-AI/HMG-public) 开源仓库为 HMG 生态接入新的 AI 编码 Agent。

## 概览

HMG 有两类 Agent 集成方式：

| 类别 | 谁来构建 | 代码位置 | 用户体验 |
|------|---------|---------|---------|
| **内置适配器** | HMG 核心团队（私有仓库） | `hmg-server` Rust 源码 | `hmg init --agent <name>` 一条命令 |
| **社区适配器** | 任何人（公开仓库） | `examples/agent-adapter/<name>/` | 复制配置 + 提示词，按文档操作 |

作为社区贡献者，你创建的是**社区适配器**。你**不需要**访问 HMG 的专有源码。集成完全是配置驱动的：MCP 配置、系统提示词、文档。

如果你的适配器获得了广泛使用，可以通过 GitHub Issue 申请升级为内置适配器——HMG 核心团队会在下一个版本中实现 Rust 适配器。

## 前置知识

### HMG 集成接口

HMG 暴露三种集成接口。根据你的 Agent 能力选择：

| 接口 | 适用场景 | 工作量 | 参考文档 |
|------|---------|--------|---------|
| **MCP**（Model Context Protocol） | 支持标准 MCP 工具协议的 Agent | ~5 分钟 | [`mcp/schemas/tools.json`](../../mcp/schemas/tools.json) |
| **HTTP REST API** | 有 HTTP 客户端但不支持 MCP 的 Agent | ~30 分钟 | [`openapi/hmg-server.yaml`](../../openapi/hmg-server.yaml) |
| **SDK**（Python / TypeScript） | 有插件/扩展系统的 Agent | ~1–2 小时 | [`sdk-python/`](../../sdk-python/)、[`sdk-ts/`](../../sdk-ts/) |

### 核心记忆生命周期

无论使用哪种接口，推荐的 Agent 记忆生命周期是：

```
会话开始 → agent_brief（获取上下文）
     │
     ├── 风险编辑前 → recall（检查相关决策）
     ├── 做出决策 → memorize（持久化）
     ├── 发现过时信息 → correct（更新）
     │
会话结束 → handoff（为下次会话留下摘要）
```

| 时机 | 工具 / 端点 | 说明 |
|------|------------|------|
| 会话开始 | `memory_agent_brief` 或 `POST /api/agent_brief` | 检索上下文、决策、风险 |
| 风险编辑前 | `memory_recall` 或 `POST /api/recall` | 检查受影响文件/符号的先前决策 |
| 做出决策 | `memory_memorize` 或 `POST /api/memorize` | 存储架构选择、根因、约束 |
| 发现过时信息 | `memory_correct` 或 `POST /api/correct` | 事实变化时更新 |
| 会话结束 | `memory_handoff` 或 `POST /api/handoff` | 持久化摘要、验证结果、下一步 |

### Scope 约定

对于编码任务，使用带分支感知的 scope 和 `software-engineering` 域包：

```json
{
  "domain_pack_id": "software-engineering",
  "context": {
    "scope": {
      "tenant_id": "tenant-acme",
      "path": [
        {"kind": "workspace", "id": "platform"},
        {"kind": "repository", "id": "my-project"},
        {"kind": "branch", "id": "feature/auth"}
      ]
    }
  }
}
```

## 分步贡献流程

### 第 1 步：Fork 并 Clone

```bash
# 在 GitHub 上 Fork https://github.com/HMG-AI/HMG-public
git clone https://github.com/<你的用户名>/HMG-public.git
cd HMG-public
git checkout -b add-<agent名称>-adapter
```

### 第 2 步：创建适配器目录

```bash
mkdir -p examples/agent-adapter/<agent名称>/
```

使用小写、连字符分隔的名称（如 `hermes`、`aider`、`roo-code`）。

### 第 3 步：编写必要文件

每个适配器目录**必须**包含以下四个文件：

#### 3a. `<agent名称>-mcp.json` — MCP 配置模板

告诉 Agent 如何连接 HMG 的 MCP 服务配置：

```json
{
  "mcpServers": {
    "hmg": {
      "command": "hmg-server",
      "args": ["~/.local/share/hmg/stores/default"],
      "env": {
        "HMG_PROVIDER_BACKEND": "local",
        "HMG_CONSOLIDATION_SCHEDULER": "embedded"
      }
    }
  }
}
```

根据你的 Agent 实际读取的配置格式调整结构。有些 Agent 使用不同的顶层键、嵌套配置或不同的文件格式（YAML、TOML）。在 README 中记录确切的位置和格式。

#### 3b. `hmg-<agent名称>-prompt.md` — 系统提示词片段

告诉 Agent 的 LLM 何时以及如何使用 HMG 工具的简洁提示：

```markdown
# HMG Memory — <Agent名称> System Prompt

When HMG MCP tools are available, use them as durable long-term memory:

## When to use HMG
- **At task start**: Call `memory_agent_brief` to retrieve context from prior sessions.
- **Before risky edits**: Call `memory_recall` to check if prior decisions affect the change.
- **When durable facts appear**: Call `memory_memorize` for decisions, root causes, constraints.
- **When memory is stale**: Call `memory_correct` instead of writing conflicting facts.
- **At task end**: Call `memory_handoff` with what changed, why, and next steps.

## When NOT to use HMG
- Do not store ephemeral command output, secrets, tokens, or raw credentials.
- Do not call HMG for trivial operations that don't benefit from persistence.

## Scope
Prefer branch-aware scope for coding tasks:
- `domain_pack_id: "software-engineering"`
- Set `tenant_id`, `workspace`, `repository`, `branch` from the current project context.
```

根据你的 Agent 提示词约定调整措辞和格式。有些 Agent 使用 XML 标签，有些使用 markdown，有些有特定的系统指令文件位置。

#### 3c. `example-session.md` — 端到端使用示例

展示一个在生命周期各节点使用 HMG 的真实 Agent 会话：

```markdown
# Example: <Agent名称> Session with HMG Memory

## Session Start

The agent calls `memory_agent_brief`:

→ memory_agent_brief({
    query: "current task status and recent decisions",
    domain_pack_id: "software-engineering"
  })

← Brief:
  - Last session: implemented JWT auth middleware
  - Decision: use RS256 over HS256 for asymmetric key verification
  - Risk: token revocation not yet implemented
  - Next step: add token blacklist endpoint

## During Task — Storing a Decision

→ memory_memorize({
    content: "Decided to use Redis for token blacklist with TTL matching JWT expiry",
    source: "architecture-review",
    domain_pack_id: "software-engineering"
  })

← Stored atoms: [01KSM3ABC...]

## Before Risky Edit — Recalling Context

→ memory_recall({
    query: "auth middleware JWT token decisions",
    domain_pack_id: "software-engineering"
  })

← Recall:
  [0.92] Decided to use Redis for token blacklist
  [0.87] Use RS256 over HS256
  [0.71] Token revocation not yet implemented — risk

## Session End — Handoff

→ memory_handoff({
    summary: "Implemented token blacklist endpoint using Redis. Tests pass (12/12).
              Remaining: integrate blacklist check in auth middleware."
  })
```

#### 3d. `README.md` — 集成指南

其他用户用来安装你适配器的主要文档：

```markdown
# <Agent名称> × HMG Integration

## Prerequisites

- HMG installed (`curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh`)
- HMG daemon running (`hmg daemon start`)

## Setup

### 1. Configure <Agent>

Copy `<agent名称>-mcp.json` to <agent>'s config directory:

```bash
cp <agent名称>-mcp.json ~/.config/<agent名称>/mcp-servers.json
```

### 2. Add System Prompt

Append `hmg-<agent名称>-prompt.md` to your <agent> system prompt, or place it in:

```
<path-to-agent-prompts-directory>/
```

### 3. Verify

```bash
hmg doctor
```

## Files

| File | Purpose |
|------|---------|
| [`<agent名称>-mcp.json`](<agent名称>-mcp.json) | MCP server config |
| [`hmg-<agent名称>-prompt.md`](hmg-<agent名称>-prompt.md) | System prompt fragment |
| [`example-session.md`](example-session.md) | Example session walkthrough |
```

### 第 4 步：（可选）基于 SDK 的集成

如果你的 Agent 有插件/扩展系统但不原生支持 MCP，你可能需要用 SDK 写一个薄集成层：

**Python：**
```python
from hmg import HmgClient, software_engineering_context

client = HmgClient(base_url="http://localhost:3000")

# 会话开始
brief = client.recall({"query": "current task", "domain_pack_id": "software-engineering"})

# 存储决策
client.memorize({
    "content": "Use event-sourcing for audit log",
    "source": "architecture-review",
    "domain_pack_id": "software-engineering",
    "context": software_engineering_context("tenant-acme", "platform", "my-repo", "main")
})
```

**TypeScript：**
```typescript
import { HmgClient } from "@hmg_ai/sdk-ts";

const client = new HmgClient({ baseUrl: "http://localhost:3000" });

// 会话开始
await client.recall({ query: "current task", domainPackId: "software-engineering" });

// 存储决策
await client.memorize({
  content: "Chose Redis for session caching",
  source: "architecture-review",
  domainPackId: "software-engineering",
});
```

将插件代码和配置文件一起放在你的适配器目录中。

### 第 5 步：提交 PR

```bash
git add examples/agent-adapter/<agent名称>/
git commit -s -m "feat: add <agent名称> agent adapter"
git push origin add-<agent名称>-adapter
# 向 HMG-public/main 发起 Pull Request
```

#### PR 检查清单

- [ ] 所有 commit 已 DCO sign-off（`git commit -s`）
- [ ] 代码或注释中不包含专有算法细节
- [ ] 不包含真实用户数据、密钥或内部端点
- [ ] README 清楚地说明了安装步骤
- [ ] MCP 配置正确（用 `hmg doctor` 验证）
- [ ] 系统提示词遵循推荐的生命周期模式
- [ ] 示例会话展示了全部五个生命周期节点

## 参考架构

```
┌─────────────────────────────────────────────┐
│  你的 Agent                                 │
│                                             │
│  ┌──────────────┐    ┌──────────────────┐   │
│  │ 会话管理器    │───▶│ hmg_agent_brief  │   │  ← 任务开始
│  │              │    └──────────────────┘   │
│  │              │    ┌──────────────────┐   │
│  │              │───▶│ hmg_recall       │   │  ← 风险编辑前
│  │              │    └──────────────────┘   │
│  │              │    ┌──────────────────┐   │
│  │              │───▶│ hmg_memorize     │   │  ← 持久事实
│  │              │    └──────────────────┘   │
│  │              │    ┌──────────────────┐   │
│  │              │───▶│ hmg_correct      │   │  ← 过时记忆
│  │              │    └──────────────────┘   │
│  │              │    ┌──────────────────┐   │
│  │              │───▶│ hmg_handoff      │   │  ← 任务结束
│  └──────────────┘    └──────────────────┘   │
│                                             │
└─────────────────────┬───────────────────────┘
                      │ MCP / HTTP / SDK
                      ▼
              ┌──────────────┐
              │  hmg-server  │
              │  (端口 3000) │
              └──────────────┘
```

## 升级为内置适配器

如果你的社区适配器获得了显著的用户采用：

1. 在 [GitHub Issues](https://github.com/HMG-AI/HMG-public/issues) 上开一个标签为 `adapter-promotion` 的 Issue
2. 附上：下载/使用数据、社区反馈、已知边界情况
3. HMG 核心团队将评估，如果批准，会在下一个版本中实现内置适配器

内置适配器获得的能力：
- `hmg init --agent <name>` 一条命令安装
- `hmg doctor --agent <name>` 自动诊断
- `hmg setup` 自动检测
- `hmg doctor --fix` 自动修复

## 现有示例

| 适配器 | 路径 |
|--------|------|
| Hermes | [`examples/agent-adapter/hermes/`](../../examples/agent-adapter/hermes/) |

使用任何现有适配器作为你贡献的模板。

## 问题？

- 💬 [GitHub Discussions](https://github.com/HMG-AI/HMG-public/discussions) — 集成问题
- 🐛 [GitHub Issues](https://github.com/HMG-AI/HMG-public/issues) — Bug 和功能请求
- 📧 monkseekee@gmail.com — 安全和私密咨询
