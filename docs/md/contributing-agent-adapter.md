# Contributing an Agent Adapter

This guide explains how to integrate a new AI coding agent into the HMG ecosystem as a **community contributor** working with the [HMG-public](https://github.com/HMG-AI/HMG-public) repository.

## Overview

HMG has two classes of agent integration:

| Class | Who builds it | Where it lives | User experience |
|-------|--------------|----------------|-----------------|
| **Built-in adapter** | HMG core team (private repo) | `hmg-server` Rust source | `hmg init --agent <name>` one command |
| **Community adapter** | Anyone (public repo) | `examples/agent-adapter/<name>/` | Copy config + prompt, documented steps |

As a community contributor, you create a **community adapter**. You do **not** need access to HMG's proprietary source code. The integration is purely configuration-driven: MCP config, system prompt, and documentation.

If your adapter gains significant adoption, you can request promotion to a built-in adapter via a GitHub Issue — the HMG core team will implement the Rust adapter in the next release.

## What You Need to Know

### HMG Integration Points

HMG exposes three integration interfaces. Pick the one that matches your agent's capabilities:

| Interface | Best for | Effort | Reference |
|-----------|----------|--------|-----------|
| **MCP** (Model Context Protocol) | Agents that support standard MCP tool servers | ~5 min | [`mcp/schemas/tools.json`](../../mcp/schemas/tools.json) |
| **HTTP REST API** | Agents with HTTP client but no MCP support | ~30 min | [`openapi/hmg-server.yaml`](../../openapi/hmg-server.yaml) |
| **SDK** (Python / TypeScript) | Agents with a plugin/extension system | ~1–2 hrs | [`sdk-python/`](../../sdk-python/), [`sdk-ts/`](../../sdk-ts/) |

### Core Memory Lifecycle

Regardless of interface, the recommended agent memory lifecycle is:

```
Session Start → agent_brief (get context)
     │
     ├── Before risky edit → recall (check prior decisions)
     ├── Decision made → memorize (persist)
     ├── Stale fact found → correct (update)
     │
Session End → handoff (summary for next session)
```

| Hook | Tool / Endpoint | When |
|------|----------------|------|
| Session start | `memory_agent_brief` or `POST /api/agent_brief` | Retrieve context, decisions, risks |
| Before risky edit | `memory_recall` or `POST /api/recall` | Check prior decisions on affected files/symbols |
| Decision made | `memory_memorize` or `POST /api/memorize` | Store architectural choices, root causes, constraints |
| Memory stale | `memory_correct` or `POST /api/correct` | Update when facts change |
| Session end | `memory_handoff` or `POST /api/handoff` | Persist summary, validation, next steps |

### Scope Convention

For coding tasks, use branch-aware scope with the `software-engineering` domain pack:

```json
{
  "domain_pack_id": "software-engineering",
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

## Step-by-Step Contribution Workflow

### Step 1: Fork and Clone

```bash
# Fork https://github.com/HMG-AI/HMG-public on GitHub
git clone https://github.com/<your-username>/HMG-public.git
cd HMG-public
git checkout -b add-<agent-name>-adapter
```

### Step 2: Create the Adapter Directory

```bash
mkdir -p examples/agent-adapter/<agent-name>/
```

Use a lowercase, hyphen-separated name (e.g. `hermes`, `aider`, `roo-code`).

### Step 3: Write the Required Files

Every adapter directory **must** contain these four files:

#### 3a. `<agent-name>-mcp.json` — MCP Config Template

The MCP server connection config that tells the agent how to reach HMG:

```json
{
  "mcpServers": {
    "hmg": {
      "command": "hmg-server",
      "args": ["~/.local/share/hmg/stores/default"],
      "env": {
        "HMG_PROVIDER_BACKEND": "local",
        "HMG_CONSOLIDATION_SCHEDULER": "embedded"
      }
    }
  }
}
```

Adjust the structure to match what your agent actually reads. Some agents use a different top-level key, nested config, or a different file format (YAML, TOML). Document the exact location and format in your README.

#### 3b. `hmg-<agent-name>-prompt.md` — System Prompt Fragment

A concise prompt that tells the agent's LLM when and how to use HMG tools:

```markdown
# HMG Memory — <Agent> System Prompt

When HMG MCP tools are available, use them as durable long-term memory:

## When to use HMG
- **At task start**: Call `memory_agent_brief` to retrieve context from prior sessions.
- **Before risky edits**: Call `memory_recall` to check if prior decisions affect the change.
- **When durable facts appear**: Call `memory_memorize` for decisions, root causes, constraints.
- **When memory is stale**: Call `memory_correct` instead of writing conflicting facts.
- **At task end**: Call `memory_handoff` with what changed, why, and next steps.

## When NOT to use HMG
- Do not store ephemeral command output, secrets, tokens, or raw credentials.
- Do not call HMG for trivial operations that don't benefit from persistence.

## Scope
Prefer branch-aware scope for coding tasks:
- `domain_pack_id: "software-engineering"`
- Set `tenant_id`, `workspace`, `repository`, `branch` from the current project context.
```

Customize the wording and format to match your agent's prompt conventions. Some agents use XML tags, some use markdown, some have a specific file location for system instructions.

#### 3c. `example-session.md` — End-to-End Usage Example

Show a realistic agent session that uses HMG at each lifecycle point:

```markdown
# Example: <Agent> Session with HMG Memory

## Session Start

The agent calls `memory_agent_brief`:

→ memory_agent_brief({
    query: "current task status and recent decisions",
    domain_pack_id: "software-engineering"
  })

← Brief:
  - Last session: implemented JWT auth middleware
  - Decision: use RS256 over HS256 for asymmetric key verification
  - Risk: token revocation not yet implemented
  - Next step: add token blacklist endpoint

## During Task — Storing a Decision

→ memory_memorize({
    content: "Decided to use Redis for token blacklist with TTL matching JWT expiry",
    source: "architecture-review",
    domain_pack_id: "software-engineering"
  })

← Stored atoms: [01KSM3ABC...]

## Before Risky Edit — Recalling Context

→ memory_recall({
    query: "auth middleware JWT token decisions",
    domain_pack_id: "software-engineering"
  })

← Recall:
  [0.92] Decided to use Redis for token blacklist
  [0.87] Use RS256 over HS256
  [0.71] Token revocation not yet implemented — risk

## Session End — Handoff

→ memory_handoff({
    summary: "Implemented token blacklist endpoint using Redis. Tests pass (12/12).
              Remaining: integrate blacklist check in auth middleware."
  })
```

#### 3d. `README.md` — Integration Guide

The primary document that other users will follow to set up your adapter:

```markdown
# <Agent> × HMG Integration

## Prerequisites

- HMG installed (`curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh`)
- HMG daemon running (`hmg daemon start`)

## Setup

### 1. Configure <Agent>

Copy `<agent-name>-mcp.json` to <agent>'s config directory:

```bash
cp <agent-name>-mcp.json ~/.config/<agent-name>/mcp-servers.json
```

### 2. Add System Prompt

Append `hmg-<agent-name>-prompt.md` to your <agent> system prompt, or place it in:

```
<path-to-agent-prompts-directory>/
```

### 3. Verify

```bash
hmg doctor
```

## Files

| File | Purpose |
|------|---------|
| [`<agent-name>-mcp.json`](<agent-name>-mcp.json) | MCP server config |
| [`hmg-<agent-name>-prompt.md`](hmg-<agent-name>-prompt.md) | System prompt fragment |
| [`example-session.md`](example-session.md) | Example session walkthrough |

## How It Works

<Agent> discovers HMG's MCP tools at startup. When the agent encounters a task that benefits from memory:

1. **Session start** → calls `memory_agent_brief` to recall prior context
2. **Before edits** → calls `memory_recall` to check related decisions
3. **New decisions** → calls `memory_memorize` to persist
4. **Stale info** → calls `memory_correct` to update
5. **Session end** → calls `memory_handoff` for the next session
```

### Step 4: (Optional) SDK-Based Integration

If your agent has a plugin/extension system and doesn't support MCP natively, you may need to write a thin integration layer using the SDK:

**Python:**
```python
from hmg import HmgClient, software_engineering_context

client = HmgClient(base_url="http://localhost:7654")

# Session start
brief = client.recall({"query": "current task", "domain_pack_id": "software-engineering"})

# Store a decision
client.memorize({
    "content": "Use event-sourcing for audit log",
    "source": "architecture-review",
    "domain_pack_id": "software-engineering",
    "context": software_engineering_context("tenant-acme", "platform", "my-repo", "main")
})
```

**TypeScript:**
```typescript
import { HmgClient } from "@hmg_ai/sdk-ts";

const client = new HmgClient({ baseUrl: "http://localhost:7654" });

// Session start
await client.recall({ query: "current task", domainPackId: "software-engineering" });

// Store a decision
await client.memorize({
  content: "Chose Redis for session caching",
  source: "architecture-review",
  domainPackId: "software-engineering",
});
```

Include the plugin code in your adapter directory alongside the config files.

### Step 5: Submit the PR

```bash
git add examples/agent-adapter/<agent-name>/
git commit -s -m "feat: add <agent-name> agent adapter"
git push origin add-<agent-name>-adapter
# Open PR against HMG-public/main
```

#### PR Checklist

- [ ] All commits signed off (DCO: `git commit -s`)
- [ ] No proprietary algorithm details in code or comments
- [ ] No real user data, secrets, or internal endpoints
- [ ] README clearly explains setup steps
- [ ] MCP config is correct (verify with `hmg doctor`)
- [ ] System prompt follows the recommended lifecycle pattern
- [ ] Example session demonstrates all five lifecycle hooks

## Reference Architecture

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
                      │ MCP / HTTP / SDK
                      ▼
              ┌──────────────┐
              │  hmg-server  │
              │  (port 7654) │
              └──────────────┘
```

## Promotion to Built-in Adapter

If your community adapter sees significant adoption:

1. Open a [GitHub Issue](https://github.com/HMG-AI/HMG-public/issues) with the label `adapter-promotion`
2. Include: download/adoption metrics, community feedback, known edge cases
3. The HMG core team will evaluate and, if approved, implement a built-in adapter in the next release

Built-in adapters get:
- `hmg init --agent <name>` one-command setup
- `hmg doctor --agent <name>` automatic diagnostics
- `hmg setup` auto-detection
- `hmg doctor --fix` auto-repair

## Existing Examples

| Adapter | Path |
|---------|------|
| Hermes | [`examples/agent-adapter/hermes/`](../../examples/agent-adapter/hermes/) |

Use any existing adapter as a template for your contribution.

## Questions?

- 💬 [GitHub Discussions](https://github.com/HMG-AI/HMG-public/discussions) — integration questions
- 🐛 [GitHub Issues](https://github.com/HMG-AI/HMG-public/issues) — bugs and feature requests
- 📧 monkseekee@gmail.com — security and private inquiries
