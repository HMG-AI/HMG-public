# HMG Examples

Integration quickstarts and synthetic data for HMG Community Edition.

## Quickstarts

| Language | File | Description |
|---|---|---|
| Python | [`quickstart.py`](quickstart.py) | Memorize, recall, correct, govern via Python SDK |
| TypeScript | [`quickstart.ts`](quickstart.ts) | Memorize, recall, correct, govern via TypeScript SDK |
| MCP (raw) | See [API Reference](../docs/api-reference.md) | Direct MCP tool calls |
| HTTP (curl) | See [API Reference](../docs/api-reference.md) | REST API examples |

## Prerequisites

Start a local HMG daemon:

```bash
# Install HMG
curl -L https://hmg2ai.com/install.sh | sh

# Start the daemon
hmg daemon start
```

## Python

```bash
pip install hmg-sdk
python quickstart.py
```

```python
from hmg import HMGClient

client = HMGClient(base_url="http://localhost:3000")

# Store a decision
client.memorize(
    content="We chose PostgreSQL for the main database",
    source="architecture-review",
)

# Recall memories
result = client.recall(query="database choice")
for atom in result.atoms:
    print(f"[{atom.score:.2f}] {atom.text}")
```

## TypeScript

```bash
npm install @hmg_ai/sdk-ts
npx ts-node quickstart.ts
```

```typescript
import { HMGClient } from "@hmg_ai/sdk-ts";

const client = new HMGClient({ baseUrl: "http://localhost:3000" });

await client.memorize({
  content: "API uses JWT tokens with 24h expiry",
  domain_pack_id: "software-engineering",
});

const result = await client.recall({ query: "authentication approach" });
for (const atom of result.atoms) {
  console.log(atom.text);
}
```

## Synthetic Fixtures

The [`synthetic-fixtures/`](synthetic-fixtures/) directory contains sample atom data for testing integrations. No real user data is included — all fixtures are synthetic.

## Agent Adapters

[`agent-adapter/`](agent-adapter/) contains integration templates for connecting third-party AI agents to HMG. Each adapter is pure configuration — no HMG binary changes needed.

| Agent | Directory |
|-------|-----------|
| Hermes (example) | [`agent-adapter/hermes/`](agent-adapter/hermes/) |

To add your own agent, see the [Agent Adapter Development Guide](agent-adapter/README.md).

## More Resources

- [Getting Started](../docs/getting-started.md) — full setup guide
- [API Reference](../docs/api-reference.md) — all tools and endpoints
- [Concepts](../docs/concepts.md) — memory atoms, correction, governance

## License

Apache-2.0
