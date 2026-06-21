# Agent Adapter Development Guide

This guide shows how to integrate **any** AI coding agent with HMG's memory service.

HMG provides three integration paths, from easiest to most customizable:

| Path | Best For | Effort |
|------|----------|--------|
| **MCP JSON config** | Agents that support standard MCP | 5 minutes |
| **HTTP REST API** | Agents with HTTP client capability | 30 minutes |
| **SDK (Python/TS)** | Building rich integrations | 1–2 hours |

---

## Option 1: MCP JSON Config (Recommended)

Most modern AI agents support the [Model Context Protocol](https://modelcontextprotocol.io/). HMG ships as a standard MCP server.

### Generate config

```bash
hmg init --agent generic-mcp
```

This creates `hmg-mcp.json` in your project:

```json
{
  "mcpServers": {
    "hmg": {
      "command": "hmg-server",
      "args": ["/home/user/.local/share/hmg/stores/default"]
    }
  }
}
```

### Integrate with your agent

Copy `hmg-mcp.json` into your agent's config directory, or merge the `mcpServers.hmg` entry into its existing config.

For example, if your agent reads MCP servers from `~/.config/your-agent/mcp.json`:

```bash
# Generate the HMG MCP config
hmg init --agent generic-mcp

# Merge into your agent's config
cp hmg-mcp.json ~/.config/your-agent/mcp.json
```

### Available MCP Tools

| Tool | Description |
|------|-------------|
| `memory_memorize` | Store a new memory atom |
| `memory_recall` | Recall relevant memories |
| `memory_correct` | Correct a stale memory |
| `memory_govern` | Govern sensitive knowledge |
| `memory_history` | Inspect atom correction history |
| `memory_handoff` | Write a session handoff summary |
| `memory_agent_brief` | Get a compact agent brief |
| `memory_stats` | Get memory graph statistics |

Full tool schemas: [`mcp/schemas/tools.json`](../../mcp/schemas/tools.json)

---

## Option 2: HTTP REST API

If your agent doesn't support MCP, call HMG directly over HTTP.

### Start the server

```bash
hmg daemon start
# Server listens on http://127.0.0.1:7654
```

### Example: Memorize

```bash
curl -s -X POST http://127.0.0.1:7654/api/memorize \
  -H 'Content-Type: application/json' \
  -d '{
    "content": "Key decision: use event-sourcing for audit log",
    "source": "architecture-review",
    "modality": "text",
    "domain_pack_id": "software-engineering"
  }'
```

### Example: Recall

```bash
curl -s -X POST http://127.0.0.1:7654/api/recall \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "audit log architecture decision",
    "max_results": 5,
    "domain_pack_id": "software-engineering"
  }'
```

### Example: Agent Brief (session context)

```bash
curl -s -X POST http://127.0.0.1:7654/api/agent_brief \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "current task status and risks",
    "domain_pack_id": "software-engineering"
  }'
```

Full API spec: [`openapi/hmg-server.yaml`](../../openapi/hmg-server.yaml)

---

## Option 3: SDK Integration

### Python

```python
from hmg import HMGClient, codingAgentScope

client = HMGClient(base_url="http://localhost:7654")

# Store a decision
client.memorize(
    content="Use WebSocket for real-time sync",
    source="architecture-review",
    domain_pack_id="software-engineering",
)

# Recall context
result = client.recall(query="sync mechanism")
for atom in result.atoms:
    print(f"[{atom.score:.2f}] {atom.text}")
```

### TypeScript

```typescript
import { HMGClient, codingAgentScope } from "@hmg_ai/sdk-ts";

const client = new HMGClient({ baseUrl: "http://localhost:7654" });

await client.memorize({
  content: "Chose Redis for session caching",
  source: "architecture-review",
  domainPackId: "software-engineering",
});

const result = await client.recall({ query: "caching strategy" });
for (const atom of result.atoms) {
  console.log(`[${atom.score}] ${atom.text}`);
}
```

---

## Adapter Reference Architecture

Here's the recommended integration pattern for any agent:

```
┌─────────────────────────────────────────────┐
│  Your Agent                                 │
│                                             │
│  ┌──────────────┐    ┌──────────────────┐   │
│  │ Session      │───▶│ hmg_agent_brief  │   │  ← Task start
│  │ Manager      │    └──────────────────┘   │
│  │              │    ┌──────────────────┐   │
│  │              │───▶│ hmg_recall       │   │  ← Before risky edits
│  │              │    └──────────────────┘   │
│  │              │    ┌──────────────────┐   │
│  │              │───▶│ hmg_memorize     │   │  ← Durable facts
│  │              │    └──────────────────┘   │
│  │              │    ┌──────────────────┐   │
│  │              │───▶│ hmg_correct      │   │  ← Stale memories
│  │              │    └──────────────────┘   │
│  │              │    ┌──────────────────┐   │
│  │              │───▶│ hmg_handoff      │   │  ← Task end
│  └──────────────┘    └──────────────────┘   │
│                                             │
└─────────────────────┬───────────────────────┘
                      │ MCP / HTTP
                      ▼
              ┌──────────────┐
              │  hmg-server  │
              │  (port 7654) │
              └──────────────┘
```

### Lifecycle Hooks

| Hook | Tool | When to Call |
|------|------|-------------|
| **Session start** | `agent_brief` | Retrieve context, decisions, risks |
| **Before risky edit** | `recall` | Check prior decisions on affected files |
| **Decision made** | `memorize` | Store architectural choices, root causes |
| **Memory stale** | `correct` | Update when facts change |
| **Session end** | `handoff` | Persist summary, validation, next steps |

### Scope Convention

Use branch-aware scope for coding tasks:

```json
{
  "context": {
    "scope": {
      "tenant_id": "tenant-acme",
      "path": [
        {"kind": "workspace", "id": "platform"},
        {"kind": "repository", "id": "my-project"},
        {"kind": "branch", "id": "feature/auth"}
      ]
    }
  }
}
```

---

## Contributing Your Adapter

Built an adapter for a new agent? We'd love to include it:

1. **Fork** [HMG-public](https://github.com/HMG-AI/HMG-public)
2. **Create** `examples/agent-adapter/your-agent/` with:
   - `README.md` — integration guide specific to your agent
   - Config templates (MCP JSON, env vars, etc.)
   - Minimal working example
3. **Open a PR** with DCO sign-off (`git commit -s`)

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for the full contribution guide.

---

## Support

- 💬 [GitHub Discussions](https://github.com/HMG-AI/HMG-public/discussions) — integration questions
- 🐛 [GitHub Issues](https://github.com/HMG-AI/HMG-public/issues) — bugs and feature requests
- 📧 security@hmg1ai.com — security issues
