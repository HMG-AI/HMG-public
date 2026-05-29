# アップグレードガイド

このドキュメントでは HMG のアップグレードとエディションの切り替え方法を説明します。

## HMG のアップグレード

### v0.9.x からのアップグレード

```bash
# 最新版をダウンロード
curl -fsSL https://raw.githubusercontent.com/HMG-AI/HMG-public/main/scripts/install.sh | sh

# デーモンを再起動
hmg daemon restart

# バージョンを確認
hmg --version
```

### 手動アップグレード

```bash
# Linux x86_64
curl -L https://github.com/HMG-AI/HMG-public/releases/latest/download/hmg-x86_64-unknown-linux-gnu.tar.gz | tar -xzf - -C ~/.local/bin/

# macOS Apple Silicon
curl -L https://github.com/HMG-AI/HMG-public/releases/latest/download/hmg-aarch64-apple-darwin.tar.gz | tar -xzf - -C ~/.local/bin/
```

### v0.8.x からのアップグレード

v0.9.x にはストレージ形式の変更が含まれています。HMG は自動的に移行します：

```bash
hmg daemon start
# 初回起動時に v0.8 ストレージ形式を自動移行
```

移行は自動的で元に戻せません。事前にバックアップを推奨します：

```bash
cp -r ~/.local/share/hmg ~/.local/share/hmg.bak-v0.8
```

## エディションの切り替え

HMG は単一バイナリを使用します。エディションはライセンスキーで決定されます：

### Community → Developer

```bash
hmg license apply <your-key>
hmg daemon restart
```

即座にアンロック：無制限アトム、セマンティック検索、One-Shot Recall、ドメインパック。

### Developer → Enterprise

```bash
hmg license apply <your-key>
hmg daemon restart
```

即座にアンロック：SSO、RBAC、マルチテナント、監査エクスポート。

### Enterprise → Community

```bash
hmg license remove
hmg daemon restart
```

Community 版の制限に戻ります。データは保持されますが、制限を超えるアトムは読み取り専用になります。

## データ互換性

| From → To | 移行アクション |
|---|---|
| Community → Developer | 移行不要 |
| Community → Enterprise | 移行不要 |
| Developer → Enterprise | 移行不要 |
| v0.8 → v0.9 | 自動移行（初回起動時） |

## 変更履歴

完全な変更履歴は [CHANGELOG.md](https://github.com/HMG-AI/HMG-public/blob/main/CHANGELOG.md) をご覧ください。
