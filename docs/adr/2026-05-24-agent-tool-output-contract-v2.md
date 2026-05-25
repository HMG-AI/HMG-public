# ADR 2026-05-24: Agent Tool Output Contract v2

## Status

**Accepted** — supersedes partial coverage of [ADR 2026-05-23: Agent Tool Output Profiles](./2026-05-23-agent-tool-output-profiles.md) and changes the default policy in [ADR 2026-05-20: Agent Brief v2 Compact and Localized Response Profile](./2026-05-20-agent-brief-v2-compact-localized.md). Extends [ADR 2026-05-20: Compact Write Tool Acknowledgements](./2026-05-20-compact-write-tool-acknowledgements.md) to all MCP surfaces.

## Date

2026-05-24

## Context

HMG MCP tools run inside coding-agent sessions. Tool responses enter the active model context window. When handlers serialize storage types directly — especially `MemoryAtom` with `ContentEnvelope.embedding`, Kant `CategoryCoord`, full `MemoryContext` audit chains, and duplicate current/history fields — a single `memory_history` call can consume thousands of tokens with near-zero decision value.

Prior ADRs established the right principles but only partially applied them:

| Prior ADR | What shipped | Gap |
|-----------|--------------|-----|
| 2026-05-20 write ack | `memory_memorize` / `memory_handoff` default `ack` | Observation and metadata tools still echo raw content |
| 2026-05-20 agent brief | `compact_yaml` profile exists | MCP schema default remains `full`; outer JSON wrapper still verbose |
| 2026-05-23 read profiles | `memory_recall` compact YAML + `structuredContent` | `memory_history`, query tools, stats, panorama, brief not on shared contract |

The observed failure mode (2026-05-24 dogfood): agents calling `memory_history` receive pretty JSON containing full embedding vectors, category taxonomy, and duplicated atom/current blocks. This is not a formatting problem. It is an **agent boundary violation**: storage fidelity leaked into the agent reading surface.

### Architectural alignment

HMG's product wedge is **coding-agent memory** — cross-session continuity, decision trace, correction history, governed recall. The runtime model is:

- **Storage layer** (`MemoryAtom`, indexes, Fjall): holographic retention; embeddings and audit belong here.
- **Projection layer** (`hmg-core::projection`, recall views, MemoryQL rows): governed, task-scoped views.
- **Service adapter layer** (`hmg-server` MCP/HTTP): protocol translation for clients.
- **Agent reading surface** (MCP `content[0].text`): must be a **decision-optimized projection**, never a dump of storage types.

Contract v1 (recall-only profiles) proved that token savings come from **response shape**, not YAML vs JSON. Contract v2 makes that rule **mandatory and universal** for all agent-facing read paths.

## Decision

Adopt **Agent Tool Output Contract v2**:

> **Never serialize storage types directly to the agent reading surface.** All MCP read tools must project through agent-facing DTOs, default to compact profiles, omit internal/runtime fields, and expose full fidelity only via explicit opt-in or durable IDs + follow-up tools.

### Core principles

1. **Storage ≠ agent surface.** `MemoryAtom`, raw index internals, and embedding vectors must not appear in default tool text.
2. **Compact by default.** Every read tool defaults to the smallest profile that answers the agent's decision question.
3. **Progressive disclosure.** IDs, lineage summaries, and omission markers first; full payloads only when `response_profile=full|debug` or tool-specific debug flags are set.
4. **No duplicate echo.** Do not return the same semantic content in `brief`, `narrative`, `atoms`, and `atom` blocks unless `include_debug=true`.
5. **Structured side channel.** MCP `structuredContent.data` carries structured payloads for programmatic clients; visible text stays compact.
6. **Fidelity preserved in store.** Compact responses never truncate or delete stored memory; omission is response-only.

### Three-layer response pipeline

All MCP handlers must follow this pipeline (new shared module: `crates/hmg-server/src/mcp/agent_output/`):

```
HMG engine / store types
        ↓
  Agent DTO projection   ← profile, token_budget, field denylist
        ↓
  Render (YAML / MD / JSON)
        ↓
  ToolTextOutput { content, structured_data }
```

**Forbidden:** `serde_json::json!({ "atom": atom })` where `atom: MemoryAtom` in any default or compact path.

### Shared read parameters

All **read-class** MCP tools (see inventory below) must accept and honor:

| Parameter | Type | Default | Purpose |
|-----------|------|---------|---------|
| `response_profile` | `compact` \| `summary` \| `full` \| `debug` | `compact` | Response shape |
| `output_format` | `yaml` \| `markdown` \| `json` | profile-dependent | Visible text encoding |
| `token_budget` | integer | none | Soft cap; trims **related/result counts only**, never atom text |
| `max_text_chars_per_atom` | integer | `0` (never truncate) | Legacy opt-in truncation when set `> 0` (clamp 1–2000) |
| `include_debug` | boolean | `false` | Include traces, raw atoms, pipeline detail |
| `include_embedding` | boolean | `false` | Only honored when `response_profile=debug` |

Profile defaults for `output_format`:

- `compact` → `yaml`
- `summary` → `markdown`
- `full` \| `debug` → `json`

Aliases (backward compatible): `compact|yaml|agent`, `summary|human|markdown`, `full|json`.

Write-class tools continue using [write ack profiles](./2026-05-20-compact-write-tool-acknowledgements.md): `ack` (default), `summary`, `full`, `debug`, plus `include_content`, `max_response_chars`.

### Agent-facing DTO shapes

These types are the **only** shapes allowed in compact/summary visible text. Implement in `hmg-server` (agent adapter), not in `hmg-core` storage types.

#### `AgentAtomView` (compact atom reference)

Used by: recall results (already approximated by `RecalledAtom`), history, query rows, brief memories, panorama seeds.

```yaml
# Logical fields (YAML keys stable across tools)
id: "01KS..."
text: "full human-readable content for selected atoms"   # truncated only when max_text_chars_per_atom > 0
score: 0.42                              # optional, when ranked
state:
  epistemic: Actual                      # string label, not full enum tree
  exposure: Normal
  polarity: Positive
scope: "tenant-acme/platform/HMG@main"   # single-line scope summary
modality: Text                           # optional short label
```

**Omitted in compact (always):**

- `content.embedding`, any `Vec<f32>` vector
- `category` / `CategoryCoord` (Kant taxonomy)
- Full `MemoryContext` audit blobs, policy tag expansions, reference graphs
- `provenance.agent` ULID unless `include_debug=true`
- `structured` content envelope unless `include_debug=true`
- Duplicate copies of the same text in sibling fields

#### `AgentHistoryView` (lineage inspection)

Used by: `memory_history`. Replaces direct `MemoryAtom` serialization.

```yaml
hmg_history_v1:
  atom_id: "01KS..."
  text: "bounded current text or [governed payload hidden: Sealed]"
  state:
    epistemic: Actual
    exposure: Normal
    polarity: Positive
  scope: "tenant-acme/platform/HMG@main"
  snapshot_version: 216
  lineage:
    - at: "2026-05-23T12:00:00Z"
      kind: governance_sealed          # stable enum: polarity_change | epistemic_change | governance_* | derived
      summary: "Sealed by mcp: policy review"
      actor: "mcp"                     # optional
  edges:
    - relation: supersedes
      peer_id: "01KS..."
      direction: incoming | outgoing
  related_lessons: ["01KS..."]
  diagnostics:
    embedding: omitted
    full_atom: omitted
    debug_payload: omitted
```

**Lineage rules:**

- Merge `polarity_history`, `epistemic_history`, and `exposure_history` into a single time-ordered `lineage` list in compact mode.
- Do not emit both raw history arrays and `lineage` in compact mode.
- `response_profile=full` may restore the previous JSON shape for compatibility.
- `response_profile=debug` may include `full_atom` and `include_embedding=true` vectors.

#### `AgentBriefEnvelope` (task-start brief)

Unify `brief_format` into `response_profile`:

| Legacy | v2 mapping |
|--------|------------|
| `brief_format=compact_yaml` | `response_profile=compact`, `output_format=yaml` |
| `brief_format=full` | `response_profile=full` |

Compact visible text is the `hmg_brief_v2` YAML block (per ADR 2026-05-20). Broad briefs use **primary + related** (full text, bounded count). One-shot briefs use **answer + related** (full text, up to 2 graph-linked atoms). The outer JSON wrapper must not repeat `narrative`, raw `atoms`, or full recall payload unless `include_debug=true`.

**Default change:** `response_profile=compact` (was `full`).

#### `AgentQueryResultView` (MemoryQL)

Used by: `memory_query_intent`, `memory_query`.

```yaml
hmg_query_v1:
  task: recall_branch_memory
  mode: normal
  rows_returned: 3
  rows:
    - id: "01KS..."
      text: "bounded content"
      score: 0.31
      state: { epistemic: Actual, exposure: Normal }
      matched_reason: ["semantic", "scope"]
  diagnostics:
    cost: { rows_scanned: 120, rows_returned: 3 }
    debug_payload: omitted
```

`MemoryQueryRow` is already close to this shape; handlers must render it through the shared pipeline instead of wrapping pretty JSON.

#### `AgentStatsView`

Used by: `memory_stats`.

```yaml
hmg_stats_v1:
  atoms: 1240
  edges: 3891
  indexes:
    semantic: 1180
    keyword: 1240
  snapshot_version: 216
```

Fixed small payload; never include index dumps or sample atoms.

#### `AgentMetaView`

Used by: `memory_schema`, `memory_query_templates`.

- Prefer MCP **resources** (`hmg://schema`, `hmg://query-templates`) for static metadata in a future release.
- Until then: compact YAML with version + section counts; full schema only on `response_profile=full`.
- Agents should call these rarely (task setup), not every turn.

#### Write acknowledgements (unchanged contract)

Continue per ADR 2026-05-20. All write tools return durable IDs + omission markers; never echo long input by default.

### Field denylist (global)

The following must **never** appear in default (`compact`) visible tool text:

| Field class | Examples | Rationale |
|-------------|----------|-----------|
| Embeddings | `content.embedding`, any float vector | ~3k–12k tokens each; zero agent decision value |
| Index internals | HNSW manifests, shard paths, posting lists | Runtime/debug only |
| Category taxonomy | `category.quantity`, Kant enums | Storage annotation, not task context |
| Raw audit chains | Full `MemoryContext.audit` event lists | Use lineage summary or audit mode |
| Duplicate bodies | Same text in `atom`, `current`, `narrative`, `atoms` | Echo tax |
| Secrets | Vault payloads, raw tokens | Security + noise |
| Observation raw | `raw_text`, full hook transcripts | Use summary + observation ID |

`response_profile=debug` may include denylisted fields only when paired with explicit flags (`include_embedding`, `include_debug`, `include_recall_trace`, etc.).

### MCP transport contract

Every read tool that supports profiles must return:

```json
{
  "content": [{ "type": "text", "text": "<compact yaml or markdown>" }],
  "structuredContent": {
    "data": {
      "response_profile": "compact",
      "output_format": "yaml",
      "debug_payload": "omitted",
      "...": "structured payload for programmatic clients"
    }
  }
}
```

Rules:

1. `structuredContent.data` always includes `response_profile`, `output_format`, and omission markers.
2. Visible `content[0].text` is what enters the LLM context — optimize this first.
3. TUI, pi wrappers, and SDKs must read `structuredContent` when they need fields absent from compact text.
4. Do not duplicate the entire structured payload into visible text.

## Tool inventory and compliance matrix

Mandatory compliance for all MCP tools exposed to coding agents. Status as of v0.9.1:

| Tool | Class | v0.9.1 status | v2 requirement |
|------|-------|---------------|----------------|
| `memory_recall` | read | **Compliant** | Maintain; reference implementation |
| `memory_memorize` | write | **Compliant** | Maintain ack default |
| `memory_handoff` | write | **Compliant** | Maintain ack default |
| `memory_correct` | write | **Compliant** | Maintain; no long echo |
| `memory_govern` | write | **Compliant** | Maintain; no long echo |
| `memory_agent_brief` | read | **Partial** | Default → compact; unify brief_format; shared pipeline |
| `memory_history` | read | **Non-compliant** | **P0** — AgentHistoryView; no MemoryAtom dump |
| `memory_query_intent` | read | **Partial** | Compact YAML default; token_budget |
| `memory_query` | read | **Partial** | Compact default; audit/debug opt-in only |
| `memory_stats` | read | **Partial** | AgentStatsView compact YAML |
| `memory_schema` | meta | **Partial** | AgentMetaView; consider MCP resource |
| `memory_query_templates` | meta | **Partial** | AgentMetaView compact list |
| `memory_explain_query` | meta | **Partial** | Compact plan summary; full plan on debug |
| `memory_suggest_query` | meta | **Partial** | Top-N suggestions only |
| `memory_export_snapshot` | read/export | **Review** | Never inline snapshot bytes; URI/checksum ack |
| `panorama_query` | read | **Partial** | Compact summaries; bound snippet text |
| `panorama_impact` | read | **Partial** | Risk + top symbols; bound blast radius |
| `memory_noise_feedback` | write | **Compliant** | Small ack |
| `observation_capture` | write | **Partial** | Ack only; no raw_text echo |
| `observation_promote*` | write | **Partial** | Ack + plan IDs; no full episode dump |
| `observation_config` | meta | **Partial** | Compact config snapshot |
| `observation_review_*` | read/write | **Partial** | Queue summaries; detail on demand |
| `observation_maintain` | write | **Partial** | Stats ack |
| `observation_forget` | write | **Partial** | IDs ack |
| `secret_*` | write/read | **Compliant** | Never return secret material |

Any new MCP tool **must** declare its class and default profile in `schema.rs` and implement through `agent_output` before merge.

## Scope

### In scope

- Shared `agent_output` projection + render module in `hmg-server`
- DTO types listed above
- Profile parameters on all read/meta tools in the inventory
- Default policy changes (`memory_history`, `memory_agent_brief`)
- MCP tests: denylist, token bounds, structuredContent
- TUI / pi / `hmg init` default argument injection
- README and MCP quickstart updates
- OpenAPI/SDK `response_profile` parity where HTTP mirrors MCP

### Out of scope

- Changing `MemoryAtom` storage schema or deleting embeddings on disk
- Changing recall ranking, extraction, governance semantics
- Replacing JSON-RPC/MCP transport
- HTTP/gRPC full parity in the same release (may follow MCP)
- Automatic embedding compression or on-the-fly summarization of stored atoms

## Implementation plan

### Phase 0 — Contract landing (this ADR)

- [x] ADR accepted with tool inventory and DTO shapes
- [x] Add `agent_output` module skeleton + denylist tests
- [x] Add compliance checklist to `tests/release_artifacts.rs`

### Phase 1 — P0 hot path (`memory_history`)

1. Implement `AgentHistoryView` projection + `hmg_history_v1` YAML renderer.
2. Wire `parse_read_response_options` into `handle_history`; return `ToolTextOutput`.
3. Default compact; `full` restores v0.9.1 JSON for compatibility.
4. Tests: no `embedding` in default text; char budget; lineage present; structuredContent populated.
5. Update TUI client to use compact + structuredContent (stop forcing `response_profile=full`).

- [x] Phase 1 complete @ main

### Phase 2 — Brief and query alignment

1. Change `memory_agent_brief` schema default to `response_profile=compact`.
2. Deprecate standalone `brief_format` in favor of shared read profiles (keep alias one release).
3. Route `memory_query_intent` / `memory_query` through shared renderer.
4. `memory_stats` → `AgentStatsView`.

- [x] Phase 2 complete @ main

### Phase 3 — Meta, panorama, observation

1. Compact meta tools; document rare-call pattern.
2. Panorama tools: bound symbol lists (`max_results`, `max_text_chars`).
3. Observation tools: ack-only defaults; explicit `include_content` for debug.

- [x] Phase 3 complete @ main

### Phase 4 — Adoption and regression guard

1. `hmg init --agent *` injects compact defaults in generated configs.
2. Pi wrapper defaults aligned with server defaults.
3. Token regression tests: P95 char counts per tool in `crates/hmg-server/src/mcp/tests.rs`.
4. Optional eval: `hmg-evals` scenario measuring response size vs v0.9.1 baseline.

- [x] Pi wrapper compact defaults (existing `compactAgentBriefArgs` / `compactRecallArgs`)
- [x] Token regression tests in `mcp::tests` (`memory_history_compact_*`, schema defaults)
- [ ] Optional `hmg-evals` response-size scenario (deferred)

## Backward compatibility

1. **`response_profile=full`** preserves v0.9.1 visible JSON for every migrated tool for at least one minor release.
2. **`HMG_READ_RESPONSE_PROFILE=full`** env override allowed during transition (mirrors write ack env pattern).
3. **`brief_format=full`** remains accepted as alias for `response_profile=full`.
4. Clients that parsed visible JSON must migrate to `structuredContent.data` or opt into `full`.
5. TUI and integration tests that assert on full atom JSON must update to structuredContent or pass `response_profile=full` explicitly in tests only — not in production defaults.

## Consequences

### Positive

- Order-of-magnitude token reduction on history/inspect paths (primary dogfood pain).
- Consistent agent ergonomics across all read tools.
- Clear developer constraint: storage types cannot leak by accident.
- structuredContent enables rich clients without taxing LLM context.

### Risks

- Breaking clients that depended on default full JSON in visible text.
- Debugging friction if compact lineage hides audit detail.
- Short-term implementation churn across handlers.

### Mitigations

- Explicit omission markers (`embedding: omitted`, `full_atom: omitted`).
- `full` and `debug` profiles remain available indefinitely for tooling.
- Durable atom IDs in every compact view for follow-up recall/history/full inspect.
- Token regression tests in CI.

## Validation

Minimum validation before marking v2 complete:

```bash
cargo test -p hmg-server mcp::tests -- --nocapture
cargo test -p hmg-server integrations::pi -- --nocapture
cargo test --test contracts -- --nocapture
cargo fmt --all -- --check
cargo clippy -p hmg-server --all-targets -- -D warnings
```

Required new tests:

1. Each read tool: default response contains **no** `embedding` key in visible text.
2. `memory_history` compact: char count below configured budget for fixture atom with embedding.
3. `memory_history` full: backward-compatible payload shape.
4. `memory_agent_brief` default: compact YAML visible; no `narrative` unless debug.
5. structuredContent present and includes `response_profile` for all profile-aware read tools.
6. Token regression snapshot: document P95 visible chars per tool vs v0.9.1 baseline in test comments or eval report.

Release gate addition:

- `tests/release_artifacts.rs` asserts ADR reference, init templates use compact defaults, and MCP schema defaults match this ADR.

## Relationship to prior ADRs

| ADR | Relationship |
|-----|--------------|
| 2026-05-20 write ack | Unchanged write policy; observation tools brought into compliance |
| 2026-05-20 agent brief | Compact YAML contract retained; **default changed** from `full` to `compact` |
| 2026-05-23 read profiles | Generalized from recall-only to all read tools; this ADR is the authoritative superset |
| 2026-05-20 MemoryQL | Query row shape aligned with `AgentQueryResultView`; execution semantics unchanged |
| 2026-05-21 observation | Capture/consolidation semantics unchanged; tool **responses** compacted |

## Open questions

1. Should `memory_get_atom` be added as an explicit authorized full-atom read with mandatory `response_profile` (replacing implicit full dump via history)?
2. Should static schema/templates move to MCP resources in v0.10 to eliminate repeated meta tool calls?
3. Should HTTP `/api/atom/:id` share the same DTO projection when implemented?

---

**Implementation rule for all future MCP handler changes:** if a PR adds or modifies an agent-facing tool response, it must cite this ADR, declare the tool class (read/write/meta), and prove default compact compliance in tests. No new `MemoryAtom` direct serialization to visible text.
