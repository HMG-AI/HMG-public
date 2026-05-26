<p align="center">
  <img src="docs/img/logovideo.gif" alt="HMG Logo" width="360" style="border-radius:12px;" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.9.2-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/license-Apache--2.0%20%7C%20Community-green.svg" alt="License">
  <img src="https://img.shields.io/badge/rust-1.85%2B-orange.svg" alt="Rust">
  <img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg" alt="Platform">
</p>

<h1 align="center">HMG — Agent Memory That Actually Works</h1>

<p align="center">
  <strong>Holographic Memory Graph</strong> — a long-term memory kernel for AI agents.<br>
  Store decisions, trace corrections, govern knowledge. One tool call, complete answers.
</p>

<p align="center">
  <a href="https://hmg-ai.github.io/HMG-public/">🌐 多语言站点 / Site</a> ·
  <a href="https://github.com/HMG-AI/HMG-public/releases">📦 Releases</a> ·
  <a href="docs/getting-started.md">📖 Docs</a> ·
  <a href="#quick-start">🚀 Quick Start</a> ·
  <a href="#sdks">SDKs</a>
</p>

---

## Quick Start

```bash
# Install (auto-detects OS and CPU)
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh

# Initialize
hmg init -g

# Start daemon
hmg daemon start

# Store your first memory
curl -s -X POST http://127.0.0.1:3000/api/memorize \
  -H 'Content-Type: application/json' \
  -d '{"content": "My first HMG memory!"}'
```

## 🌐 Multilingual Site

**[hmg-ai.github.io/HMG-public](https://hmg-ai.github.io/HMG-public/)** — bilingual (中文/English) with one-click toggle.

## 📦 Community Edition Releases

Prebuilt binaries for 4 platforms, published via [GitHub Releases](https://github.com/HMG-AI/HMG-public/releases):

| Platform | Download |
|----------|----------|
| Linux x86_64 | `hmg-{version}-x86_64-unknown-linux-gnu.tar.gz` |
| Linux ARM64 | `hmg-{version}-aarch64-unknown-linux-gnu.tar.gz` |
| macOS Intel | `hmg-{version}-x86_64-apple-darwin.tar.gz` |
| macOS Apple Silicon | `hmg-{version}-aarch64-apple-darwin.tar.gz` |

Or use the one-command installer:
```bash
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
```

## Why HMG?

AI agents forget everything between sessions. HMG gives agents durable, queryable, governable long-term memory:

- **Memorize** decisions, root causes, constraints, and validation outcomes
- **Recall** the right context at the right time with branch-aware scope
- **Correct** memories when they go stale — full correction history retained
- **Govern** sensitive knowledge — quarantine, seal, or derive lessons

## Features

| Feature | Description |
|---------|-------------|
| One-Shot Recall | One MCP call for complete session context |
| Branch-Aware Scope | tenant → workspace → repository → branch |
| Governance Control Plane | Quarantine, seal, tombstone, derive lessons |
| Local-First | Fjall embedded storage, zero dependencies |
| 8 MCP Tools | memorize, recall, correct, govern, history, handoff, agent_brief, stats |
| Open Protocol | hmg-protocol (Apache-2.0) standalone crate |

## Editions

| | Community (Free) | Developer ($12/mo) | Enterprise |
|---|---|---|---|
| Memory atoms | 50,000 | Unlimited | Unlimited |
| Agents / instance | 5 | Unlimited | Unlimited |
| MCP tools | 8 core | 8 + observation | All |
| One-Shot Recall | — | ✓ | ✓ |
| Vector search | — | ✓ | ✓ |
| SSO / RBAC | — | — | ✓ |
| Domain packs | — | software-engineering | All |

Single binary, runtime edition detection. Upgrade with `hmg license apply`.

## SDKs

### Python
```bash
pip install hmg-sdk
```
```python
import hmg
client = hmg.HmgClient()
client.memorize("key decision: use Rust for perf")
```

### TypeScript
```bash
npm install @hmg_ai/sdk-ts
```
```typescript
import { HmgClient } from "@hmg_ai/sdk-ts";
const client = new HmgClient();
await client.memorize({ content: "decision noted" });
```

## Documentation

| Document | Description |
|----------|-------------|
| [Getting Started](docs/getting-started.md) | Install → first memory in 5 minutes |
| [Concepts](docs/concepts.md) | Memory atoms, correction, governance, scope |
| [Architecture](docs/architecture.md) | High-level system overview |
| [API Reference](docs/api-reference.md) | MCP tools and HTTP endpoints |
| [FAQ](docs/faq.md) | Common questions |
| [Upgrade Guide](docs/upgrade.md) | Upgrading to Developer/Enterprise |

## Repository Structure

```
├── site/              # Multilingual static site (GitHub Pages)
├── scripts/
│   └── install.sh     # One-command installer
├── docs/              # Documentation (Markdown)
├── mcp/schemas/       # MCP tool definitions
├── openapi/           # OpenAPI (Community Edition surface)
├── protocol/          # hmg-protocol crate (Apache-2.0)
├── sdk-python/        # Python SDK
├── sdk-ts/            # TypeScript SDK
├── certification/     # Conformance tests
├── examples/          # Quickstart examples
└── pi-agent/          # pi (Codex) integration
```

## Community

- **Issues**: [github.com/HMG-AI/HMG-public/issues](https://github.com/HMG-AI/HMG-public/issues)
- **Discussions**: [github.com/HMG-AI/HMG-public/discussions](https://github.com/HMG-AI/HMG-public/discussions)
- **Security**: [github.com/HMG-AI/HMG-public/security](https://github.com/HMG-AI/HMG-public/security)

## License

- **Protocol & SDK artifacts**: [Apache-2.0](LICENSE)
- **Community Edition binary**: [LICENSE-COMMUNITY](LICENSE-COMMUNITY) (free use, no redistribution)

---

<p align="center">
  <a href="https://hmg-ai.github.io/HMG-public/">🌐 Site</a> ·
  <a href="https://funcode.xin/HMG/">🏠 Website</a> ·
  <a href="https://github.com/HMG-AI/HMG-public/releases">📦 Releases</a>
</p>
