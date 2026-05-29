# Hermes Agent × HMG Integration

Example adapter showing how to connect [Hermes](https://github.com/example/hermes) to HMG's memory service.

## Quick Setup

### 1. Install HMG

```bash
curl -fsSL https://raw.githubusercontent.com/HMG-AI/HMG-public/main/scripts/install.sh | sh
hmg daemon start
```

### 2. Configure Hermes

Add the H MCP server to Hermes's config. Copy `hermes-mcp.json` to Hermes's config directory:

```bash
cp hermes-mcp.json ~/.config/hermes/mcp-servers.json
```

### 3. Add System Prompt

Append `hmg-hermes-prompt.md` to your Hermes system prompt, or place it in Hermes's prompts directory.

### 4. Verify

```bash
hmg doctor
```

## Files

| File | Purpose |
|------|---------|
| [`hermes-mcp.json`](hermes-mcp.json) | MCP server config for Hermes |
| [`hmg-hermes-prompt.md`](hmg-hermes-prompt.md) | System prompt fragment for HMG memory usage |
| [`example-session.md`](example-session.md) | Example Hermes session using HMG |

## How It Works

Hermes discovers HMG's MCP tools at startup. When Hermes encounters a task that benefits from memory:

1. **Session start** → calls `memory_agent_brief` to recall prior context
2. **Before edits** → calls `memory_recall` to check related decisions
3. **New decisions** → calls `memory_memorize` to persist
4. **Stale info** → calls `memory_correct` to update
5. **Session end** → calls `memory_handoff` for the next session

No changes to HMG's binary are needed — this is purely configuration.

## Extending for Other Agents

Use this as a template for any MCP-capable agent:

1. Copy `hermes-mcp.json` and adapt the `mcpServers` key name
2. Copy `hmg-hermes-prompt.md` and customize for your agent's prompt format
3. Submit a PR to `examples/agent-adapter/your-agent/`
