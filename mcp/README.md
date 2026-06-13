# HMG MCP Tool Schemas

<p>
  <img src="https://img.shields.io/badge/tools-8-blue.svg" alt="Tools">
  <img src="https://img.shields.io/badge/protocol-MCP-ff6f00.svg" alt="MCP">
</p>

MCP (Model Context Protocol) tool definitions for HMG memory operations.

## Community Edition Tools

| Tool | Description |
|---|---|
| `memory_memorize` | Store a new memory atom |
| `memory_recall` | Recall relevant memories by query |
| `memory_correct` | Correct, negate, confirm, demote, or replace an atom |
| `memory_govern` | Quarantine, seal, tombstone, or derive lesson |
| `memory_history` | Inspect correction and governance history |
| `memory_handoff` | Write a cross-session handoff summary |
| `memory_agent_brief` | Get compact session-start context |
| `memory_stats` | Get memory graph and index statistics |

> Developer and Enterprise editions add observation management, secret/vault, and advanced tools.

## Quick Start

```bash
# Install HMG
curl -L https://hmg1ai.com/releases/latest/download/install.sh | sh

# Start the daemon
hmg daemon start

# Connect your agent
hmg init --agent cursor
```

## Schema Format

Tool schemas follow the MCP JSON Schema format. See [`schemas/tools.json`](schemas/tools.json).

## Tool Details

### `memory_memorize`

Store durable information into HMG.

**Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `content` | string | ✅ | Text content to memorize |
| `source` | string | Optional | Source attribution |
| `modality` | string | Optional | `text`, `code`, `dialogue`, `observation` |
| `context` | object | Optional | Scope fields (tenant, workspace, repo, branch) |

### `memory_recall`

Retrieve relevant memories by query.

**Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `query` | string | ✅ | Query or question |
| `max_results` | number | Optional | Maximum results (default: 10) |
| `response_profile` | string | Optional | `compact`, `summary`, `full`, `debug` |
| `output_format` | string | Optional | `yaml`, `markdown`, `json` |
| `context` | object | Optional | Scope fields for branch-aware recall |

### `memory_correct`

Correct, negate, confirm, demote, or replace an existing atom.

**Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `target_atom` | string | ✅ | Atom ULID to correct |
| `action` | string | ✅ | `negate`, `confirm_actual`, `confirm_necessary`, `demote`, `replace` |
| `reason` | string | ✅ | Correction reason |
| `new_content` | string | Optional | Replacement text (for `replace` action) |

### `memory_govern`

Apply governance actions to sensitive, unsafe, or stale memory.

**Parameters:**
| Parameter | Type | Required | Description |
|---|---|---|---|
| `target_atom` | string | ✅ | Atom ULID to govern |
| `action` | string | ✅ | `quarantine`, `seal`, `tombstone`, `derive_lesson` |
| `reason` | string | ✅ | Governance reason |
| `lesson_content` | string | Optional | Safe lesson text (for `derive_lesson`) |

## License

Apache-2.0
