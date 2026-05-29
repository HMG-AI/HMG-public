# HMG Normative Specification

This document is the authoritative reference for HMG concepts, data types,
lifecycle semantics, and wire protocol. Implementations that conform to this
specification may claim "HMG Compatible."

**Version:** 1.0 (corresponds to HMG v1.0.0)

---

## Table of Contents

1. [Memory Atom](#1-memory-atom)
2. [Polarity](#2-polarity)
3. [Epistemic Status](#3-epistemic-status)
4. [Exposure State (Governance)](#4-exposure-state-governance)
5. [Relation Types](#5-relation-types)
6. [Scope](#6-scope)
7. [Memory Context](#7-memory-context)
8. [Correction Lifecycle](#8-correction-lifecycle)
9. [Governance Lifecycle](#9-governance-lifecycle)
10. [Recall Views](#10-recall-views)
11. [P-Type Query Matrix](#11-p-type-query-matrix)
12. [Agent Tool Output Contract v2](#12-agent-tool-output-contract-v2)
13. [Mechanical Agent Adoption Protocol](#13-mechanical-agent-adoption-protocol)
14. [Edition Boundary](#14-edition-boundary)

---

## 1. Memory Atom

The **Memory Atom** is the fundamental unit of HMG. Every piece of information
stored in HMG is represented as an atom with the following fields:

| Field | Type | Description |
|---|---|---|
| `id` | ULID string | Unique identifier, time-sortable |
| `content` | string | The raw text content of the memory |
| `modality` | enum | How the content was produced (see below) |
| `polarity` | enum | Truth-value assertion (§2) |
| `epistemic_status` | enum | Confidence/truth classification (§3) |
| `exposure_state` | enum | Governance visibility (§4) |
| `created_at` | temporal coordinate | When the atom was created |
| `provenance` | object | Agent ID, source, and derivation chain |
| `context` | MemoryContext | Scope, access level, policy tags, audit (§7) |

### Modality

| Value | Description |
|---|---|
| `text` | Free-form natural language |
| `code` | Source code or configuration |
| `dialogue` | Conversational exchange (dialogue turn) |
| `observation` | Observed system event or external data |

### Key Invariant

**Atoms are never physically deleted.** Negation and governance produce new
information without destroying history. This enables full audit trails.

---

## 2. Polarity

Polarity represents the assertion quality of an atom, following Kantian
categories:

| Polarity | Wire Value | Description |
|---|---|---|
| **Positive** | `"positive"` | Reality — affirmed as true |
| **Negative** | `"negative"` | Negation — retracted or denied |
| **Conditional** | `"conditional"` | Limitation — true under specific conditions |

Negative polarity records *what was negated and why* (not just a boolean flag).
Conditional polarity includes a context predicate describing the condition.

---

## 3. Epistemic Status

Epistemic status classifies how confident the system is that an atom is true,
mapped to Kant's modality categories:

| Status | Wire Value | Rank | Description |
|---|---|---|---|
| **Possible** | `"possible"` | 0 | May be true (with probability score) |
| **Actual** | `"actual"` | 1 | Confirmed as in fact true |
| **Necessary** | `"necessary"` | 2 | Axiomatic — must be true |

Ranking: `Possible < Actual < Necessary`. Corrections can elevate or demote
status (§8).

---

## 4. Exposure State (Governance)

Exposure state controls an atom's visibility in recall. It is orthogonal to
truth and epistemic status: an atom can remain historically true while being
removed from ordinary recall due to privacy, safety, or governance reasons.

| State | Wire Value | In Normal Recall | Description |
|---|---|---|---|
| **Normal** | `"normal"` | ✅ | Default — visible in all views |
| **Quarantined** | `"quarantined"` | ❌ | Under review for sensitivity |
| **Sealed** | `"sealed"` | ❌ | Permanently locked, immutable |
| **Tombstoned** | `"tombstoned"` | ❌ | Marked for removal |
| **Lesson** | `"lesson"` | ✅ | Sensitive payload replaced with safe summary |

### State Transitions

```text
normal ──→ quarantined ──→ sealed
    │          │
    │          ├──→ tombstoned
    │          │
    │          └──→ normal (cleared, restored)
    │
    └──→ lesson (derive_lesson: payload replaced with safe lesson)
```

---

## 5. Relation Types

Relations connect atoms via directed edges:

| Relation | Wire Label | Description |
|---|---|---|
| `AttributeOf` | `"attribute_of"` | `from` is a sub-feature/attribute of `to` |
| `CausedBy` | `"caused_by"` | `from` caused/entailed `to` (with causal strength and temporal lag) |
| `CorrelatesWith` | `"correlates_with"` | `from` and `to` co-occur in context |
| `Contradicts` | `"contradicts"` | `from` contradicts `to` (optional resolution atom) |
| `Supersedes` | `"supersedes"` | `from` is a newer version of `to` (created by replace corrections) |
| `IsInstanceOf` | `"is_instance_of"` | `from` is an instance/example of `to` |
| `TemporallyAdjacent` | `"temporally_adjacent"` | `from` and `to` occurred close in time |
| `DerivedLessonFrom` | `"derived_lesson_from"` | `from` is a sanitized lesson derived from `to` |
| `RedactedFrom` | `"redacted_from"` | `from` is a redacted replacement view of `to` |
| `SealedBecause` | `"sealed_because"` | `from` records the governance reason for `to` being sealed |
| `GovernedBy` | `"governed_by"` | `from` stores governance metadata about `to` |
| `Custom` | `"custom:{label}"` | User-defined free-form relation |

---

## 6. Scope

HMG uses hierarchical scope for branch-aware coding-agent memory:

```text
tenant_id
  └── workspace
        └── repository
              └── branch
                    ├── task_id
                    └── decision_id
```

### Scope Segment

Each level is a `{ kind, id }` pair:

```json
{ "kind": "repository", "id": "my-repo" }
```

### ScopeRef

A full scope reference consists of a `tenant_id` plus a path of segments:

```json
{
  "tenant_id": "tenant-acme",
  "path": [
    { "kind": "workspace", "id": "platform" },
    { "kind": "repository", "id": "my-repo" },
    { "kind": "branch", "id": "feature/auth" }
  ]
}
```

### Scope Inheritance

When scope is provided, recall automatically prioritizes branch-specific
memories, falling back to repository, workspace, and tenant levels.

---

## 7. Memory Context

Every atom carries a `MemoryContext`:

| Field | Type | Description |
|---|---|---|
| `scope` | ScopeRef (optional) | Hierarchical scope path (§6) |
| `access_level` | enum | `internal` (default), `confidential`, `restricted` |
| `policy_tags` | string[] | Tags for policy evaluation |
| `effective_time` | time window (optional) | When the memory is valid |
| `audit` | AuditContext (optional) | Audit trail information |
| `references` | MemoryReferences | Cross-references to other atoms |
| `governance` | Governance (optional) | Governance metadata |

---

## 8. Correction Lifecycle

Corrections explicitly revise existing atoms. The correction model is
**append-only**: original atoms are preserved, and corrections create explicit
relationships.

### Correction Actions

| Action | Wire Value | Effect |
|---|---|---|
| **Negate** | `"negate"` | Sets atom polarity to Negative. Records reason. |
| **Confirm Actual** | `"confirm_actual"` | Elevates epistemic status to Actual. |
| **Confirm Necessary** | `"confirm_necessary"` | Elevates epistemic status to Necessary. |
| **Demote** | `"demote"` | Demotes epistemic status to Possible. |
| **Replace** | `"replace"` | Negates old atom, creates new atom with updated content, links via `Supersedes` edge. |

### Replace Flow

```text
1. Original atom (positive, content A)
2. Correction: replace with content B
   → Original atom polarity → negative
   → New atom created (positive, content B)
   → Supersedes edge: new → original
   → Snapshot preserved
```

### Correction Request

```json
{
  "target_atom": "01KSEFSC29QX8RQ78N3110ATC9",
  "action": "replace",
  "reason": "Database changed to SQLite for simplicity",
  "new_content": "Decision: Use SQLite for user data.",
  "context": { "repository": "my-repo", "branch": "main" }
}
```

### Correction Result

```json
{
  "success": true,
  "message": "replaced with new atom 01KSNEW...",
  "replacement_atom": "01KSNEW..."
}
```

---

## 9. Governance Lifecycle

Governance actions protect sensitive or stale memory. Like corrections,
governance is append-only with snapshot history.

### Governance Actions

| Action | Wire Value | Effect |
|---|---|---|
| **Quarantine** | `"quarantine"` | Moves atom to Quarantined state. Hidden from normal recall. |
| **Seal** | `"seal"` | Moves atom to Sealed state. Permanently locked, immutable. Optionally links a lesson atom. |
| **Tombstone** | `"tombstone"` | Moves atom to Tombstoned state. Optionally destroys payload. Optionally links a lesson atom. |
| **Derive Lesson** | `"derive_lesson"` | Creates a new lesson atom with safe summary content. Links via `DerivedLessonFrom` edge. Original atom may become tombstoned or sealed. |

### Governance Request

```json
{
  "target_atom": "01KSEFSC29QX8RQ78N3110ATC9",
  "action": "derive_lesson",
  "reason": "Contains sensitive API endpoint",
  "lesson_content": "An API endpoint was stored but removed for security."
}
```

---

## 10. Recall Views

HMG supports three recall views with different visibility rules:

| View | Includes | Excludes |
|---|---|---|
| **normal** | Positive-polarity, Normal-exposure atoms | Quarantined, sealed, tombstoned, negative |
| **governance** | + Quarantined and sealed atoms | Tombstoned |
| **audit** | All atoms including tombstoned and full correction chain | Nothing |

Normal recall is the default for daily agent use. Audit recall provides full
forensic traceability.

---

## 11. P-Type Query Matrix

HMG defines nine query types for coding-agent lookup tasks. These types
describe *what kind of information* an agent is looking for, not how to find it.

| Type | Name | Example Query |
|---|---|---|
| P1 | Entity | "What is X?" |
| P2 | Process | "How does X work?" |
| P3 | Decision | "Why did we choose X?" |
| P4 | Status | "What is the current state of X?" |
| P5 | History | "What changed with X?" |
| P6 | Relation | "How does X relate to Y?" |
| P7 | Error | "Why is X failing?" |
| P8 | Instruction | "How should I do X?" |
| P9 | Context | "What should I know about X?" |

---

## 12. Agent Tool Output Contract v2

### Overview

HMG tools return results to agents in a structured format designed for
efficient consumption by AI systems:

- **Compact YAML** is the default output format (not verbose JSON)
- **Field denylist** strips internal fields from public responses
- **Progressive disclosure** — `compact` profile for routine use, `summary`
  for human review, `full` for debugging
- **`structuredContent`** side channel — machine-parseable data alongside
  human-readable text

### Response Profiles

| Profile | Use Case | Content Level |
|---|---|---|
| `compact` | Default agent use | Minimal fields, YAML |
| `summary` | Human review | Markdown narrative |
| `full` | Debugging | All public fields, JSON |
| `debug` | Internal diagnostics | All fields including internal |

### Output Formats

| Format | Description |
|---|---|
| `yaml` | Compact YAML (default for agent consumption) |
| `markdown` | Human-readable markdown |
| `json` | Full JSON structure |

### Compact YAML Example (Recall)

```yaml
brief_v2:
  scope: "tenant-acme/platform/HMG/main"
  lang: auto
  query: "database decision"
  engine: basic
  intent: query_directed
  confidence: high
  answer: "Decision: Use SQLite for user data."
  sources:
    - "01KSNEW..."
  related: []
  gaps: []
```

### Handoff Output Example

```yaml
scope:
  repository: "HMG"
  branch: "main"
what_changed: "Implemented user authentication module"
why: "ADR-007 required OAuth2 support"
validation: "47/47 tests pass"
remaining_risks:
  - "Token refresh edge case untested"
next_steps:
  - "Add refresh token integration test"
```

---

## 13. Mechanical Agent Adoption Protocol

### Overview

HMG provides one-click agent integration via `hmg init --agent <id>`. The
Mechanical Adoption Protocol defines the standard contract that all agent
adapters must implement.

### Integration Contract

Every agent adapter must provide:

| Component | Description | Doctor Severity if Missing |
|---|---|---|
| **MCP Config** | Transport configuration for the agent to reach HMG | **Fail** |
| **Advisory Prompt** | Slim rules guiding the agent to use HMG tools correctly | **Warning** |
| **Lifecycle Surface** | Hooks for session start/end, command events | **Fail** (when hooks available) |

### Adapter Interface

```rust
trait AgentIntegration {
    fn id(&self) -> &'static str;           // e.g., "cursor", "claude", "pi"
    fn display_name(&self) -> &'static str; // e.g., "Cursor"
    fn init(&self, options: &InitOptions) -> Result<InitReport, String>;
    fn doctor(&self) -> Vec<DoctorFinding>;
    fn is_detected(&self, target_dir: &Path) -> bool;
    fn remove(&self, options: &InitOptions) -> Result<InitReport, String>;
}
```

### Init Process

```bash
hmg init --agent <id>       # One-click setup
hmg doctor                  # Verify integration health
hmg integrations repair     # Fix broken integrations
```

### Supported Agents

| Agent ID | Display Name | Transport |
|---|---|---|
| `cursor` | Cursor | MCP stdio |
| `claude` | Claude Code (Codex) | MCP stdio |
| `codex` | OpenAI Codex | MCP stdio |
| `pi` | Pi Coding Agent | Pi extension API |
| `generic_mcp` | Any MCP client | MCP stdio |

### Doctor Exit Codes

| Code | Meaning |
|---|---|
| 0 | All checks pass |
| 1 | Advisory warning (prompt missing but mechanical OK) |
| 2 | Mechanical failure (MCP config or hooks broken) |

---

## 14. Edition Boundary

HMG ships as a single binary with three editions gated at runtime:

| Feature | Community | Developer | Enterprise |
|---|---|---|---|
| Memorize | ✅ | ✅ | ✅ |
| Recall | Basic keyword | One-Shot Engine | One-Shot + Domain |
| Correction | ✅ Full | ✅ Full | ✅ Full |
| Governance | ✅ Full | ✅ Full | ✅ + Policy Packs |
| MCP Protocol | ✅ Full | ✅ Full | ✅ Full |
| Agent Integration | ✅ All adapters | ✅ All adapters | ✅ All adapters |
| Semantic Search | ❌ | ✅ | ✅ |
| Consolidation | Manual only | Automated | Automated + Policies |
| Domain Packs | None | software-engineering | + customer-service, compliance |
| Max Atoms | 50,000 | Unlimited | Unlimited |
| Max Instances | 5 | Unlimited | Unlimited |
| SSO / RBAC | ❌ | ❌ | ✅ |

### Edition Detection

```bash
# Environment variable
export HMG_LICENSE_KEY=hmg-dev-xxxx-xxxx-xxxx

# Config file
echo "hmg-dev-xxxx-xxxx-xxxx" > ~/.config/hmg/license.key

# Cloud token
export HMG_CLOUD_TOKEN=your-cloud-token
```

No key → Community. `hmg-dev-*` → Developer. `hmg-ent-*` → Enterprise.
`HMG_CLOUD_TOKEN` → Enterprise.

---

## Conformance

Implementations claiming **"HMG Compatible"** must:

1. Support all atom fields, polarities, and epistemic statuses defined here
2. Implement the full correction action set (§8)
3. Implement the full governance action set (§9)
4. Respect the three recall view visibility rules (§10)
5. Pass the `hmg-certification` conformance test suite
