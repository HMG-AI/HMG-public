<p align="center">
  <img src="docs/img/logovideo.gif" alt="HMG Logo" width="360" style="border-radius:12px;" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.9.2-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/license-Apache--2.0%20%7C%20Community-green.svg" alt="License">
  <img src="https://img.shields.io/badge/rust-1.85%2B-orange.svg" alt="Rust">
  <img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey.svg" alt="Platform">
</p>

<h1 align="center">HMG — Agent Memory That Actually Works</h1>

<p align="center">
  <strong>Holographic Memory Graph</strong> — a long-term memory kernel for AI agents.<br>
  Store decisions, trace corrections, govern knowledge. One tool call, complete answers.
</p>

<p align="center">
  <a href="https://hmg-ai.github.io/HMG-public/">🌐 多语言站点 / Site</a> ·
  <a href="https://github.com/HMG-AI/HMG-public/releases">📦 Releases</a> ·
  <a href="docs/md/getting-started.md">📖 Docs</a> ·
  <a href="#quick-start">🚀 Quick Start</a> ·
  <a href="#sdks">SDKs</a>
</p>

---

## Quick Start

### Linux
```bash
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
```

### macOS
```bash
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
# Note: macOS binaries are in CI pipeline. Linux x86_64 is available now.
```

### Windows (PowerShell)
```powershell
irm https://github.com/HMG-AI/HMG-public/releases/latest/download/install.ps1 | iex
# Note: Windows binaries are in CI pipeline. Linux x86_64 is available now.
```

### WSL (Windows Subsystem for Linux)
```bash
# Works with Linux x86_64 binary today
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
```

### First Run (all platforms)
```bash
# Initialize + install agent adapters
hmg init -g

# Start memory service
hmg daemon start

# Store your first memory
curl -s -X POST http://127.0.0.1:3000/api/memorize \
  -H 'Content-Type: application/json' \
  -d '{"content": "My first HMG memory!"}'

# Verify
hmg doctor
```

## 🌐 Multilingual Site

**[hmg-ai.github.io/HMG-public](https://hmg-ai.github.io/HMG-public/)** — bilingual (中文/English) with one-click toggle.

## 📦 Platform Support

| Platform | Status |
|----------|--------|
| Linux x86_64 (glibc 2.31+) | ✅ [Download](https://github.com/HMG-AI/HMG-public/releases/latest) |
| Linux ARM64 | 🔜 CI pipeline |
| macOS Intel | 🔜 CI pipeline |
| macOS Apple Silicon | 🔜 CI pipeline |
| Windows x86_64 | 🔜 CI pipeline |

One-command installer (auto-detects platform):
```bash
# Linux / macOS
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh

# Windows (PowerShell)
irm https://github.com/HMG-AI/HMG-public/releases/latest/download/install.ps1 | iex
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
| Advanced Recall | One MCP call for complete session context |
| Branch-Aware Scope | tenant → workspace → repository → branch |
| Governance Control Plane | Quarantine, seal, tombstone, derive lessons |
| Local-First | Embedded storage, zero dependencies |
| 8 MCP Tools | memorize, recall, correct, govern, history, handoff, agent_brief, stats |
| Open Protocol | hmg-protocol (Apache-2.0) standalone crate |

## Editions

| | Community (Free) | Developer ($12/mo) | Enterprise |
|---|---|---|---|
| Memory atoms | 50,000 | Unlimited | Unlimited |
| Agents / instance | 5 | Unlimited | Unlimited |
| MCP tools | 8 core | 8 + observation | All |
| Advanced Recall | — | ✓ | ✓ |
| Vector search | — | ✓ | ✓ |
| SSO / RBAC | — | — | ✓ |
| Domain packs | — | software-engineering | All |

Single binary, runtime edition detection. Upgrade with `hmg license apply`.

## Agent Adapters

HMG works with **any** MCP-capable agent. Built-in adapters:

| Agent | Install Command |
|-------|---------------|
| pi (Codex) | `hmg init --agent pi` |
| Cursor | `hmg init --agent cursor` |
| Claude Code | `hmg init --agent claude` |
| Codex CLI | `hmg init --agent codex` |
| Generic MCP | `hmg init --agent generic-mcp` |

Building for a new agent? See [`examples/agent-adapter/`](examples/agent-adapter/) for templates and guides.

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
| [Getting Started](docs/md/getting-started.md) | Install → first memory in 5 minutes |
| [Concepts](docs/md/concepts.md) | Memory atoms, correction, governance, scope |
| [Architecture](docs/md/architecture.md) | High-level system overview |
| [API Reference](docs/md/api-reference.md) | MCP tools and HTTP endpoints |
| [FAQ](docs/md/faq.md) | Common questions |
| [Upgrade Guide](docs/md/upgrade.md) | Upgrading to Developer/Enterprise |

## Repository Structure

```
├── docs/              # GitHub Pages site + documentation
│   ├── index.html     # Multilingual landing page
│   ├── img/           # Screenshots and assets
│   └── md/            # Documentation (Markdown, 11 languages)
├── scripts/
│   └── install.sh     # One-command installer
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
  <a href="https://hmg2ai.com/">🏠 Website</a> ·
  <a href="https://github.com/HMG-AI/HMG-public/releases">📦 Releases</a>
</p>
