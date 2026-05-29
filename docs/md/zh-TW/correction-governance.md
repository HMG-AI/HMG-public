# 糾錯與治理

HMG 使用**只追加的糾錯與治理模型**。記憶原子從不會被靜默覆蓋。相反，糾錯會建立帶有明確關聯的新原子，治理轉換保留完整歷史。

## 原子生命週期狀態

### 極性（Polarity）

每個原子都有一個表示其真值狀態的極性：

| 極性 | 含義 |
|---|---|
| `positive` | 該原子被斷言為真 |
| `negative` | 該原子已被否定或取代 |
| `neutral` | 資訊性——不包含真值斷言 |

### 認識狀態（Epistemic Status）

| 狀態 | 含義 |
|---|---|
| `claimed` | 未經證實的聲明 |
| `confirmed` | 已透過證據或權威驗證 |
| `deprecated` | 不再相關但不為假 |
| `unknown` | 資訊不足以分類 |

### 治理暴露狀態（Exposure State）

| 狀態 | 可召回 | 含義 |
|---|---|---|
| `normal` | ✅ 正常召回 | 預設狀態 |
| `quarantined` | ❌ 從召回中隱藏 | 因敏感性正在審查 |
| `sealed` | ❌ 隱藏且不可變 | 法律或策略限制 |
| `tombstoned` | ❌ 隱藏，承載資料可選 | 標記為待刪除 |
| `lesson` | ✅ 僅顯示教訓 | 敏感承載資料已替換為安全的教訓摘要 |

## 糾錯流程

糾錯會在原子之間建立明確的 `Supersedes`（取代）邊：

```text
原始原子 (positive)
    │
    ├── negate ──→ 新原子 (negative) + Supersedes 邊
    ├── confirm_actual ──→ 確認原始極性 + Supersedes 邊
    ├── confirm_necessary ──→ 確認原始必要性
    ├── demote ──→ 降低原始認識狀態
    └── replace ──→ 新原子 (positive) + Supersedes 邊 + 新內容
```

### 糾錯動作

| 動作 | 效果 |
|---|---|
| `negate` | 建立一個否定極性的原子，取代目標原子 |
| `confirm_actual` | 確認原子的事實準確性 |
| `confirm_necessary` | 確認原子仍然相關 |
| `demote` | 降低認識狀態（如 confirmed → deprecated） |
| `replace` | 建立包含更新內容的新原子，取代舊原子 |


## 治理流程

治理轉換保護敏感或過時的記憶：

```text
normal → quarantined（審查中）
quarantined → sealed（鎖定，不可變）
quarantined → tombstoned（從召回中移除）
quarantined → normal（已清除，恢復）
任意 → derive_lesson（用安全摘要替換承載資料）
```

### 治理動作

| 動作 | 從 → 到 | 使用場景 |
|---|---|---|
| `quarantine` | normal → quarantined | 疑似敏感內容 |
| `seal` | quarantined → sealed | 法律保全，合規要求 |
| `tombstone` | quarantined → tombstoned | 從召回中刪除 |
| `derive_lesson` | 任意 → lesson | 提取安全教訓，移除敏感承載資料 |


## 快照歷史

每次糾錯和治理動作都會建立一個不可變的快照。
快照保留原子在轉換時刻的狀態。

`memory_history` 工具返回完整鏈路：

```text
原子建立 (v1)
  → 糾錯：negate (v2, Supersedes v1)
    → 治理：tombstone (v2 從正常召回中隱藏)
      → 衍生教訓 (v3, 安全摘要在召回中可見)
```

## 召回檢視

HMG 支援三種具有不同可見性規則的召回檢視：

| 檢視 | 顯示內容 | 使用場景 |
|---|---|---|
| `normal` | 僅活躍原子（正極性，normal 暴露狀態） | 日常 agent 使用 |
| `governance` | + 被隔離/密封的原子 | 合規審查 |
| `audit` | + 所有原子包括已墓碑化的，完整糾錯鏈 | 取證調查 |

正常召回有意排除已治理的承載資料。審計召回顯示所有內容以確保可究責性。
