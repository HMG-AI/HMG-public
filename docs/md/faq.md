# HMG FAQ

## General

### What is HMG?

HMG (Holographic Memory Graph) is a long-term memory system for AI agents. It lets agents store decisions, recall context, correct mistakes, and govern sensitive knowledge — all persistently across sessions.

### Who is HMG for?

- **AI agent users** who want their agents to remember things between sessions
- **Developers** building agent-based tools and need a memory layer
- **Teams** who want shared agent memory across projects
- **Enterprises** who need governed, auditable agent memory at scale

### Is HMG open source?

HMG has an **open protocol** (Apache-2.0) and a **free binary** (custom license). The engine code is proprietary. This follows the Docker Desktop model — free to use, no source code published.

See: [Licensing](../README.md#license)

### How is HMG different from a vector database?

| Feature | Vector DB | HMG |
|---|---|---|
| Data model | Embeddings + metadata | Typed graph with polarity, epistemic state, governance |
| Correction | Overwrite | Append-only with full history |
| Governance | ACL at best | Quarantine, seal, tombstone, lesson derivation |
| Scope | Flat or simple namespaces | Hierarchical (tenant → workspace → repo → branch) |
| Agent integration | Build your own | 7 agents, one-command setup |
| Output contract | Raw results | Structured, token-budgeted, progressive disclosure |

Vector databases store and retrieve embeddings. HMG manages knowledge lifecycle.

### What does "Holographic Memory Graph" mean?

- **Memory** — it stores and retrieves information
- **Graph** — atoms are connected by typed edges (Supersedes, DerivesFrom, etc.)
- **Holographic** — any subgraph contains enough information to reconstruct meaningful context, similar to how a hologram works

## Installation & Setup

### How do I install HMG?

```bash
curl -L https://hmg2ai.com/install.sh | sh
```

Or download from [GitHub Releases](https://github.com/HMG-AI/HMG/releases).

### What platforms are supported?

| Platform | Architecture | Status |
|---|---|---|
| Linux | x86_64 | ✅ Primary |
| Linux | ARM64 | ✅ Supported |
| macOS | Intel | ✅ Supported |
| macOS | Apple Silicon | ✅ Primary |
| Windows | x86_64 | 🔜 Planned |

### How do I start HMG?

```bash
hmg daemon start
```

This starts the HMG service in the background. Agents can connect via MCP or HTTP.

### How do I connect my agent?

```bash
hmg init --agent cursor    # Cursor
hmg init --agent pi        # pi (Codex fork)
hmg init --agent claude    # Claude Code
```

This configures your agent to use HMG as its memory layer. One command, done.

## Usage

### What can my agent remember?

Anything that helps it work better across sessions:

- **Decisions**: "We chose PostgreSQL over MongoDB for the main database"
- **Constraints**: "All API endpoints must require authentication"
- **Root causes**: "Build fails on ARM64 because of missing jemalloc flags"
- **Preferences**: "User prefers TypeScript over JavaScript"
- **Observations**: "Tests pass consistently on Linux but fail intermittently on macOS"

### How does correction work?

When a memory becomes stale, your agent corrects it:

```
Old: "We use MongoDB"
Corrected: "We migrated to PostgreSQL"
```

The old memory is NOT deleted — it's linked via a `Supersedes` edge. You can always trace the full history.

### What happens when I reach the atom limit?

Community Edition supports 50,000 memory atoms. This is approximately:
- **1 year** of medium use (coding agent working daily)
- **6-8 months** of heavy use (active team with multiple agents)
- **2.7 years** of light use (occasional use)

When approaching the limit, HMG shows a warning. At the limit, new memories replace lowest-certainty existing ones (intelligent rotation, no data loss).

To get unlimited storage: [Upgrade to Developer](https://hmg2ai.com/#pricing)

### How does branch-aware scope work?

Memories are scoped to a hierarchy:

```
tenant → workspace → repository → branch
```

A coding agent on `feature/auth` sees:
- All memories from `main` (shared decisions)
- Only `feature/auth`-specific memories (not `feature/payments`)

This prevents context pollution across branches.

## Privacy & Security

### Does HMG send my data anywhere?

**Community Edition: No.** Zero outbound connections. No telemetry. Your memory stays on your machine.

**Developer Local: No.** Same as Community — fully offline.

**Developer Cloud / Enterprise:** Only when you explicitly use cloud features. Transport is TLS-encrypted.

### Can HMG store secrets or API keys?

Yes, but we recommend using the governance features:

```bash
# If a secret is accidentally memorized, seal it:
hmg govern <atom-id> --action seal --reason "Contains API key"
```

Sealed memories are irretrievable — the content is gone, only metadata remains.

### Where is data stored?

```
~/.local/share/hmg/stores/default/
```

Local filesystem, user-only permissions. You own your data completely.

## Licensing & Pricing

### Is Community Edition really free?

Yes. Free for personal, academic, and commercial use within the volume limits:
- Up to 5 instances per organization
- Up to 5 agents per instance
- Up to 50,000 memory atoms

No time limits, no feature removal, no ads.

### What do I get with Developer Edition?

- **One-Shot Recall Engine**: Complete answers in a single tool call
- **Semantic search**: Vector-based similarity, not just keyword matching
- **Automated consolidation**: Background knowledge maintenance
- **Domain Packs**: Software engineering domain intelligence
- **Unlimited** atoms, agents, and instances

### How do I upgrade?

Set a license key:

```bash
export HMG_LICENSE_KEY=<your-key>
hmg daemon restart
```

Same binary, instant upgrade. See [Upgrade Guide](upgrade.md).

### I'm an AI platform / IDE vendor. Can I embed HMG?

Yes, through an OEM agreement. Community Edition explicitly prohibits embedding in products for external users (License Section 3e). OEM licensing provides:
- Developer/Enterprise features
- Branding rights ("Powered by HMG")
- Priority support

Contact: security@hmg2ai.com

## More questions?

- 💬 [GitHub Discussions](https://github.com/HMG-AI/HMG-public/discussions)
- 📧 security@hmg2ai.com
- 🌐 https://hmg2ai.com/
