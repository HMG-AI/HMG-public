# HMG API Reference — Community Edition

Base URL for HTTP: `http://localhost:3000` (default).

## MCP Tools

HMG exposes 8 MCP tools in Community Edition. All tools accept an optional
`context` object with scope fields for branch-aware memory.

### `memory_memorize`

Store durable information.

```json
{
  "content": "Text to memorize",
  "source": "optional-source-label",
  "modality": "text",
  "context": {
    "tenant_id": "tenant-acme",
    "workspace": "platform",
    "repository": "my-repo",
    "branch": "main"
  }
}
```

Response:

```json
{
  "success": true,
  "added_atom_count": 1,
  "added_atoms": ["01KSEFSC29QX8RQ78N3110ATC9"],
  "snapshot_version": 8
}
```

![Agent calling memory_memorize](img/agent-memorize.png)

### `memory_recall`

Retrieve relevant memories.

```json
{
  "query": "What database did we choose?",
  "max_results": 10,
  "response_profile": "compact",
  "output_format": "yaml"
}
```

Response profiles: `compact` (default), `summary`, `full`, `debug`.

Output formats: `yaml` (default), `markdown`, `json`.

![Agent calling memory_recall](img/agent-recall.png)

### `memory_correct`

Correct, negate, confirm, demote, or replace an atom.

```json
{
  "target_atom": "01KSEFSC29QX8RQ78N3110ATC9",
  "action": "replace",
  "reason": "Database changed to SQLite for simplicity",
  "new_content": "Decision: Use SQLite for user data."
}
```

Actions: `negate`, `confirm_actual`, `confirm_necessary`, `demote`, `replace`.

![Agent calling memory_correct](img/agent-correct.png)

### `memory_govern`

Apply governance: quarantine, seal, tombstone, or derive a lesson.

```json
{
  "target_atom": "01KSEFSC29QX8RQ78N3110ATC9",
  "action": "tombstone",
  "reason": "Contains sensitive API key reference"
}
```

Actions: `quarantine`, `seal`, `tombstone`, `derive_lesson`.

![Agent calling memory_govern](img/agent-govern.png)

### `memory_history`

Inspect correction and governance history for an atom.

```json
{
  "atom_id": "01KSEFSC29QX8RQ78N3110ATC9"
}
```

### `memory_handoff`

Write a cross-session handoff summary.

```json
{
  "summary": "Implemented X, validated with Y tests, remaining risk: Z.",
  "source": "session-end"
}
```

### `memory_agent_brief`

Get a compact, branch-aware brief at task start.

```json
{
  "query": "context for current coding task",
  "brief_format": "compact_yaml"
}
```

![Agent calling memory_agent_brief](img/agent-brief.png)

### `memory_stats`

Get graph and index statistics.

```json
{}
```

![Agent calling memory_stats](img/agent-stats.png)

## HTTP API

### `POST /api/memorize`

Same parameters as `memory_memorize`, as JSON body.

### `POST /api/recall`

Same parameters as `memory_recall`, as JSON body.

### `POST /api/correct`

Same parameters as `memory_correct`, as JSON body.

### `POST /api/governance/{action}`

Actions: `quarantine`, `seal`, `tombstone`, `derive_lesson`.

### `GET /api/stats`

Returns atom count, edge count, index statistics.

### `GET /api/graph/export`

Exports the full memory graph as JSON.

### `GET /api/snapshot/{atom_id}`

Returns snapshot history for a specific atom.

### `GET /api/audit/{atom_id}`

Returns full audit trail (correction + governance history).

## Scope (Branch-Aware Memory)

HMG supports hierarchical scope for coding agents:

```text
tenant_id → workspace → repository → branch
                                        ↳ task_id
                                        ↳ decision_id
```

When scope fields are provided, recall automatically prioritizes branch-specific
memories over broader workspace or tenant memories.

## Response Format

All responses follow a consistent structure:

```json
{
  "success": true,
  "snapshot_version": 905,
  "..."
}
```

Error responses:

```json
{
  "success": false,
  "error": "description of the error"
}
```
