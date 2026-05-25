<p align="center">
  <img src="https://img.shields.io/badge/version-0.9.2-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/license-Apache--2.0-green.svg" alt="License">
  <img src="https://img.shields.io/badge/rust-1.85%2B-orange.svg" alt="Rust">
  <img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg" alt="Platform">
</p>

<h1 align="center">HMG — Agent Memory That Actually Works</h1>

<p align="center">
  <strong>Holographic Memory Graph</strong> — a long-term memory kernel for AI agents.<br>
  Store decisions, trace corrections, govern knowledge. One tool call, complete answers.
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> ·
  <a href="#features">Features</a> ·
  <a href="#editions">Editions</a> ·
  <a href="docs/getting-started.md">Docs</a> ·
  <a href="#sdks">SDKs</a> ·
  <a href="#community">Community</a>
</p>

---

## Why HMG?

AI agents forget everything between sessions. They make the same mistakes, re-learn the same preferences, and lose critical context at every restart.

**HMG fixes this.** It gives agents durable, queryable, governable long-term memory:

- **Memorize** decisions, root causes, constraints, and validation outcomes
- **Recall** the right context at the right time with branch-aware scope
- **Correct** memories when they go stale — full correction history retained
- **Govern** sensitive knowledge — quarantine, seal, or derive lessons

Unlike vector databases or simple key-value stores, HMG models memory as a **typed graph** with polarity, epistemic state, exposure governance, and correction lineage. This isn't just storage — it's knowledge management designed for agents.

## Quick Start

```bash
# Install (Linux / macOS)
curl -L https://funcode.xin/HMG/install.sh | sh

# Start the memory service
hmg daemon start

# Your agent can now use memory
hmg init --agent cursor     # Cursor
hmg init --agent pi         # pi (Codex fork)
hmg init --agent claude     # Claude Code
```

That's it. Your agent now has durable, cross-session memory. No database to set up, no cloud account needed.

### First memory (manual test)

```bash
# Store a decision
hmg memorize "We use PostgreSQL for the main database" --source "architecture-review"

# Recall it later
hmg recall "database choice"
# → [0.92] We use PostgreSQL for the main database (architecture-review, 2026-05-25)

# Correct when it changes
hmg correct <atom-id> --action replace --content "We migrated to CockroachDB for horizontal scale"
```

## Features

| Feature | What it does |
|---|---|
| 🧠 **Typed Memory Atoms** | Store decisions, facts, observations with polarity and epistemic state |
| 🔄 **Correction History** | Append-only corrections with full lineage — never lose why something changed |
| 🛡️ **Governance** | Quarantine sensitive data, seal secrets, derive lessons from incidents |
| 🌿 **Branch-Aware Scope** | Memory scoped to workspace → repository → branch — coding agents get the right context |
| 📋 **Agent Tool Output Contract** | Structured YAML/JSON output designed for agent consumption, not humans |
| 🔧 **8 MCP Tools** | `memory_memorize`, `memory_recall`, `memory_correct`, `memory_govern`, and more |
| 🌍 **15 Locales** | TUI and output localization: English, Chinese, Japanese, Korean, French, German, Spanish, etc. |
| 🔌 **7 Agent Integrations** | Cursor, pi, Claude Code, Codex, Windsurf, Aider, Continue — one-command setup |
| 📜 **Open Protocol** | Wire-safe DTO types, OpenAPI spec, and certification suite — build your own implementation |

## Editions

| Feature | Community | Developer | Enterprise |
|---|---|---|---|
| **Price** | Free | $99/year (local) / $19/month (cloud) | Custom |
| **Memory atoms** | 50,000 | Unlimited | Unlimited |
| **Search** | Keyword | One-Shot Recall (semantic) | One-Shot Recall (semantic) |
| **Consolidation** | — | Automated | Automated + configurable |
| **Domain Packs** | — | software-engineering | All packs |
| **Agents per instance** | 5 | Unlimited | Unlimited |
| **Instances per org** | 5 | Unlimited | Unlimited |
| **SSO / RBAC** | — | — | ✅ SAML/OIDC/SCIM |
| **Audit export** | — | — | ✅ |
| **SLA + support** | Community (GitHub) | Email | Dedicated |

Community Edition is genuinely useful for daily work — full correction/governance lifecycle, keyword search, all 8 MCP tools, all agent integrations. No time bombs, no feature removal.

👉 **Pricing details:** https://funcode.xin/HMG/#pricing

## SDKs

### Python

```bash
pip install hmg-sdk
```

```python
from hmg import HMGClient

client = HMGClient(base_url="http://localhost:8080")
client.memorize("We chose PostgreSQL for the main database", source="agent")
result = client.recall("database choice")
for atom in result.atoms:
    print(f"[{atom.score:.2f}] {atom.text}")
```

📖 **Full docs:** [`sdk-python/`](sdk-python/)

### TypeScript

```bash
npm install @hmg_ai/sdk-ts
```

```typescript
import { HMGClient } from "@hmg_ai/sdk-ts";

const client = new HMGClient({ baseUrl: "http://localhost:8080" });
await client.memorize({ content: "API uses JWT tokens with 24h expiry" });
const result = await client.recall({ query: "authentication approach" });
```

📖 **Full docs:** [`sdk-ts/`](sdk-ts/)

## Protocol & Specification

HMG's wire protocol is open and versioned:

| Artifact | Description |
|---|---|
| [`spec/README.md`](spec/README.md) | Normative specification — atom lifecycle, correction, governance, scope, recall views |
| [`protocol/`](protocol/) | Wire-safe Rust DTO types (`hmg-protocol` crate) |
| [`openapi/hmg-server.yaml`](openapi/hmg-server.yaml) | HTTP API specification (Community Edition surface) |
| [`mcp/schemas/tools.json`](mcp/schemas/tools.json) | MCP tool JSON schemas |
| [`certification/`](certification/) | Conformance test suite — claim "HMG Compatible" |

### Implementing the protocol

Anyone may implement the HMG Protocol. Third-party implementations that pass the conformance suite may claim **"HMG Compatible"**. Only approved implementations may use **"HMG Certified"**.

```bash
# Run conformance tests against your implementation
cd certification && cargo test
```

📖 **Trademark policy:** [`docs/trademark-policy.md`](docs/trademark-policy.md)

## Documentation

| Document | Description |
|---|---|
| [Getting Started](docs/getting-started.md) | Install → first memory in 5 minutes |
| [Concepts](docs/concepts.md) | Memory atoms, correction, governance, scope |
| [Architecture](docs/architecture.md) | System overview (high-level, no internals) |
| [API Reference](docs/api-reference.md) | All MCP tools and HTTP endpoints |
| [Correction & Governance](docs/correction-governance.md) | Deep dive into the correction/governance lifecycle |
| [Upgrade Guide](docs/upgrade.md) | Upgrading from Community to Developer/Enterprise |
| [FAQ](docs/faq.md) | Common questions |
| [Security](docs/security.md) | Security model and vulnerability reporting |
| [Changelog](docs/changelog.md) | Version history |
| [Trademark Policy](docs/trademark-policy.md) | Brand and logo usage |

## Community

- **Bug reports:** [GitHub Issues](https://github.com/HMG-AI/HMG-public/issues)
- **Feature requests:** [GitHub Discussions → Ideas](https://github.com/HMG-AI/HMG-public/discussions)
- **Questions:** [GitHub Discussions → Q&A](https://github.com/HMG-AI/HMG-public/discussions)
- **Security vulnerabilities:** See [`SECURITY.md`](SECURITY.md)

Please read our [Contributing Guide](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md).

## License

This repository contains artifacts under **two licenses**:

| Artifact | License |
|---|---|
| Protocol, SDK, MCP schemas, OpenAPI, examples, certification, docs | **[Apache-2.0](LICENSE)** |
| HMG Community Edition binary | **[Custom free-use license](LICENSE-COMMUNITY)** |

HMG is a product of 武汉凡尘合创科技有限公司 (Wuhan Fanchen Hechuang Technology Co., Ltd.).

---

<p align="center">
  <a href="https://funcode.xin/HMG/">Website</a> ·
  <a href="https://github.com/HMG-AI/HMG/releases">Downloads</a> ·
  <a href="https://funcode.xin/HMG/#pricing">Pricing</a> ·
  <a href="mailto:monkseekee@gmail.com">Contact</a>
</p>
