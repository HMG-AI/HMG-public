# 升級指南

本文檔說明如何升級 HMG 和切換版本。

## 升級 HMG

### 從 v0.9.x 升級

```bash
# 下載最新版本
curl -fsSL https://raw.githubusercontent.com/HMG-AI/HMG-public/main/scripts/install.sh | sh

# 重啟守護程式
hmg daemon restart

# 驗證版本
hmg --version
```

### 手動升級

```bash
# Linux x86_64
curl -L https://github.com/HMG-AI/HMG-public/releases/latest/download/hmg-x86_64-unknown-linux-gnu.tar.gz | tar -xzf - -C ~/.local/bin/

# macOS Apple Silicon
curl -L https://github.com/HMG-AI/HMG-public/releases/latest/download/hmg-aarch64-apple-darwin.tar.gz | tar -xzf - -C ~/.local/bin/
```

### 從 v0.8.x 升級

v0.9.x 包含儲存格式變更。HMG 會自動遷移：

```bash
hmg daemon start
# 首次啟動時自動遷移 v0.8 儲存格式
```

遷移是自動且不可逆的。建議先備份：

```bash
cp -r ~/.local/share/hmg ~/.local/share/hmg.bak-v0.8
```

## 切換版本

HMG 使用單一二進位。版本由 license key 決定：

### Community → Developer

```bash
hmg license apply <your-key>
hmg daemon restart
```

立即解鎖：無限原子、語義搜尋、One-Shot Recall、Domain Packs。

### Developer → Enterprise

```bash
hmg license apply <your-key>
hmg daemon restart
```

立即解鎖：SSO、RBAC、多租戶、審計匯出。

### Enterprise → Community

```bash
hmg license remove
hmg daemon restart
```

回到 Community 版限制。資料保留，但超過限制的原子變為唯讀。

## 資料相容性

| 從 → 到 | 遷移動作 |
|---|---|
| Community → Developer | 無需遷移 |
| Community → Enterprise | 無需遷移 |
| Developer → Enterprise | 無需遷移 |
| v0.8 → v0.9 | 自動遷移（首次啟動） |

## 變更日誌

完整變更日誌請見 [CHANGELOG.md](https://github.com/HMG-AI/HMG-public/blob/main/CHANGELOG.md)。
