# Changelog

All notable changes to the HMG public protocol, SDKs, and documentation are documented here.

For binary release notes, see [GitHub Releases](https://github.com/HMG-AI/HMG/releases).

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.4.10] — 2026-06-15

Windows stale/zombie daemon lock recovery.

### Fixed

- Windows installs/upgrades no longer get stuck when a previous `hmg-server` process still holds the store lock but no longer responds on its named pipe (the "daemon status says not running yet store.lock is held" zombie). The store lock now records the holder PID, `hmg daemon status` detects a stale/zombie holder, and `hmg daemon stop --force` terminates it and waits for the OS to release the lock.
- `install.ps1` now runs a force-stop sweep plus a `Stop-Process` fallback for `hmg-server.exe`/`hmg.exe` before copying binaries, and the deferred-update helper force-stops before running `hmg setup`, so interrupted Windows upgrades recover automatically.

## [1.4.9] — 2026-06-15

Windows daemon install and upgrade reliability patch.

### Fixed

- Windows post-install now runs `hmg setup` instead of only `hmg init -g`, so new installs create the default store and start the local daemon automatically.
- Windows upgrades now try to stop the existing daemon before replacing binaries, and deferred updates run `hmg setup` after the new binaries land.
- Daemon startup/readiness waits now use one shared configurable window (`HMG_DAEMON_AUTOSTART_TIMEOUT_SECS`, default 30s) across MCP autostart, `hmg daemon start`, `hmg setup`, and TUI daemon start.

## [1.4.8] — 2026-06-14

CLI/TUI usability and installed-evaluation reliability patch.

### Fixed

- Noisy multilingual recall now prioritizes exact high-signal project/sentinel anchors over broad old handoff atoms.
- MCP memory context now accepts shorthand `context.scope` objects with tenant/workspace/repository/branch fields.
- CLI output formats now fail explicitly for unsupported values instead of silently falling back to text.
- `hmg doctor --format json|yaml` emits structured summaries for ordinary doctor runs.
- TUI splash, scope editing, command palette, context help, and single-line input editing are improved.

## [1.4.7] — 2026-06-13

Open-source release-readiness hardening: ordered multi-mirror download fallback, manifest-driven download URLs, and export leak-gate false-positive fix.

### Fixed

- **Version drift**: every public export surface (badges, SDK manifests, protocol/certification crates, package lockfiles, manifest) now tracks the workspace version. The version-drift gate went from 3/19 failing to 19/19 passing.
- **Export leak-gate false positives**: the leak check no longer flags the public security-contact email or the `root@hmg1ai.com` infra host as customer data.

### Changed

- **Ordered download-mirror fallback** (ADR 2026-06-13 D4): install scripts now try `GitHub → hmg1ai.com → hmg2ai.com` in order. A mirror that returns HTML (e.g. the SPA catch-all before R2 is live) is rejected by archive extraction, so the fallback chain is robust today.
- **Manifest-driven download URLs** (ADR 2026-06-13 D5): `public-manifest.json` gained a `download` block (`release_primary`, ordered `mirrors`, `sha256sums_url`) as the single source of truth, with a drift test asserting install scripts match it.
- **CI**: build-release gained a `mirror-to-hmg1ai` (Cloudflare R2) job that activates once R2 secrets are configured, and a `sync-public` job that mirrors `export/` to HMG-public on every release.

## [1.4.6] — 2026-06-13

Windows install robustness and public installer URL canonicalization.

### Fixed

- Windows post-install reliability: `install.ps1` configures PATH and runs `hmg init -g` with the full binary path; daemon autostart timeout raised from 5s to 30s (`HMG_DAEMON_AUTOSTART_TIMEOUT_SECS`); fastembed lazy-initialized.
- Public installer URLs point at the HMG-public GitHub Release (canonical).

## [1.4.5] — 2026-06-12

Simplified Windows smoke test. See CHANGELOG.

## [1.4.4] — 2026-06-12

First successful multi-platform release build (6 platforms). Fixes feature unification leak, adds hmg-cli to release package, and increases Windows smoke test timeout.

### Fixed

- Feature unification leak in hmg-connectors, hmg-consolidation, and hmg-query.
- hmg-cli binary added to release package build.
- Windows daemon smoke test timeout increased to 120s.

### Added

- ADR for embedding model tiered strategy.

## [1.4.3] — 2026-06-12 (build failed)

See 1.4.4.

## [1.4.1] — 2026-06-12 (build failed — no binary release)

Documentation patch whose release build did not succeed; no public assets were published. See 1.4.2.

## [1.4.0] — 2026-06-11

Milestone release completing the world-class technical-assessment upgrade. The
public protocol, SDK shapes, and MCP/HTTP/gRPC surface are **unchanged**; this
is not a breaking release.

### Changed

- **Recall ranking de-over-fitted.** Hardcoded evaluation-fixture proper nouns
  and scenario detectors were removed from the ranking path; the final-evidence
  reranker now uses principled features (exact-entity hits, intent
  classification, recency, lexical/semantic overlap). A held-out generalization
  gate (all identifiers renamed to unseen strings) confirms the ranking
  generalizes: Top-1 98.5%, Top-3 100%, 0 false attribution.
- Default `cargo build` now enables `fastembed-local` (real multilingual
  embeddings). Release packages still build deterministic via explicit
  `--no-default-features` for portability.
- Internal crate architecture: `hmg-cli`, `hmg-licensing`, `hmg-consolidation`
  extracted from `hmg-server`; `hmg-query` and `hmg-vault` monoliths split.
  Public `hmg_query::*` API is unchanged.

### Added

- Held-out generalization gate integrated into the release gate.
- Property, fuzz, and snapshot test infrastructure plus per-crate coverage
  floors (CI-enforced).
- Environment-variable reference catalog (`docs/2026-06-11-hmg-env-var-reference.md`).

## [1.3.3] — 2026-06-11

### Fixed

- Windows release package smoke now allows slower daemon readiness on GitHub runners while still requiring daemon status to become healthy.
- Public package metadata updated for v1.3.3 after the v1.3.2 tag workflow exposed a Windows smoke-test timeout.

## [1.3.2] — 2026-06-10

### Fixed

- Release package builds now use portable default features and keep `fastembed-local` as an explicit opt-in feature.
- Public package metadata updated for v1.3.2 after the v1.3.1 tag workflow exposed non-portable ONNX Runtime release builds.

## [1.3.1] — 2026-06-10

### Added

- Formal Recall Precision v2 MCP release gate for release-quality memory evaluation.
- Public package and SDK metadata updated for v1.3.1.

### Changed

- Improved bilingual recall precision, evidence ranking, and no-evidence abstention for coding-agent memory workflows.
- Release packaging now validates MCP recall precision using the current release binaries to avoid daemon drift.

### Fixed

- Scope-aware direct memory behavior and CLI quality-of-life fixes for correction, governance, graph export, verification, and UTF-8-safe output.

## [1.3.0] — 2026-06-07

### Added

- Agent adapter ecosystem expanded to 19 adapters (VS Code, OpenClaw, Hermes, Windsurf, Continue, Cline, Roo Code, Zed, Aider, OpenHands, Goose, Gemini CLI, Qwen Code, OpenCode)
- Community adapter templates for hermes, openclaw, vscode in `export/adapters/templates/`
- Framework integration recipes (AutoGen, CrewAI, Semantic Kernel, LlamaIndex)


## [1.2.1] — 2026-06-05

### Fixed

- Windows Named Pipe daemon IPC — `hmg daemon start/status/stop` now works on Windows
- Replace all `funcode.xin` URLs with `hmg1ai.com`
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
| 1.0.0 | 2026-05-28 | Three-tier editions, Community elevation, security hardening, license system |
| 0.9.2 | 2026-05-24 | Agent Tool Output Contract v2, Mechanical Adoption Protocol, full spec, SDKs, certification |
| 0.6.2 | 2026-05-17 | Initial public protocol and SDK artifacts |

[1.0.0]: https://github.com/HMG-AI/HMG/releases/tag/v1.0.0
[0.9.2]: https://github.com/HMG-AI/HMG/releases/tag/v0.9.2
[0.6.2]: https://github.com/HMG-AI/HMG/releases/tag/v0.6.2
