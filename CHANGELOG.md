# Changelog

All notable changes to the HMG public protocol, SDKs, and documentation are documented here.

For binary release notes, see [GitHub Releases](https://github.com/HMG-AI/HMG-public/releases).

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Hook-first agent ecosystem expansion: 19 declared adapters with doctor-verifiable lifecycle support (pi, Cursor, Claude Code, Codex, VS Code, OpenClaw, Hermes, Windsurf, Continue, Cline, Roo Code, Zed, Aider, OpenHands, Goose, Gemini CLI, Qwen Code, OpenCode, generic MCP).
- General-memory domain pack: 16 object kinds, 9 recall views, workspace/subject/thread scope for non-coding durable memory.
- Automatic domain router: heuristic-based routing between `software-engineering` and `general-memory` — users no longer need to manually specify `domain_pack_id`.
- NERE/GliNER-assisted routing: 17 entity labels feed into routing decisions for higher accuracy.
- 37 MCP tools total (up from 20+), including: `query_intent`, `panorama_query`, `panorama_impact`, `observation_capture/promote/forget/config`, `secret_store/use/reveal/rotate/revoke`, `noise_feedback`, `export_snapshot`, `knowledge_health`, `communities`, `intent_evolution`, `antifragile_analyze`, `counterfactuals`, and more.
- Secret vault service (SRV-002): AES-256-GCM credential storage with server-side use authorization without revealing payloads.
- Framework recipes planned for AutoGen, CrewAI, Semantic Kernel, and LlamaIndex using HMG HTTP/SDK surfaces.
- 193K LoC Rust codebase.
- Adapter lifecycle eval module with cross-session scenarios.
- HMG Desktop source-boundary decision documented.

### Changed

- MCP tool schemas expanded to 37 tools in `mcp/schemas/tools.json`.
- `public-manifest.json` updated with all 37 public MCP tools, expanded HTTP and CLI surfaces, SDK version bumps.
- Public documentation separates stable release facts from development-branch progress.

## [1.2.1] — 2026-06-05

### Fixed

- Windows Named Pipe daemon IPC — `hmg daemon start/status/stop` now works on Windows
- Replace all `funcode.xin` URLs with `hmg2ai.com`
- Fix private repo links in documentation
- Replace truncated LICENSE with full Apache-2.0 text for proper GitHub license detection

## [1.2.0] — 2026-06-05

### Added

- NERE model manifest support for GliNER ONNX model management
- `hmg model` CLI command for model download, status, and removal
- 6 new TUI screens: Agent, Export, Panorama, Query, Secrets, NERE Models
- GliNER ONNX runtime integration with remote model loading

### Changed

- SDK versions updated to 1.2.0
- Protocol version updated to 1.2.0

## [1.0.0] — 2026-05-28

### Added

- **Three-tier edition model** — Community (free), Developer, Enterprise with quantitative caps
- **License system** — ed25519 asymmetric signatures, machine fingerprint binding, pure local verification
- **Community Edition elevation** — full One-Shot Recall Engine (P1-P9) and canonical ingest for all editions
- **Security hardening** — AES-256-GCM storage encryption, injection detection, RBAC hardening, SSRF protection
- **Binary hardening** — stripped ELF, LTO, XOR tier obfuscation, no debug symbols

### Changed

- Community Edition now includes full One-Shot Recall (P1-P9). Quantitative caps (50K atoms, 5 instances) drive conversion.
- Updated spec §14 (Edition Boundary) to reflect Community elevation.

## [0.9.2] — 2026-05-24

### Added

- **Agent Tool Output Contract v2** — structured YAML/JSON output with progressive disclosure for agent consumption ([spec §12](spec/README.md))
- **Mechanical Adoption Protocol** — one-command agent integration: `hmg init --agent <id>` ([spec §13](spec/README.md))
- **Normative specification** — 14 chapters covering atom lifecycle, correction, governance, scope, recall views, and edition boundary ([spec/README.md](spec/README.md))
- **Wire-safe protocol types** — Rust crate `hmg-protocol` with `AtomView`, `Polarity`, `EpistemicStatus`, `ExposureState`, `CorrectionAction`, `GovernanceAction`, `ScopeRef`, `MemoryContextView`, `RecallResponse`, `MemorizeAck`, `HandoffSummary`, `AgentBrief` ([protocol/](protocol/))
- **TypeScript SDK** — `@hmg_ai/sdk-ts` with full Community Edition API surface ([sdk-ts/](sdk-ts/))
- **Python SDK** — `hmg` with full Community Edition API surface ([sdk-python/](sdk-python/)
- **MCP tool schemas** — 8 tools: `memory_memorize`, `memory_recall`, `memory_correct`, `memory_govern`, `memory_handoff`, `memory_agent_brief`, `memory_history` ([mcp/schemas/tools.json](mcp/schemas/tools.json))
- **Conformance test suite** — 10 tests for HMG Compatible certification ([certification/](certification/))
- **OpenAPI specification** — Community Edition HTTP API surface ([openapi/hmg-server.yaml](openapi/hmg-server.yaml))
- **Pi agent package** — `@hmg_ai/pi-agent` for pi/Codex integration ([pi-agent/](pi-agent/))
- **Integration quickstarts** — Python and TypeScript examples with synthetic data ([examples/](examples/))
- **Public documentation** — getting started, API reference, correction/governance, upgrade guide, FAQ, security, architecture, concepts ([docs/](docs/))
- **Community infrastructure** — CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md
- **License** — Apache-2.0 for protocol artifacts; custom free-use license for binary
- **Trademark policy** — brand and logo usage guidelines
- **Multi-platform binary** — Linux x86_64, Linux ARM64, macOS Intel, macOS Apple Silicon

## [0.6.2] — 2026-05-17

### Added

- Initial public protocol types (atom, correction, governance, scope)
- Basic MCP tool definitions (5 tools)
- Initial OpenAPI specification
- Pi agent integration

### Changed

- Protocol wire format stabilized
- SDK types aligned with specification

## Release history

| Version | Date | Highlights |
|---|---|---|
| Unreleased | 2026-06-07 | 37 MCP tools, 19-adapter ecosystem, general-memory + auto domain router, 193K LoC Rust |
| 1.2.1 | 2026-06-05 | Windows support, NERE intelligence, encrypted vault, knowledge panorama, 20+ MCP tools |
| 1.0.0 | 2026-05-28 | Three-tier editions, Community elevation, security hardening, license system |
| 0.9.2 | 2026-05-24 | Agent Tool Output Contract v2, Mechanical Adoption Protocol, full spec, SDKs, certification |
| 0.6.2 | 2026-05-17 | Initial public protocol and SDK artifacts |

[Unreleased]: https://github.com/HMG-AI/HMG-public/compare/v1.2.1...HEAD
[1.2.1]: https://github.com/HMG-AI/HMG-public/releases/tag/v1.2.1
[1.0.0]: https://github.com/HMG-AI/HMG-public/releases/tag/v1.0.0
[0.9.2]: https://github.com/HMG-AI/HMG-public/releases/tag/v0.9.2
[0.6.2]: https://github.com/HMG-AI/HMG-public/releases/tag/v0.6.2
