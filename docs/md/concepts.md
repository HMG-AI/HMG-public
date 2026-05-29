# HMG Concepts

This guide explains the core concepts behind HMG's memory model. Understanding these concepts will help you use HMG effectively with your AI agents.

## Memory Atoms

The fundamental unit of memory in HMG is a **Memory Atom**. Each atom is a typed graph node that represents a piece of knowledge:

```
┌─────────────────────────────────────────┐
│           Memory Atom                    │
├─────────────────────────────────────────┤
│  id:        01HKX2ABCDEF... (ULID)      │
│  content:   "We use PostgreSQL for..."   │
│  polarity:  positive                    │
│  epistemic: actual                      │
│  exposure:  visible                     │
│  time:      2026-05-25T10:30:00Z        │
│  modality:  text                        │
│  category:  decision                    │
│  scope:     my-org/my-repo/main         │
│  source:    architecture-review         │
└─────────────────────────────────────────┘
```

### Content

The raw text of the memory. This is what gets recalled and presented to your agent.

### Polarity

Every memory has a **polarity** — an assertion about the world:

| Polarity | Meaning | Example |
|---|---|---|
| `positive` | This is the case | "We use PostgreSQL for the main database" |
| `negative` | This is NOT the case | "We do NOT use MongoDB for user data" |
| `conditional` | This is true under conditions | "We use Redis for caching when latency < 5ms" |

### Epistemic Status

How certain we are about the memory:

| Status | Meaning | Example |
|---|---|---|
| `possible` | Might be true | "We might switch to CockroachDB next quarter" |
| `actual` | Confirmed true | "We deployed v2.1.0 to production yesterday" |
| `necessary` | Must be true (constraint) | "All API endpoints require authentication" |

### Exposure State

Governance visibility — controls who can see the memory and how:

| State | Meaning |
|---|---|
| `visible` | Normal — appears in all recall |
| `quarantined` | Hidden from normal recall — under review |
| `sealed` | Hidden — contains sensitive data, payload not retrievable |
| `tombstoned` | Deleted — only metadata remains |
| `lesson` | Derived lesson — sanitized version of a sensitive memory |

## Correction

Unlike simple overwrite-and-forget systems, HMG uses **append-only correction**. When a memory becomes stale or wrong, you don't delete it — you correct it.

```
Memory A: "We use MongoDB"
    │
    ├── Correction: replace → Memory B: "We migrated to PostgreSQL"
    │                                        │
    │                                        └── Supersedes link → A
    │
    └── History preserved: A still exists with correction lineage
```

### Correction actions

| Action | What it does |
|---|---|
| `negate` | Mark as false — changes polarity to negative |
| `confirm_actual` | Upgrade certainty — changes epistemic to `actual` |
| `confirm_necessary` | Upgrade certainty — changes epistemic to `necessary` |
| `demote` | Downgrade certainty — reduces confidence |
| `replace` | Create a new atom that supersedes the old one |

**Key insight:** Correction history is never lost. You can always trace why a decision changed, what was believed before, and who made the correction.

## Governance

Governance controls the visibility and lifecycle of memories, especially sensitive ones.

### Governance actions

| Action | What it does |
|---|---|
| `quarantine` | Hide from normal recall — pending review |
| `seal` | Permanently hide content — payload is irretrievable |
| `tombstone` | Delete — only metadata remains |
| `derive_lesson` | Extract a safe lesson from sensitive content |

### Example: Handling a leaked API key

```
1. Agent accidentally memorizes: "The API key is sk-abc123..."
2. Governance → quarantine: Hidden from recall, under review
3. Governance → derive_lesson: "Always rotate keys after accidental commit"
4. Governance → seal: Original content irretrievable, lesson preserved
```

## Scope

HMG supports hierarchical scoping for branch-aware memory:

```
tenant (my-company)
  └── workspace (platform)
       └── repository (my-app)
            └── branch (main)
```

### Why scope matters for coding agents

A coding agent working on `feature/auth` doesn't need memories from `feature/payments`. Scope ensures agents get the **right** context:

- `main` branch memories: architecture decisions, conventions
- `feature/auth` memories: auth-specific implementation notes
- Cross-branch: shared decisions bubble up through the hierarchy

## Modality

Memories can have different modalities — the form in which knowledge was captured:

| Modality | Description | Example |
|---|---|---|
| `text` | Natural language prose | "We chose Redis for session storage" |
| `code` | Code snippet or technical reference | "`fn main() { ... }`" |
| `dialogue` | Conversation excerpt | "User said: Use the blue theme. Agent: Noted." |
| `observation` | Observed behavior or pattern | "Tests fail consistently on ARM64" |

## Memory Context

Every memory operation carries a **MemoryContext** — unified metadata that includes:

- **Scope**: where in the hierarchy this memory lives
- **Access level**: who can see it
- **Policy tags**: governance rules that apply
- **References**: links to related atoms, files, or external resources
- **Audit trail**: who created/modified it and when

## Recall Views

HMG supports different views of memory depending on the context:

| View | What you see | Use case |
|---|---|---|
| **Normal** | Visible, non-governed atoms | Daily agent work |
| **Governance** | Governed atoms (quarantined, sealed, tombstoned) | Admin review |
| **Audit** | Full history including corrections and governance transitions | Compliance, debugging |

Normal recall is intentionally narrower than audit recall — agents get what they need, not everything.

## Agent Tool Output Contract

HMG's recall output follows a structured contract designed for agent consumption:

1. **Compact YAML by default** — easy for agents to parse
2. **Progressive disclosure** — `compact` → `summary` → `full` → `debug` profiles
3. **Hints and diagnostics** — quality signals, knowledge-gap indicators
4. **Safe for agent context windows** — respects token budgets

This is not just an API — it's a protocol for how agent memory interfaces should work.

## What's next?

- [Getting Started](getting-started.md) — install HMG and store your first memory
- [API Reference](api-reference.md) — all MCP tools and HTTP endpoints
- [Architecture](architecture.md) — how HMG works at a high level
