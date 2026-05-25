# HMG 核心概念

本指南解释 HMG 记忆模型背后的核心概念。理解这些概念将帮助你有效地将 HMG 与 AI Agent 配合使用。

## 记忆原子

HMG 中记忆的基本单位是**记忆原子 (Memory Atom)**。每个原子是一个类型化的图谱节点，代表一条知识：

```
┌─────────────────────────────────────────┐
│           记忆原子 (Memory Atom)          │
├─────────────────────────────────────────┤
│  id:        01HKX2ABCDEF... (ULID)      │
│  content:   "我们使用 PostgreSQL..."      │
│  polarity:  positive（肯定）             │
│  epistemic: actual（实际）               │
│  exposure:  visible（可见）              │
│  time:      2026-05-25T10:30:00Z        │
│  modality:  text（文本）                 │
│  category:  decision（决策）             │
│  scope:     my-org/my-repo/main         │
│  source:    architecture-review         │
└─────────────────────────────────────────┘
```

### 内容 (Content)

记忆的原始文本。这是被回忆并呈现给你的 Agent 的内容。

### 极性 (Polarity)

每个记忆都有一个**极性**——关于世界的断言：

| 极性 | 含义 | 示例 |
|---|---|---|
| `positive` | 是这样的 | "我们使用 PostgreSQL 作为主数据库" |
| `negative` | 不是这样的 | "我们不使用 MongoDB 存储用户数据" |
| `conditional` | 在条件下成立 | "当延迟 < 5ms 时我们使用 Redis 缓存" |

### 认知状态 (Epistemic Status)

我们对记忆的确定程度：

| 状态 | 含义 | 示例 |
|---|---|---|
| `possible` | 可能是真的 | "我们可能下季度迁移到 CockroachDB" |
| `actual` | 确认为真 | "我们昨天部署了 v2.1.0 到生产环境" |
| `necessary` | 必须为真（约束） | "所有 API 端点都需要认证" |

### 暴露状态 (Exposure State)

治理可见性——控制谁可以看到记忆以及如何看到：

| 状态 | 含义 |
|---|---|
| `visible` | 正常——出现在所有回忆中 |
| `quarantined` | 在正常回忆中隐藏——审查中 |
| `sealed` | 已隐藏——包含敏感数据，负载不可检索 |
| `tombstoned` | 已删除——仅保留元数据 |
| `lesson` | 提取的教训——敏感记忆的脱敏版本 |

## 修正 (Correction)

与简单的覆盖即忘记系统不同，HMG 使用**只追加修正**。当记忆变得过时或错误时，你不会删除它——你修正它。

```
记忆 A："我们使用 MongoDB"
    │
    ├── 修正：replace → 记忆 B："我们迁移到了 PostgreSQL"
    │                                        │
    │                                        └── Supersedes 链接 → A
    │
    └── 历史保留：A 仍然存在，带有修正谱系
```

### 修正动作

| 动作 | 作用 |
|---|---|
| `negate` | 标记为假——将极性改为否定 |
| `confirm_actual` | 提升确定性——将认知状态改为 `actual` |
| `confirm_necessary` | 提升确定性——将认知状态改为 `necessary` |
| `demote` | 降低确定性——减少置信度 |
| `replace` | 创建一个取代旧原子新原子 |

**关键洞察：** 修正历史永远不会丢失。你总是可以追溯决策为什么改变，之前相信什么，以及谁做了修正。

## 治理 (Governance)

治理控制记忆的可见性和生命周期，特别是敏感记忆。

### 治理动作

| 动作 | 作用 |
|---|---|
| `quarantine` | 从正常回忆中隐藏——待审查 |
| `seal` | 永久隐藏内容——负载不可检索 |
| `tombstone` | 删除——仅保留元数据 |
| `derive_lesson` | 从敏感内容中提取安全教训 |

### 示例：处理泄露的 API 密钥

```
1. Agent 意外记忆："API 密钥是 sk-abc123..."
2. 治理 → quarantine：从回忆中隐藏，审查中
3. 治理 → derive_lesson："意外提交后始终轮换密钥"
4. 治理 → seal：原始内容不可检索，教训保留
```

## 范围 (Scope)

HMG 支持层次化范围，实现分支感知记忆：

```
tenant (my-company)
  └── workspace (platform)
       └── repository (my-app)
            └── branch (main)
```

### 为什么范围对编码 Agent 很重要

在 `feature/auth` 上工作的编码 Agent 不需要来自 `feature/payments` 的记忆。范围确保 Agent 获得**正确的**上下文：

- `main` 分支记忆：架构决策、约定
- `feature/auth` 记忆：认证特定的实现笔记
- 跨分支：共享决策通过层次结构向上冒泡

## 模态 (Modality)

记忆可以有不同的模态——知识被捕获的形式：

| 模态 | 描述 | 示例 |
|---|---|---|
| `text` | 自然语言文本 | "我们选择 Redis 做会话存储" |
| `code` | 代码片段或技术参考 | "`fn main() { ... }`" |
| `dialogue` | 对话摘录 | "用户说：用蓝色主题。Agent：已记录。" |
| `observation` | 观察到的行为或模式 | "测试在 ARM64 上持续失败" |

## 记忆上下文 (Memory Context)

每个记忆操作携带一个**MemoryContext**——统一的元数据，包括：

- **范围**：记忆在层次结构中的位置
- **访问级别**：谁可以看到它
- **策略标签**：适用的治理规则
- **引用**：链接到相关原子、文件或外部资源
- **审计轨迹**：谁创建/修改了它以及何时

## 回忆视图 (Recall Views)

HMG 根据上下文支持不同的记忆视图：

| 视图 | 你看到的 | 用例 |
|---|---|---|
| **Normal** | 可见的、未治理的原子 | 日常 Agent 工作 |
| **Governance** | 已治理的原子（隔离、封存、墓碑） | 管理员审查 |
| **Audit** | 完整历史包括修正和治理转换 | 合规、调试 |

Normal 回忆有意比 Audit 回忆更窄——Agent 获得所需的内容，而不是所有内容。

## Agent 工具输出契约

HMG 的回忆输出遵循结构化契约，专为 Agent 消费设计：

1. **默认紧凑 YAML** ——便于 Agent 解析
2. **渐进式披露** —— `compact` → `summary` → `full` → `debug` 配置
3. **提示和诊断** ——质量信号、知识缺口指示器
4. **对 Agent 上下文窗口安全** ——遵守 token 预算

这不仅是一个 API——它是 Agent 记忆接口应该如何工作的协议。

## 下一步

- [快速开始](getting-started.md) — 安装 HMG 并存储你的第一个记忆
- [API 参考](api-reference.md) — 所有 MCP 工具和 HTTP 端点
- [架构](architecture.md) — HMG 的高层工作原理
