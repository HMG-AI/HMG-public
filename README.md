<p align="center">
  <img src="docs/img/logovideo.gif" alt="HMG Logo" width="360" style="border-radius:12px;" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.4.5-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/license-Apache--2.0%20%7C%20Community-green.svg" alt="License">
  <img src="https://img.shields.io/badge/rust-1.85%2B-orange.svg" alt="Rust">
  <img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey.svg" alt="Platform">
  <img src="https://img.shields.io/badge/tools-37_MCP-purple.svg" alt="MCP Tools">
  <img src="https://img.shields.io/badge/adapters-19_hooks-teal.svg" alt="Adapters">
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

### Linux / macOS

```bash
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
hmg init -g
hmg daemon start
```

### Windows PowerShell

```powershell
irm https://github.com/HMG-AI/HMG-public/releases/latest/download/install.ps1 | iex
hmg init -g
hmg daemon start
```

### Store and Verify

```bash
curl -s -X POST http://127.0.0.1:3000/api/memorize \
  -H 'Content-Type: application/json' \
  -d '{"content": "My first HMG memory!"}'

hmg doctor
hmg --version
# hmg 1.4.5-community
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

## Latest Progress

- **World-Class Recall (v1.4)**: de-over-fitted ranking — hardcoded evaluation fixtures removed. Held-out Top-1 95.4%, real-decision corpus Top-1 85%, zero false attribution. Unified CJK tokenization, evidence-first reranking.
- **37 MCP Tools**: expanded from 8 tools to 37 — `query_intent`, `panorama`, `secret_store`, `observation_capture/promote`, `noise_feedback`, `export_snapshot`, `knowledge_health`, `communities`, `intent_evolution`, `antifragile_analyze`, `counterfactuals`, and more.
- **19 Agent Adapters**: hook-first ecosystem with doctor-verifiable lifecycle support. See the full list below.
- **General-Memory + Auto Domain Router**: automatic routing between `software-engineering` and `general-memory` domains. NERE/GliNER entity labels provide routing evidence. Users no longer need to manually specify `domain_pack_id`.
- **Secret Vault**: AES-256-GCM credential storage with server-side use authorization.
- **199K+ LoC Rust**: production-grade codebase with comprehensive test coverage.
- **Stable release v1.4.5**: world-class recall de-over-fitting, 6-platform builds (Linux x86_64/ARM64, macOS Intel/Apple Silicon, Windows x86_64/ARM64), hook-first 19-adapter ecosystem, General Memory Domain Router, Secret Service, and a 1,837+ test baseline.

## Editions

<!-- MANIFEST:START -->
| | Community (Free) | Developer ($19/mo) | Enterprise |
|---|---|---|---|
| Memory atoms | 100,000 | Unlimited | Unlimited |
| Semantic vectors | 5,000 | Unlimited | Unlimited |
| One-Shot Recall | ✓ | ✓ | ✓ |
| Correction + Governance | ✓ | ✓ | ✓ |
| Observation capture | ✓ | ✓ | ✓ |
| Observation promotion | — | ✓ | ✓ |
| Credential vault | ✓ | ✓ | ✓ |
| Domain pack | software-engineering | software-engineering | All |
| MemoryQL + Panorama | — | ✓ | ✓ |
| Consolidation | Manual | ✓ (auto) | ✓ (full) |
| SSO / RBAC | — | — | ✓ |
<!-- MANIFEST:END -->

Single binary, runtime edition detection. No reinstall needed. Use `hmg license request`, then upgrade with `hmg license apply <key>` and verify with `hmg license status`.

## Agent Adapters

| Agent | Command | Support level |
|-------|---------|---------------|
| pi (Codex) | `hmg init --agent pi` | Packaged first-class |
| Cursor | `hmg init --agent cursor` | Hook-first |
| Claude Code | `hmg init --agent claude` | Hook-first |
| Codex CLI | `hmg init --agent codex` | Hook-first |
| VS Code | `hmg init --agent vscode` | Hook-first |
| OpenClaw | `hmg init --agent openclaw` | Hook-first |
| Hermes | `hmg init --agent hermes` | Hook-first |
| Windsurf | `hmg init --agent windsurf` | Hook-first |
| Continue | `hmg init --agent continue` | Hook-first |
| Cline | `hmg init --agent cline` | Hook-first |
| Roo Code | `hmg init --agent roo-code` | Hook-first |
| Zed | `hmg init --agent zed` | Hook-first |
| Aider | `hmg init --agent aider` | Hook-first |
| OpenHands | `hmg init --agent openhands` | Hook-first |
| Goose | `hmg init --agent goose` | Hook-first |
| Gemini CLI | `hmg init --agent gemini-cli` | Hook-first |
| Qwen Code | `hmg init --agent qwen-code` | Hook-first |
| OpenCode | `hmg init --agent opencode` | Hook-first |
| Any MCP client | `hmg init --agent generic-mcp` | MCP-compatible |

**Framework recipes**: AutoGen, CrewAI, Semantic Kernel, LlamaIndex.

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
- **MCP Schemas**: [`mcp/schemas/`](mcp/schemas/) — 37 tool definitions
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
| [Public Release SOP](docs/md/standard-release-sop.md) | Public release and documentation checklist |
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
