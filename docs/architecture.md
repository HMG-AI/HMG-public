# HMG Architecture

This document provides a high-level overview of how HMG works. It describes the system at a conceptual level — no proprietary implementation details.

## Visual Tour — TUI

HMG includes a built-in terminal UI (TUI) for browsing, searching, and managing your memory store.

Launch it with:

```bash
hmg tui
```


The Dashboard shows atom count, index status, daemon health, and recommended next actions.

### Doctor Screen

Check all integrations and system readiness:


### Recall Screen

Search your memory and view projected results:


### Timeline Screen

Browse memory events chronologically:


### Integrations Screen

See which agents are detected and configured:


### Store Screen

Monitor daemon status, storage paths, and snapshot versions:


### Settings Screen

Configure language (15 locales) and theme:


## System Overview

```
┌──────────────────────────────────────────────────────────┐
│                    AI Agent / IDE                         │
│  (Cursor, Claude Code, pi, Codex, Windsurf, ...)         │
└────────────┬─────────────────────────────┬───────────────┘
             │ MCP                          │ HTTP / SDK
             ▼                              ▼
┌──────────────────────────────────────────────────────────┐
│                    HMG Binary                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐               │
│  │   MCP    │  │   HTTP   │  │   CLI    │               │
│  │ Handlers │  │    API   │  │  (hmg)   │               │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘               │
│       │             │             │                       │
│       └─────────────┼─────────────┘                       │
│                     ▼                                     │
│  ┌──────────────────────────────────────────┐            │
│  │           Memory Engine                   │            │
│  │  ┌────────┐ ┌────────┐ ┌───────────┐    │            │
│  │  │ Graph  │ │ Index  │ │ Storage   │    │            │
│  │  │ Model  │ │ (query)│ │ (persist) │    │            │
│  │  └────────┘ └────────┘ └───────────┘    │            │
│  └──────────────────────────────────────────┘            │
│                     │                                     │
│                     ▼                                     │
│           Local File System (~/.local/share/hmg/)        │
└──────────────────────────────────────────────────────────┘
```

## Components

### Interfaces

HMG provides three access surfaces:

| Interface | Protocol | Use case |
|---|---|---|
| **MCP** | Model Context Protocol | Agent integration (primary) |
| **HTTP API** | REST + JSON | SDK integration, custom tools |
| **CLI** | Terminal (`hmg` command) | Administration, debugging, scripting |
| **TUI** | Interactive terminal (`hmg tui`) | Visual browsing and management |

All four surfaces expose the same capabilities — store memories, recall, correct, and govern.

### Memory Engine

The core of HMG. It manages:

- **Graph model**: Atoms connected by typed edges (Supersedes, DerivesFrom, RelatesTo, etc.)
- **Indexes**: Keyword search, temporal ordering, categorical grouping, and semantic search
- **Storage**: Persistent local storage with snapshot history

### Agent Integration

`hmg init --agent <id>` configures an agent to use HMG as its memory layer. Supported agents:

| Agent | Status |
|---|---|
| Cursor | ✅ Supported |
| pi (Codex fork) | ✅ Supported |
| Claude Code | ✅ Supported |
| Codex | ✅ Supported |
| Windsurf | ✅ Supported |
| Aider | ✅ Supported |
| Continue | ✅ Supported |

## Data Flow

### Memorize

```
Agent → "Remember this: ..." → HMG
  → Validate input
  → Create typed Memory Atom
  → Attach scope and context
  → Index for retrieval (keyword + temporal + categorical)
  → Persist to local storage
  → Return atom ID + acknowledgment
```


### Recall

```
Agent → "What about database?" → HMG
  → Parse query intent
  → Retrieve candidates from indexes
  → Rank by relevance, certainty, recency
  → Filter by scope and governance state
  → Project related atoms via graph traversal
  → Format output per Agent Tool Output Contract
  → Return structured result + diagnostics
```


### Correct

```
Agent → "That's wrong, it's actually ..." → HMG
  → Create correction atom (action + reason)
  → Link via Supersedes edge
  → Update original atom's polarity/epistemic state
  → Persist correction history
  → Return correction confirmation
```


### Govern

```
Admin → "Seal this sensitive memory" → HMG
  → Validate governance action
  → Transition exposure state (visible → sealed)
  → Optionally derive safe lesson atom
  → Persist governance record
  → Original content becomes irretrievable (sealed)
```


## Storage

HMG stores all data locally on the machine where it runs:

```
~/.local/share/hmg/
  stores/
    default/           ← Default memory store
      graph/           ← Atom and edge data
      indexes/         ← Search indexes
      snapshots/       ← Correction/governance history
```

No data leaves the machine in Community and Developer Local editions.

## Edition Architecture

HMG is a single binary that contains all code for all editions. The active edition is determined at startup:

```
HMG Binary
  │
  ├── No license key → Community Edition
  │     └── One-Shot Recall, 50K atoms, 5 agents, quantitative caps
  │
  ├── HMG_LICENSE_KEY=hmg-dev-... → Developer Edition
  │     └── One-Shot Recall, consolidation, Domain Packs, unlimited
  │
  ├── HMG_LICENSE_KEY=hmg-ent-... → Enterprise Edition
  │     └── All features, SSO, RBAC, multi-tenant, audit
  │
  └── HMG_CLOUD_TOKEN → Cloud-connected
        └── Developer or Enterprise via cloud authentication
```

This means:
- No separate binaries to maintain
- Upgrade is instant: `export HMG_LICENSE_KEY=...` and restart
- Community users get the same binary quality as Enterprise

## Security Boundaries

```
┌─────────────────────────────────┐
│         Agent Process            │
│   (runs with user permissions)   │
└──────────────┬──────────────────┘
               │ MCP / HTTP (localhost)
               ▼
┌─────────────────────────────────┐
│         HMG Process              │
│   (binds to localhost:8080)      │
│                                  │
│   Memory data: user-only access  │
│   No outbound connections (CE)   │
│   No telemetry (CE)              │
└─────────────────────────────────┘
```

- Community Edition makes **zero outbound network connections**
- HMG binds to `localhost` by default — not exposed to the network
- Storage files use user-only permissions

## What's next?

- [Concepts](concepts.md) — memory atoms, correction, governance, scope
- [API Reference](api-reference.md) — all MCP tools and HTTP endpoints
- [Security](security.md) — security model and reporting
