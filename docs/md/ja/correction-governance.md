# 修正とガバナンス

HMG は**追記専用の修正とガバナンスモデル**を使用します。アトムが静かに上書きされることはありません。代わりに、修正は明示的な関係を持つ新しいアトムを作成し、ガバナンス遷移は完全な履歴を保持します。

## アトムライフサイクル状態

### 極性（Polarity）

すべてのアトムには真偽状態を示す極性があります：

| 極性 | 意味 |
|---|---|
| `positive` | アトムは真として主張されている |
| `negative` | アトムは否定または置換されている |
| `neutral` | 情報的 — 真偽の主張なし |

### 認識状態（Epistemic Status）

| 状態 | 意味 |
|---|---|
| `claimed` | 未検証の主張 |
| `confirmed` | 証拠または権威により検証済み |
| `deprecated` | もはや関連しないが誤りではない |
| `unknown` | 分類に情報が不十分 |

### ガバナンス露出状態（Exposure State）

| 状態 | リコール可能 | 意味 |
|---|---|---|
| `normal` | ✅ 通常リコール | デフォルト状態 |
| `quarantined` | ❌ リコールから非表示 | 機密性のレビュー中 |
| `sealed` | ❌ 非表示、不変 | 法的またはポリシーによる制限 |
| `tombstoned` | ❌ 非表示、ペイロード任意 | 削除対象としてマーク |
| `lesson` | ✅ 教訓のみ | 機密ペイロードを安全な教訓に置換 |

## 修正フロー

修正はアトム間に明示的な `Supersedes`（置換）エッジを作成します：

```text
元のアトム (positive)
    │
    ├── negate ──→ 新しいアトム (negative) + Supersedes エッジ
    ├── confirm_actual ──→ 元の極性を確認 + Supersedes エッジ
    ├── confirm_necessary ──→ 元の必要性を確認
    ├── demote ──→ 元の認識状態を低下
    └── replace ──→ 新しいアトム (positive) + Supersedes エッジ + 新しい内容
```

### 修正アクション

| アクション | 効果 |
|---|---|
| `negate` | 否定極性のアトムを作成し、対象を置換 |
| `confirm_actual` | アトムの事実の正確性を確認 |
| `confirm_necessary` | アトムが引き続き関連していることを確認 |
| `demote` | 認識状態を低下（例：confirmed → deprecated） |
| `replace` | 更新された内容の新しいアトムを作成し、古いものを置換 |

![エージェントが memory_correct (replace) を呼び出し](../img/agent-correct.png)

## ガバナンスフロー

ガバナンス遷移は機密性の高いまたは古い記憶を保護します：

```text
normal → quarantined（レビュー中）
quarantined → sealed（ロック、不変）
quarantined → tombstoned（リコールから削除）
quarantined → normal（クリア、復元）
任意 → derive_lesson（安全な要約でペイロードを置換）
```

### ガバナンスアクション

| アクション | From → To | 使用ケース |
|---|---|---|
| `quarantine` | normal → quarantined | 機密性が疑われるコンテンツ |
| `seal` | quarantined → sealed | 法的ホールド、コンプライアンス |
| `tombstone` | quarantined → tombstoned | リコールから削除 |
| `derive_lesson` | 任意 → lesson | 安全な教訓を抽出、機密ペイロードを削除 |

![エージェントが memory_govern (quarantine) を呼び出し](../img/agent-govern.png)

## スナップショット履歴

すべての修正とガバナンスアクションは不変のスナップショットを作成します。
スナップショットは遷移時のアトムの状態を保持します。

`memory_history` ツールは完全なチェーンを返します：

```text
アトム作成 (v1)
  → 修正：negate (v2, Supersedes v1)
    → ガバナンス：tombstone (v2 は通常リコールから非表示)
      → 教訓の派生 (v3, 安全な要約がリコールで表示可能)
```

## リコールビュー

HMG は異なる可視性ルールを持つ3つのリコールビューをサポートします：

| ビュー | 表示内容 | 使用ケース |
|---|---|---|
| `normal` | アクティブなアトムのみ（正極性、normal 露出状態） | 日常のエージェント使用 |
| `governance` | + 隔離/封印されたアトム | コンプライアンスレビュー |
| `audit` | + 墓石化されたものを含む全アトム、完全な修正チェーン | フォレンジック調査 |

通常リコールは意図的にガバナンスされたペイロードを除外します。監査リコールは説明責任のためにすべてを表示します。
