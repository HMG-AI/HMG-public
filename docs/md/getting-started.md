# Getting Started with HMG

## Prerequisites

- Linux (x86_64 or ARM64) or macOS (Intel or Apple Silicon)
- An AI agent or coding tool that supports MCP (Model Context Protocol)

## Install

```bash
curl -L https://funcode.xin/HMG/install.sh | sh
```

Or download directly from [GitHub Releases](https://github.com/HMG-AI/HMG/releases):

```bash
# Linux x86_64
curl -L https://github.com/HMG-AI/HMG/releases/latest/download/hmg-latest-x86_64-unknown-linux-gnu.tar.gz | tar -xzf - -C /usr/local/bin/

# macOS Apple Silicon
curl -L https://github.com/HMG-AI/HMG/releases/latest/download/hmg-latest-aarch64-apple-darwin.tar.gz | tar -xzf - -C /usr/local/bin/
```

## Verify

```bash
hmg --version
# hmg 0.9.2-community
```

![hmg --version output](../img/cli-version.png)

## Start the Memory Service

```bash
hmg daemon start
```

The daemon starts a local MCP server at `~/.local/share/hmg/stores/default` by default.
No data leaves your machine.

![hmg daemon status](../img/cli-daemon.png)

## Connect Your Agent

### Cursor

```bash
hmg init --agent cursor
# Restart Cursor. HMG tools appear in MCP settings.
```

### Claude Code (Codex)

```bash
hmg init --agent codex
```

![hmg init output](../img/cli-init.png)

### Pi

```bash
hmg init --agent pi
```

### Generic MCP Client

HMG exposes a standard MCP server over stdio. Configure your client to run:

```json
{
  "mcpServers": {
    "hmg": {
      "command": "hmg-server",
      "args": ["~/.local/share/hmg/stores/default"]
    }
  }
}
```

## Verify Your Setup

```bash
hmg doctor
```

`hmg doctor` checks all integrations, daemon status, and MCP readiness:

![hmg doctor output](../img/cli-doctor.png)

## Detect Available Agents

```bash
hmg integrations detect
```

![hmg integrations detect](../img/cli-integrations.png)

## First Memory

Use any MCP tool to store and retrieve memories:

```json
// Store a decision
{
  "tool": "memory_memorize",
  "arguments": {
    "content": "Decision: Use PostgreSQL for user data. Rationale: ACID compliance and mature tooling.",
    "source": "architecture-review",
    "modality": "text"
  }
}

// Recall later
{
  "tool": "memory_recall",
  "arguments": {
    "query": "What database did we choose?"
  }
}
```

![Agent calling memory_memorize](../img/agent-memorize.png)

![Agent calling memory_recall](../img/agent-recall.png)

## Edition and License

Check your current edition and feature limits:

```bash
hmg license status
```

![hmg license status](../img/cli-license.png)

## What's Available in Community Edition

| Feature | Available |
|---|---|
| Memory storage (memorize) | ✅ |
| Memory retrieval (recall) | ✅ Basic keyword search |
| Correction lifecycle | ✅ Full |
| Governance lifecycle | ✅ Full |
| MCP protocol | ✅ Full |
| HTTP API | ✅ Full |
| Agent integration | ✅ All adapters |
| One-Shot Recall Engine | ❌ Developer/Enterprise |
| Automated consolidation | ❌ Developer/Enterprise |
| Domain Packs | ❌ Developer/Enterprise |
| Semantic (vector) search | ❌ Developer/Enterprise |

## Next Steps

- [Concepts](concepts.md) — understand memory atoms, correction, governance, scope
- [Architecture](architecture.md) — how HMG works, plus TUI visual tour
- [API Reference](api-reference.md) — all MCP tools and HTTP endpoints
- [Correction and Governance](correction-governance.md)
- [FAQ](faq.md)
- [Upgrade to Developer](upgrade.md)
