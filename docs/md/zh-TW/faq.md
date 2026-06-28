# 常見問題

## 一般

### HMG 是什麼？

HMG（Holographic Memory Graph）是 AI agent 的持久記憶系統。它提供結構化的記憶儲存、智慧召回、糾錯追蹤和治理能力——作為本地服務執行，透過 MCP 協定與您的 agent 整合。

### 為什麼 AI agent 需要持久記憶？

沒有記憶的 agent 會在每次工作階段遺忘一切。它們會重複犯同樣的錯誤、忘記先前的架構決策、無法跨專案保持一致性。HMG 給 agent 一個持久的「工作記憶」，隨著時間改進。

### HMG 安全嗎？

是的。Community Edition：
- **零對外網路連線**——資料永遠不會離開您的機器
- 綁定到 `localhost`——不暴露到網路
- 使用僅使用者權限的檔案儲存
- 無遙測或分析

詳見 [安全](security.md)。

### 支援哪些平台？

- Linux（x86_64、ARM64）
- macOS（Intel、Apple Silicon）
- Windows（透過 WSL 或 GNU 工具鏈）

## 安裝與設定

### 如何安裝？

```bash
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
```

詳見 [快速開始](getting-started.md)。

### 如何連接我的 agent？

```bash
hmg init --agent cursor    # Cursor
hmg init --agent codex     # Claude Code / Codex
hmg init --agent pi        # Pi
hmg init --agent windsurf  # Windsurf
hmg init --agent aider     # Aider
```

### 我可以自訂儲存位置嗎？

是的。設定 `HMG_STORE_PATH` 環境變數：

```bash
export HMG_STORE_PATH=/custom/path/hmg-store
hmg daemon start
```

## 使用

### 記憶如何組織？

記憶以**原子**的形式儲存——結構化的資訊單位，具有型別、範圍和元資料。原子透過圖譜中的邊相互連接（取代、衍生、關聯）。

詳見 [概念](concepts.md)。

### 糾錯如何運作？

HMG 從不覆蓋記憶。糾錯建立新原子並透過 `Supersedes` 邊連接到原始原子。支援：否定、確認、降權和取代。

詳見 [糾錯與治理](correction-governance.md)。

### 什麼是治理？

治理保護敏感記憶。動作包括：隔離（審查中）、密封（鎖定）、墓碑化（刪除）和衍生教訓（提取安全摘要）。

詳見 [糾錯與治理](correction-governance.md)。

### 記憶可以搜尋嗎？

是的。Community Edition 支援關鍵詞搜尋。Developer Edition 增加向量語義搜尋以獲得更好的召回品質。

## 版本

### Community、Developer 和 Enterprise 有什麼區別？

| 功能 | Community | Developer | Enterprise |
|---|---|---|---|
| 記憶和召回 | ✅ | ✅ | ✅ |
| 糾錯和治理 | ✅ | ✅ | ✅ |
| MCP 協定 | ✅ | ✅ | ✅ |
| 原子數量 | 100,000 | 無限 | 無限 |
| 語義搜尋 | ❌ | ✅ | ✅ |
| One-Shot Recall | ✅ | ✅ | ✅ |
| Domain Packs | ❌ | ✅ | 全部 |
| SSO / RBAC | ❌ | ❌ | ✅ |
| 價格 | 免費 | 訂閱制 | 聯繫我們 |

### 如何升級到 Developer？

```bash
hmg license apply <your-key>
hmg daemon restart
```

無需重新安裝——同一個二進位。

詳見 [升級指南](upgrade.md)。

## 疑難排解

### Agent 找不到 HMG 工具

1. 確認守護程式正在執行：`hmg daemon status`
2. 確認 agent 設定：`hmg doctor`
3. 重啟您的 agent/IDE

### `hmg daemon start` 失敗

1. 檢查連接埠是否被佔用：`lsof -i :7654`
2. 檢查儲存路徑權限
3. 執行 `hmg doctor` 進行診斷

### 召回返回不正確的結果

1. 確認範圍欄位正確（repository、branch）
2. 嘗試 `response_profile: "debug"` 檢視診斷資訊
3. 檢查是否有過時的記憶需要糾錯
