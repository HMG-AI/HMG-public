# Correction and Governance

HMG uses an **append-only correction and governance model**. Atoms are never
silently overwritten. Instead, corrections create new atoms with explicit
relationships, and governance transitions preserve full history.

## Atom Lifecycle States

### Polarity

Every atom has a polarity indicating its truth status:

| Polarity | Meaning |
|---|---|
| `positive` | The atom is asserted as true |
| `negative` | The atom has been negated or superseded |
| `neutral` | Informational — no truth assertion |

### Epistemic Status

| Status | Meaning |
|---|---|
| `claimed` | Unverified claim |
| `confirmed` | Verified by evidence or authority |
| `deprecated` | No longer relevant but not false |
| `unknown` | Insufficient information to classify |

### Exposure State (Governance)

| State | Recallable | Meaning |
|---|---|---|
| `normal` | ✅ Normal recall | Default state |
| `quarantined` | ❌ Hidden from recall | Under review for sensitivity |
| `sealed` | ❌ Hidden, immutable | Legally or policy-restricted |
| `tombstoned` | ❌ Hidden, payload optional | Marked for removal |
| `lesson` | ✅ Lesson only | Sensitive payload replaced with safe lesson |

## Correction Flow

Corrections create explicit `Supersedes` edges between atoms:

```text
Original atom (positive)
    │
    ├── negate ──→ New atom (negative) + Supersedes edge
    ├── confirm_actual ──→ Original polarity confirmed + Supersedes edge
    ├── confirm_necessary ──→ Original necessity confirmed
    ├── demote ──→ Original epistemic status lowered
    └── replace ──→ New atom (positive) + Supersedes edge + new content
```

### Correction Actions

| Action | Effect |
|---|---|
| `negate` | Creates a negative-polarity atom that supersedes the target |
| `confirm_actual` | Confirms the atom's factual accuracy |
| `confirm_necessary` | Confirms the atom remains relevant |
| `demote` | Lowers the epistemic status (e.g., confirmed → deprecated) |
| `replace` | Creates a new atom with updated content, supersedes the old one |

## Governance Flow

Governance transitions protect sensitive or stale memory:

```text
normal → quarantined (under review)
quarantined → sealed (locked, immutable)
quarantined → tombstoned (removed from recall)
quarantined → normal (cleared, restored)
any → derive_lesson (replace payload with safe summary)
```

### Governance Actions

| Action | From → To | Use Case |
|---|---|---|
| `quarantine` | normal → quarantined | Suspected sensitive content |
| `seal` | quarantined → sealed | Legal hold, compliance |
| `tombstone` | quarantined → tombstoned | Delete from recall |
| `derive_lesson` | any → lesson | Extract safe lesson, remove sensitive payload |

## Snapshot History

Every correction and governance action creates an immutable snapshot.
Snapshots preserve the atom's state at the time of the transition.

The `memory_history` tool returns the full chain:

```text
Atom created (v1)
  → Corrected: negate (v2, Supersedes v1)
    → Governed: tombstone (v2 hidden from normal recall)
      → Lesson derived (v3, safe summary visible in recall)
```

## Recall Views

HMG supports three recall views with different visibility rules:

| View | Shows | Use Case |
|---|---|---|
| `normal` | Active atoms only (positive polarity, normal exposure) | Daily agent use |
| `governance` | + Quarantined/sealed atoms | Compliance review |
| `audit` | + All atoms including tombstoned, full correction chain | Forensic investigation |

Normal recall intentionally excludes governed payloads. Audit recall
shows everything for accountability.
