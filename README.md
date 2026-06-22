<p align="center">
  <img src="docs/img/logovideo.gif" alt="HMG Logo" width="360" style="border-radius:12px;" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.6.1-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/license-Apache--2.0%20%7C%20Community-green.svg" alt="License">
  <img src="https://img.shields.io/badge/rust-1.85%2B-orange.svg" alt="Rust">
  <img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey.svg" alt="Platform">
</p>

<h1 align="center">HMG — Agent Memory That Actually Works</h1>

<p align="center">
  <strong>Holographic Memory Graph</strong> — branch-aware, auditable, governable long-term memory kernel for coding agents.<br>
  Store decisions, trace corrections, govern knowledge. One tool call, complete answers.
</p>

<p align="center">
  <a href="https://hmg-ai.github.io/HMG-public/">🌐 Docs</a> ·
  <a href="https://github.com/HMG-AI/HMG-public/releases">📦 Releases</a> ·
  <a href="https://hmg1ai.com/">🏠 Website</a> ·
  <a href="#quick-start">🚀 Quick Start</a>
</p>

---

## Quick Start

```bash
# Install (Linux / macOS)
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh

# Initialize + start
hmg init -g
hmg daemon start
```

```powershell
# Install (Windows PowerShell)
irm https://github.com/HMG-AI/HMG-public/releases/latest/download/install.ps1 | iex

# Initialize + start
hmg init -g
hmg daemon start

# Store your first memory
curl -s -X POST http://127.0.0.1:7654/api/memorize \
  -H 'Content-Type: application/json' \
  -d '{"content": "My first HMG memory!"}'

# Verify everything works
hmg doctor
```

## Agent Memory Loop

```
capture → canonicalize → recall → correct → govern → consolidate → brief next session
```

Every coding agent session becomes context for the next. Decisions persist. Corrections leave history. Governance controls what gets remembered.

```python
# Store a decision
memory_memorize(content="Use Rust for performance-critical paths", source="ADR-001")

# Next session: agent gets full context
memory_agent_brief(domain_pack_id="software-engineering")
# → scope, status, decisions, risks, next steps

# Correct stale knowledge
memory_correct(target_atom="01ABC...", action="replace", new_content="Use Rust + WASM")

# Govern sensitive data
memory_govern(target_atom="01DEF...", action="seal", reason="contains API key")
```

## Editions

<!-- MANIFEST:START -->
| | Community (Free) | Developer ($19/mo) | Enterprise |
|---|---|---|---|
| Memory atoms | 100,000 | Unlimited | Unlimited |
| Semantic search | ✓ | ✓ | ✓ |
| One-Shot Recall | ✓ | ✓ | ✓ |
| Correction + Governance | ✓ | ✓ | ✓ |
| Observation capture | ✓ | ✓ | ✓ |
| Domain pack | software-engineering | software-engineering | All |
| Consolidation | — | ✓ (auto) | ✓ (full) |
| Intelligent lifecycle | — | ✓ | ✓ |
| SSO / RBAC | — | — | ✓ |
<!-- MANIFEST:END -->

Single binary, runtime edition detection. No reinstall needed. Upgrade with `hmg license apply <key>`.

## Agent Adapters

| Agent | Command |
|-------|---------|
| pi (Codex) | `hmg init --agent pi` |
| Cursor | `hmg init --agent cursor` |
| Claude Code | `hmg init --agent claude` |
| Codex CLI | `hmg init --agent codex` |
| Any MCP client | `hmg init --agent generic-mcp` |

## SDKs

```bash
# Python
pip install hmg-sdk
```
```python
import hmg
client = hmg.HmgClient()
client.memorize("key decision: use Rust for perf")
```

```bash
# TypeScript
npm install @hmg_ai/sdk-ts
```
```typescript
import { HmgClient } from "@hmg_ai/sdk-ts";
const client = new HmgClient();
await client.memorize({ content: "decision noted" });
```

## Open Standard + Free Community Binary + Proprietary Memory Intelligence Engine

This repository contains the **public artifacts** for HMG:

- **Protocol**: [`protocol/`](protocol/) — hmg-protocol (Apache-2.0) standalone crate
- **MCP Schemas**: [`mcp/schemas/`](mcp/schemas/) — tool definitions
- **OpenAPI**: [`openapi/`](openapi/) — HTTP API spec
- **SDKs**: [`sdk-python/`](sdk-python/), [`sdk-ts/`](sdk-ts/)
- **Certification**: [`certification/`](certification/) — conformance tests
- **Docs**: [`docs/`](docs/) — multilingual documentation
- **Installers**: [`scripts/`](scripts/) — install.sh, install.ps1

The core memory engine is proprietary. This repository exists so developers can **install, integrate, verify, and implement compatible protocols**.

## Documentation

| | |
|---|---|
| [Getting Started](docs/md/getting-started.md) | Install → first memory in 5 minutes |
| [Concepts](docs/md/concepts.md) | Memory atoms, correction, governance, scope |
| [API Reference](docs/md/api-reference.md) | MCP tools and HTTP endpoints |
| [Architecture](docs/md/architecture.md) | System overview |
| [FAQ](docs/md/faq.md) | Common questions |

## Links

- **Website**: [hmg1ai.com](https://hmg1ai.com/)
- **Docs**: [hmg-ai.github.io/HMG-public](https://hmg-ai.github.io/HMG-public/)
- **Releases**: [GitHub Releases](https://github.com/HMG-AI/HMG-public/releases)
- **Issues**: [GitHub Issues](https://github.com/HMG-AI/HMG-public/issues)
- **Security**: [GitHub Security](https://github.com/HMG-AI/HMG-public/security)
- **Contributing**: [CONTRIBUTING.md](CONTRIBUTING.md)

## License

- **Protocol & SDK artifacts**: [Apache-2.0](LICENSE)
- **Community Edition binary**: [LICENSE-COMMUNITY](LICENSE-COMMUNITY) (free use, no redistribution)
