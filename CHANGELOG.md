# Changelog

All notable changes to the HMG public protocol, SDKs, and documentation are documented here.

For binary release notes, see [GitHub Releases](https://github.com/HMG-AI/HMG/releases).

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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
| 1.0.0 | 2026-05-28 | Three-tier editions, Community elevation, security hardening, license system |
| 0.9.2 | 2026-05-24 | Agent Tool Output Contract v2, Mechanical Adoption Protocol, full spec, SDKs, certification |
| 0.6.2 | 2026-05-17 | Initial public protocol and SDK artifacts |

[1.0.0]: https://github.com/HMG-AI/HMG/releases/tag/v1.0.0
[0.9.2]: https://github.com/HMG-AI/HMG/releases/tag/v0.9.2
[0.6.2]: https://github.com/HMG-AI/HMG/releases/tag/v0.6.2
