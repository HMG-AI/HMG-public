# HMG コンセプト

このドキュメントは HMG のコアコンセプトを説明します：記憶アトム、スコープ、修正、ガバナンス、リコール。

## 記憶アトム

記憶アトムは HMG の基本データ単位です。各アトムは構造化されたメタデータを持つ永続的な情報の断片です。

### アトム構造

```
Atom {
  id:          ULID          // 一意識別子
  text:        String        // 実際の記憶内容
  modality:    text|code|dialogue|observation
  source:      String        // ソースラベル
  polarity:    positive|negative|neutral
  epistemic:   claimed|confirmed|deprecated|unknown
  exposure:    normal|quarantined|sealed|tombstoned|lesson
  scope: {
    tenant_id, workspace, repository, branch, task_id, decision_id
  }
  timestamps:  created_at, updated_at
}
```

### モダリティ

| モダリティ | 用途 |
|---|---|
| `text` | 一般テキスト記憶（決定、メモ、観察） |
| `code` | コードスニペットやアーキテクチャ決定 |
| `dialogue` | 会話記録やインタラクション |
| `observation` | 受動的に観察された行動パターン |

## スコープ

スコープは記憶のコンテキスト境界を定義します。HMG は階層スコープモデルを使用します：

```
tenant_id         // 組織またはアカウント
  └── workspace   // プロジェクトグループまたはチーム
       └── repository  // コードベース
            └── branch  // ブランチ
                 ├── task_id     // タスク
                 └── decision_id // 決定
```

### スコープの動作

- **正確なマッチを優先**：リコール時に `branch` が提供された場合、そのブランチの記憶を優先
- **フォールバック**：ブランチレベルに結果がない場合、repository、workspace、tenant レベルにフォールバック
- **空のスコープ**：スコープなしの記憶はグローバルとして扱われる

## 修正ライフサイクル

HMG は記憶を上書きしません。代わりに、修正は新しいアトムを作成し、エッジで接続します：

### 修正アクション

| アクション | 効果 |
|---|---|
| `negate` | 否定極性のアトムを作成し、対象を置換 |
| `confirm_actual` | 事実の正確性を確認 |
| `confirm_necessary` | 継続的な関連性を確認 |
| `demote` | 認識状態を低下 |
| `replace` | 古いアトムを新しい内容で置換 |

すべての修正は不変のスナップショット履歴を作成します。

詳細は [修正とガバナンス](correction-governance.md) をご覧ください。

## ガバナンスライフサイクル

ガバナンスは機密性の高いまたは古い記憶を保護します：

```
normal → quarantined → sealed     （ロック）
                    → tombstoned  （削除）
                    → normal      （復元）
任意   → lesson                   （教訓の抽出）
```

ガバナンスされたアトムは通常リコールから非表示になりますが、監査証跡には保持されます。

詳細は [修正とガバナンス](correction-governance.md) をご覧ください。

## リコール（Recall）

リコールは記憶ストアから関連する記憶を検索します。

### リコールフロー

```
クエリ → 意図解析 → インデックス検索 → ランキング → スコープフィルタ → グラフトラバーサル投影 → フォーマット出力
```

### レスポンス形式

| 形式 | 用途 |
|---|---|
| `compact` | エージェントの日常使用（デフォルト） |
| `summary` | 人間が読める要約 |
| `full` | 完全な詳細 |
| `debug` | 診断情報を含む |

### セマンティック検索

Community Edition は One-Shot Recall (P1-P9) を含むすべてのエディションが完全なリコール機能を利用できます。Developer Edition は数量制限を解除し、自動統合を追加します。

## グラフモデル

アトムは型付けされたエッジで相互に接続されます：

| エッジ型 | 意味 |
|---|---|
| `Supersedes` | 修正/置換関係 |
| `DerivesFrom` | 派生/学習関係 |
| `RelatesTo` | 一般的な関連 |
| `ScopedBy` | スコープ帰属 |

グラフトラバーサルにより、リコール操作は直接一致した結果だけでなく、関連する記憶も投影できます。

## ドメインパック

ドメインパックは事前定義された記憶テンプレートとスコープ戦略です：

- **Software Engineering**：コードベース、ブランチ、タスクのスコープモデル
- カスタムドメインパック（Developer/Enterprise）

`domain_pack_id` パラメータで有効化します。

## 次のステップ

- [アーキテクチャ](architecture.md) — HMG の高レベルの動作原理
- [API リファレンス](api-reference.md) — すべての MCP ツールと HTTP エンドポイント
- [修正とガバナンス](correction-governance.md) — 詳細な修正とガバナンスのフロー
