# HMG MCP Tool Schemas

MCP (Model Context Protocol) tool definitions for HMG memory operations.

## Tools

| Tool | Description |
|---|---|
| `memory_memorize` | Store a new memory atom |
| `memory_recall` | Recall relevant memories |
| `memory_correct` | Correct an existing memory atom |
| `memory_govern` | Apply governance actions |
| `memory_history` | Inspect correction/governance history |
| `memory_handoff` | Write a cross-session handoff summary |
| `memory_agent_brief` | Get compact session-start context |
| `memory_stats` | Get memory graph statistics |
| `observation_capture` | Capture an observation |
| `observation_promote` | Promote an observation to durable memory |
| `observation_forget` | Forget an observation |

## Schema Format

Tool schemas follow the MCP JSON Schema format. See `schemas/tools.json`.
