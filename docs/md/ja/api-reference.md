# HMG API リファレンス — Community Edition

HTTP ベース URL：`http://localhost:7654`（デフォルト）。

## MCP ツール

HMG は Community Edition で8つの MCP ツールを公開します。すべてのツールはブランチ対応記憶のためのスコープフィールドを含むオプションの `context` オブジェクトを受け入れます。

### `memory_memorize`

永続的な情報を保存します。

```json
{
  "content": "記憶するテキスト",
  "source": "オプションのソースラベル",
  "modality": "text",
  "context": {
    "tenant_id": "tenant-acme",
    "workspace": "platform",
    "repository": "my-repo",
    "branch": "main"
  }
}
```

レスポンス：

```json
{
  "success": true,
  "added_atom_count": 1,
  "added_atoms": ["01KSEFSC29QX8RQ78N3110ATC9"],
  "snapshot_version": 8
}
```


### `memory_recall`

関連する記憶を検索します。

```json
{
  "query": "どのデータベースを選びましたか？",
  "max_results": 10,
  "response_profile": "compact",
  "output_format": "yaml"
}
```

レスポンスプロファイル：`compact`（デフォルト）、`summary`、`full`、`debug`。

出力形式：`yaml`（デフォルト）、`markdown`、`json`。


### `memory_correct`

アトムを修正、否定、確認、降格、または置換します。

```json
{
  "target_atom": "01KSEFSC29QX8RQ78N3110ATC9",
  "action": "replace",
  "reason": "シンプルさのため SQLite に変更",
  "new_content": "決定：ユーザーデータに SQLite を使用。"
}
```

アクション：`negate`、`confirm_actual`、`confirm_necessary`、`demote`、`replace`。


### `memory_govern`

ガバナンスを適用：隔離、封印、トゥームストーン、または教訓の派生。

```json
{
  "target_atom": "01KSEFSC29QX8RQ78N3110ATC9",
  "action": "tombstone",
  "reason": "機密性の高い API キー参照を含む"
}
```

アクション：`quarantine`、`seal`、`tombstone`、`derive_lesson`。


### `memory_history`

アトムの修正とガバナンス履歴を検査します。

```json
{
  "atom_id": "01KSEFSC29QX8RQ78N3110ATC9"
}
```

### `memory_handoff`

クロスセッションハンドオフサマリーを書きます。

```json
{
  "summary": "X を実装、Y テストで検証、残リスク：Z。",
  "source": "session-end"
}
```

### `memory_agent_brief`

タスク開始時にコンパクトなブランチ対応ブリーフを取得します。

```json
{
  "query": "現在のコーディングタスクのコンテキスト",
  "brief_format": "compact_yaml"
}
```


### `memory_stats`

グラフとインデックスの統計情報を取得します。

```json
{}
```


## HTTP API

### `POST /api/memorize`

`memory_memorize` と同じパラメータ、JSON ボディとして。

### `POST /api/recall`

`memory_recall` と同じパラメータ、JSON ボディとして。

### `POST /api/correct`

`memory_correct` と同じパラメータ、JSON ボディとして。

### `POST /api/governance/{action}`

アクション：`quarantine`、`seal`、`tombstone`、`derive_lesson`。

### `GET /api/stats`

アトム数、エッジ数、インデックス統計を返します。

### `GET /api/graph/export`

完全な記憶グラフを JSON でエクスポートします。

### `GET /api/snapshot/{atom_id}`

特定のアトムのスナップショット履歴を返します。

### `GET /api/audit/{atom_id}`

完全な監査証跡（修正 + ガバナンス履歴）を返します。

## スコープ（ブランチ対応記憶）

HMG はコーディングエージェント向けの階層スコープをサポートします：

```text
tenant_id → workspace → repository → branch
                                        ↳ task_id
                                        ↳ decision_id
```

スコープフィールドが提供されると、リコールは自動的にブランチ固有の記憶を優先し、より広範なワークスペースやテナントの記憶より上位にランク付けします。

## レスポンス形式

すべてのレスポンスは一貫した構造に従います：

```json
{
  "success": true,
  "snapshot_version": 905,
  "..."
}
```

エラーレスポンス：

```json
{
  "success": false,
  "error": "エラーの説明"
}
```
