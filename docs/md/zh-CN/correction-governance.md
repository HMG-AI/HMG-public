# 纠错与治理

HMG 使用**只追加的纠错与治理模型**。记忆原子从不会被静默覆盖。相反，纠错会创建带有显式关系的新原子，治理转换保留完整历史。

## 原子生命周期状态

### 极性（Polarity）

每个原子都有一个表示其真值状态的极性：

| 极性 | 含义 |
|---|---|
| `positive` | 该原子被断言为真 |
| `negative` | 该原子已被否定或取代 |
| `neutral` | 信息性——不包含真值断言 |

### 认识状态（Epistemic Status）

| 状态 | 含义 |
|---|---|
| `claimed` | 未经证实的声明 |
| `confirmed` | 已通过证据或权威验证 |
| `deprecated` | 不再相关但不为假 |
| `unknown` | 信息不足以分类 |

### 治理暴露状态（Exposure State）

| 状态 | 可召回 | 含义 |
|---|---|---|
| `normal` | ✅ 正常召回 | 默认状态 |
| `quarantined` | ❌ 从召回中隐藏 | 因敏感性正在审查 |
| `sealed` | ❌ 隐藏且不可变 | 法律或策略限制 |
| `tombstoned` | ❌ 隐藏，负载可选 | 标记为待删除 |
| `lesson` | ✅ 仅显示教训 | 敏感负载已替换为安全的教训摘要 |

## 纠错流程

纠错会在原子之间创建显式的 `Supersedes`（取代）边：

```text
原始原子 (positive)
    │
    ├── negate ──→ 新原子 (negative) + Supersedes 边
    ├── confirm_actual ──→ 确认原始极性 + Supersedes 边
    ├── confirm_necessary ──→ 确认原始必要性
    ├── demote ──→ 降低原始认识状态
    └── replace ──→ 新原子 (positive) + Supersedes 边 + 新内容
```

### 纠错动作

| 动作 | 效果 |
|---|---|
| `negate` | 创建一个否定极性的原子，取代目标原子 |
| `confirm_actual` | 确认原子的事实准确性 |
| `confirm_necessary` | 确认原子仍然相关 |
| `demote` | 降低认识状态（如 confirmed → deprecated） |
| `replace` | 创建包含更新内容的新原子，取代旧原子 |

![Agent 调用 memory_correct (replace)](../img/agent-correct.png)

## 治理流程

治理转换保护敏感或过时的记忆：

```text
normal → quarantined（审查中）
quarantined → sealed（锁定，不可变）
quarantined → tombstoned（从召回中移除）
quarantined → normal（已清除，恢复）
任意 → derive_lesson（用安全摘要替换负载）
```

### 治理动作

| 动作 | 从 → 到 | 使用场景 |
|---|---|---|
| `quarantine` | normal → quarantined | 疑似敏感内容 |
| `seal` | quarantined → sealed | 法律保全，合规要求 |
| `tombstone` | quarantined → tombstoned | 从召回中删除 |
| `derive_lesson` | 任意 → lesson | 提取安全教训，移除敏感负载 |

![Agent 调用 memory_govern (quarantine)](../img/agent-govern.png)

## 快照历史

每次纠错和治理动作都会创建一个不可变的快照。
快照保留原子在转换时刻的状态。

`memory_history` 工具返回完整链路：

```text
原子创建 (v1)
  → 纠错：negate (v2, Supersedes v1)
    → 治理：tombstone (v2 从正常召回中隐藏)
      → 派生教训 (v3, 安全摘要在召回中可见)
```

## 召回视图

HMG 支持三种具有不同可见性规则的召回视图：

| 视图 | 显示内容 | 使用场景 |
|---|---|---|
| `normal` | 仅活跃原子（正极性，normal 暴露状态） | 日常 agent 使用 |
| `governance` | + 被隔离/密封的原子 | 合规审查 |
| `audit` | + 所有原子包括已墓碑化的，完整纠错链 | 取证调查 |

正常召回有意排除已治理的负载。审计召回显示所有内容以确保可问责性。
