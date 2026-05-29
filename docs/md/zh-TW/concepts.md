# HMG 概念

本文檔解釋 HMG 的核心概念：記憶原子、範圍、糾錯、治理和召回。

## 記憶原子

記憶原子是 HMG 中的基本資料單位。每個原子是一則持久化的資訊片段，具有結構化元資料。

### 原子結構

```
Atom {
  id:          ULID          // 唯一識別符
  text:        String        // 實際記憶內容
  modality:    text|code|dialogue|observation
  source:      String        // 來源標籤
  polarity:    positive|negative|neutral
  epistemic:   claimed|confirmed|deprecated|unknown
  exposure:    normal|quarantined|sealed|tombstoned|lesson
  scope: {
    tenant_id, workspace, repository, branch, task_id, decision_id
  }
  timestamps:  created_at, updated_at
}
```

### 模態（Modality）

| 模態 | 用途 |
|---|---|
| `text` | 一般文字記憶（決策、筆記、觀察） |
| `code` | 程式碼片段或架構決策 |
| `dialogue` | 對話記錄或互動 |
| `observation` | 被動觀察的行為模式 |

## 範圍（Scope）

範圍定義記憶的上下文邊界。HMG 使用分層範圍模型：

```
tenant_id         // 組織或帳戶
  └── workspace   // 專案群或團隊
       └── repository  // 程式碼庫
            └── branch  // 分支
                 ├── task_id     // 任務
                 └── decision_id // 決策
```

### 範圍行為

- **精確匹配優先**：如果召回時提供了 `branch`，HMG 優先返回該分支的記憶
- **向上回退**：如果分支層沒有結果，回退到 repository、workspace、tenant 層
- **空範圍**：未提供範圍的記憶被視為全域記憶

## 糾錯生命週期

HMG 從不覆蓋記憶。相反，糾錯建立新原子並透過邊連接：

### 糾錯動作

| 動作 | 效果 |
|---|---|
| `negate` | 建立否定極性原子，取代目標 |
| `confirm_actual` | 確認事實準確性 |
| `confirm_necessary` | 確認持續相關性 |
| `demote` | 降低認識狀態 |
| `replace` | 以新內容取代舊原子 |

所有糾錯都會建立不可變的快照歷史。

詳見 [糾錯與治理](correction-governance.md)。

## 治理生命週期

治理保護敏感或過時的記憶：

```
normal → quarantined → sealed     （鎖定）
                    → tombstoned  （刪除）
                    → normal      （恢復）
任意   → lesson                   （提取教訓）
```

治理後的原子從正常召回中隱藏，但保留在審計追蹤中。

詳見 [糾錯與治理](correction-governance.md)。

## 召回（Recall）

召回從記憶儲存中檢索相關記憶。

### 召回流程

```
查詢 → 解析意圖 → 索引檢索 → 排名 → 範圍過濾 → 圖遍歷投影 → 格式化輸出
```

### 回應格式

| 格式 | 用途 |
|---|---|
| `compact` | Agent 日常使用（預設） |
| `summary` | 人類可讀的摘要 |
| `full` | 完整細節 |
| `debug` | 包含診斷資訊 |

### 語義搜尋

Community Edition 支援關鍵詞搜尋。Developer Edition 增加向量語義搜尋。

## 圖模型

原子透過型別化的邊相互連接：

| 邊型別 | 含義 |
|---|---|
| `Supersedes` | 糾錯/取代關係 |
| `DerivesFrom` | 衍生/學習關係 |
| `RelatesTo` | 一般關聯 |
| `ScopedBy` | 範圍歸屬 |

圖遍歷允許召回操作投射相關記憶，而不僅是直接匹配的結果。

## Domain Packs

Domain Packs 是預定義的記憶範本和範圍策略：

- **Software Engineering**：程式碼庫、分支、任務的範圍模型
- 自定義 Domain Packs（Developer/Enterprise）

使用 `domain_pack_id` 參數啟用。

## 下一步

- [架構](architecture.md) — HMG 的高層運作原理
- [API 參考](api-reference.md) — 所有 MCP 工具和 HTTP 端點
- [糾錯與治理](correction-governance.md) — 詳細的糾錯和治理流程
