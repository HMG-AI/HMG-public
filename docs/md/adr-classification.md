# ADR Publication Classification

Per ADR 2026-05-24 (v2) §Documentation Boundary, all ADRs must be classified
before any public release. This document records the classification of each ADR.

**Date classified:** 2026-05-25

## Classification Legend

| Mark | Meaning |
|---|---|
| **Public** | May be published as-is |
| **Sanitize** | May be published after removing internal algorithm/hook details |
| **Private** | Must remain in private monorepo — reveals proprietary internals |

## Classification

| ADR | Title | Classification | Rationale |
|---|---|---|---|
| 2026-05-17 | Domain Lens Semantic Compiler | **Sanitize** | ADR v2 says "Publish RFC only — concept is strategic; compiler details stay private". Remove compiler implementation, keep concept and scope spec. |
| 2026-05-18 | Five Bottleneck Scale Architecture | **Private** | Reveals storage/index tuning internals and scale architecture |
| 2026-05-18 | Recall Precision Experiment Matrix | **Private** | ADR v2 says "Keep private — reveals experiment methodology" |
| 2026-05-19 | Memory Control Plane / Optional LLM Gateway | **Private** | Reveals control plane architecture (enterprise feature) |
| 2026-05-20 | Agent Brief v2 Compact Localized | **Sanitize** | ADR v2 says "Sanitize and publish — brief format is protocol; remove internal rendering details" |
| 2026-05-20 | Compact Write Tool Acknowledgements | **Sanitize** | Output format is protocol; remove internal rendering logic |
| 2026-05-20 | Local Store Path and Daemon | **Public** | Public installation/daemon behavior — no proprietary internals |
| 2026-05-20 | MemoryQL Governed Query Layer | **Private** | Reveals governed query rewrite logic (proprietary) |
| 2026-05-21 | Biomimetic Observation Consolidation | **Private** | ADR v2 says "Keep private — reveals consolidation architecture" |
| 2026-05-21 | Open Standard Community Runtime v1 | **Private** | Superseded by v2; v1 describes source-available model no longer used. Keep for history. |
| 2026-05-21 | Ratatui Hippocampus TUI | **Sanitize** | TUI is bundled in binary; publish concept/features, remove internal panel rendering details |
| 2026-05-23 | Agent Adoption Compliance | **Sanitize** | ADR v2 says "Sanitize and publish — adoption protocol is public; remove internal hook path details" |
| 2026-05-23 | Agent Tool Output Profiles | **Sanitize** | Output profiles are part of the Agent Tool Output Contract (public protocol) |
| 2026-05-23 | Biomimetic Consolidation Runtime | **Private** | ADR v2 says "Keep private — reveals scheduler design" |
| 2026-05-24 | Agent Memory Scope and Query-Directed Recall | **Sanitize** | Scope model is public (spec §6); remove ranking/scoring internals |
| 2026-05-24 | Agent Tool Output Contract v2 | **Public** | ADR v2 says "Publish — this IS the protocol standard" |
| 2026-05-24 | One-Shot Recall Engine | **Private** | ADR v2 says "Keep private — reveals the primary moat" |
| 2026-05-24 | Open Standard v2 (this ADR) | **Private** | Contains full business strategy, pricing, defense playbook, license draft — keep private |
| 2026-05-24 | v0.9.2 Quality Metrics | **Private** | ADR v2 says "Keep private — reveals performance tuning" |

## Summary

| Classification | Count | ADRs |
|---|---|---|
| **Public** | 2 | 2026-05-20-local-store, 2026-05-24-agent-tool-output-contract-v2 |
| **Sanitize** | 6 | 2026-05-17, 2026-05-20 (brief, compact), 2026-05-21 (tui), 2026-05-23 (adoption, profiles), 2026-05-24 (scope) |
| **Private** | 11 | 2026-05-18 (both), 2026-05-19, 2026-05-20 (memoryql), 2026-05-21 (observation, osr-v1), 2026-05-23 (consolidation), 2026-05-24 (oneshot, osr-v2, quality) |

## Action Required

1. The 2 Public ADRs can be copied to `export/docs/adr/` immediately.
2. The 6 Sanitize ADRs need manual review to remove proprietary sections before publishing.
3. The 11 Private ADRs stay in the private monorepo indefinitely.
