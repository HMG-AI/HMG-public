# よくある質問

## 一般

### HMG とは何ですか？

HMG（Holographic Memory Graph）は AI エージェント向けの永続記憶システムです。構造化された記憶ストレージ、インテリジェントなリコール、修正追跡、ガバナンス機能を提供します — ローカルサービスとして実行され、MCP プロトコルを通じてエージェントと統合されます。

### なぜ AI エージェントに永続記憶が必要なのですか？

記憶のないエージェントは、毎回のセッションですべてを忘れます。同じミスを繰り返し、以前のアーキテクチャ決定を忘れ、プロジェクト間で一貫性を保てません。HMG はエージェントに時間とともに改善される永続的な「作業記憶」を与えます。

### HMG は安全ですか？

はい。Community Edition は：
- **ゼロの外向きネットワーク接続** — データがマシンから出ることはありません
- `localhost` にバインド — ネットワークに露出しない
- ユーザーのみ権限のファイルストレージを使用
- テレメトリや分析なし

詳細は [セキュリティ](security.md) をご覧ください。

### どのプラットフォームがサポートされていますか？

- Linux（x86_64、ARM64）
- macOS（Intel、Apple Silicon）
- Windows（WSL または GNU ツールチェーン経由）

## インストールと設定

### インストール方法は？

```bash
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
```

詳細は [クイックスタート](getting-started.md) をご覧ください。

### エージェントを接続するには？

```bash
hmg init --agent cursor    # Cursor
hmg init --agent codex     # Claude Code / Codex
hmg init --agent pi        # Pi
hmg init --agent windsurf  # Windsurf
hmg init --agent aider     # Aider
```

### ストレージ場所をカスタマイズできますか？

はい。`HMG_STORE_PATH` 環境変数を設定してください：

```bash
export HMG_STORE_PATH=/custom/path/hmg-store
hmg daemon start
```

## 使用方法

### 記憶はどのように整理されていますか？

記憶は**アトム**として保存されます — 型、スコープ、メタデータを持つ構造化された情報単位。アトムはグラフ内のエッジで相互に接続されています（置換、派生、関連）。

詳細は [コンセプト](concepts.md) をご覧ください。

### 修正はどのように機能しますか？

HMG は記憶を上書きしません。修正は新しいアトムを作成し、`Supersedes` エッジで元のアトムにリンクします。否定、確認、降格、置換をサポートしています。

詳細は [修正とガバナンス](correction-governance.md) をご覧ください。

### ガバナンスとは何ですか？

ガバナンスは機密記憶を保護します。アクションには以下が含まれます：隔離（レビュー中）、封印（ロック）、トゥームストーン（削除）、教訓の派生（安全な要約の抽出）。

詳細は [修正とガバナンス](correction-governance.md) をご覧ください。

### 記憶を検索できますか？

はい。Community Edition は One-Shot Recall (P1-P9) をサポートします。Developer Edition は数量制限を解除し、自動統合を追加します。

## エディション

### Community、Developer、Enterprise の違いは？

| 機能 | Community | Developer | Enterprise |
|---|---|---|---|
| 記憶とリコール | ✅ | ✅ | ✅ |
| 修正とガバナンス | ✅ | ✅ | ✅ |
| MCP プロトコル | ✅ | ✅ | ✅ |
| アトム数 | 100,000 | 無制限 | 無制限 |
| セマンティック検索 | ❌ | ✅ | ✅ |
| One-Shot Recall | ✅ | ✅ | ✅ |
| ドメインパック | ❌ | ✅ | 全部 |
| SSO / RBAC | ❌ | ❌ | ✅ |
| 価格 | 無料 | サブスクリプション | お問い合わせ |

### Developer にアップグレードするには？

```bash
hmg license apply <your-key>
hmg daemon restart
```

再インストール不要 — 同じバイナリです。

詳細は [アップグレードガイド](upgrade.md) をご覧ください。

## トラブルシューティング

### エージェントが HMG ツールを見つけられない

1. デーモンが実行中か確認：`hmg daemon status`
2. エージェント設定を確認：`hmg doctor`
3. エージェント/IDE を再起動

### `hmg daemon start` が失敗する

1. ポートが使用されていないか確認：`lsof -i :7654`
2. ストレージパスの権限を確認
3. `hmg doctor` を実行して診断

### リコールが正しくない結果を返す

1. スコープフィールドが正しいことを確認（repository、branch）
2. `response_profile: "debug"` を試して診断情報を確認
3. 古い記憶に修正が必要かどうかを確認
