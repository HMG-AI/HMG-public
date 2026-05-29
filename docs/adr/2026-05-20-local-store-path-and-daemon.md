# ADR 2026-05-20: Unified Local Store Path and Local Daemon Concurrency Model

## Status

Accepted for architecture. Local daemon MVP plan confirmed and implemented for the direct-lock, default-store proxy, JSON-RPC Unix-socket daemon, idempotent write, WAL recovery, and dry-run migration-report phases. Destructive migration apply and Windows named-pipe serving remain deferred follow-ups.

## Date

2026-05-20

## Context

HMG is local-first coding-agent memory. Today the server and agent integrations still use fragmented default store paths:

- `hmg-server` without a data directory defaults to a relative `hmg-data` directory.
- Agent integrations use per-agent data directories such as `codex-data`, `claude-data`, `cursor-data`, `pi-data`, and `generic-mcp-data` under the user's HMG data directory.
- Multiple coding agents can therefore create separate memory stores by default, weakening cross-agent continuity.
- If those integrations are simply pointed at the same directory while each tool call starts its own stdio `hmg-server`, multiple processes can concurrently mutate the same Fjall store, WAL, semantic index files, checkpoints, and sidecar metadata.

The product goal is a single local memory store for the user by default, without unsafe implicit migration or data corruption.

## Decisions

### 1. Default store path

Accept the unified default store path:

```text
~/.local/share/hmg/stores/default
```

On platforms where `XDG_DATA_HOME` is set, the equivalent XDG path is:

```text
$XDG_DATA_HOME/hmg/stores/default
```

On Windows, use the OS data directory equivalent:

```text
%LOCALAPPDATA%\HMG\stores\default
```

New installations must use this store immediately for all local agent integrations unless an explicit override is configured.

### 2. New install behavior

New installs and new integration initialization should converge on the same default store:

```text
hmg-server ~/.local/share/hmg/stores/default
```

Agent-specific environment overrides may remain for explicit isolation, but they are no longer the default path strategy:

- `HMG_DATA_DIR`
- `HMG_CODEX_DATA_DIR` or existing compatibility aliases
- `HMG_CLAUDE_DATA_DIR`
- `HMG_CURSOR_DATA_DIR`
- `HMG_PI_DATA_DIR`
- `HMG_GENERIC_MCP_DATA_DIR`

If an override is present, HMG should treat it as an intentional separate profile and should not rewrite it silently.

### 3. Old install migration policy

Do not automatically merge old stores.

Old installs may contain separate stores with conflicting atoms, duplicate content, divergent correction histories, or user-intended separation. Automatic merge risks silent data corruption and unexpected memory leakage across agents.

Instead, HMG should detect likely legacy stores and display a migration prompt or doctor warning, for example:

```text
Found legacy HMG stores:
- ~/.local/share/hmg/codex-data
- ~/.local/share/hmg/claude-data
- ~/.local/share/hmg/pi-data

New installs use ~/.local/share/hmg/stores/default.
No data was moved automatically.
Run `hmg store migrate --from <path> --to ~/.local/share/hmg/stores/default --dry-run` to inspect a migration plan.
```

Migration must be explicit, dry-run first, auditable, and reversible by backup.

### 4. Local daemon direction

Accept a local daemon as the long-term correctness model.

The daemon is not just an optimization. It is the concurrency boundary that ensures only one writer owns a local store at a time. Agent integrations should eventually talk to the local daemon instead of spawning independent store-owning stdio processes for every tool call.

### 5. Cloud scope

Cloud sync/service is deferred.

This ADR intentionally covers local-first storage and local concurrency only. Cloud identity, remote sync, multi-device merge, paid hosting, and enterprise control-plane replication require separate ADRs.

## Exact Technical Solution for Local Daemon Concurrency

### Principle

Use a single-writer database ownership model:

```text
many clients / agents
    -> local IPC transport
        -> one hmg-local-daemon process
            -> one memory graph instance
                -> one storage engine / keyspace / WAL / index owner
```

No two independent HMG processes may open the same store as writable at the same time.

This follows database design principles:

- one authoritative writer per database instance;
- append-only WAL before durable state mutation;
- ordered commit sequence numbers;
- atomic commit batches where storage supports batching;
- crash recovery by replaying committed WAL tail;
- readers observe committed snapshots, not half-applied writes;
- idempotent mutation requests for retry safety;
- explicit backup/migration boundaries instead of hidden merge.

### Process and lock model

Each store has a runtime lock file:

```text
~/.local/share/hmg/stores/default/.runtime/store.lock
```

The daemon acquires an exclusive advisory file lock on this file before opening the store for write. The lock is held for the daemon lifetime.

Lock metadata is written to:

```text
~/.local/share/hmg/stores/default/.runtime/daemon.json
```

Suggested metadata:

```json
{
  "pid": 12345,
  "started_at_ms": 1780000000000,
  "store_path": "/home/user/.local/share/hmg/stores/default",
  "socket_path": "/run/user/1000/hmg/default.sock",
  "protocol_version": "hmg-local-daemon-v1"
}
```

Rules:

1. If a writable process cannot acquire `store.lock`, it must not open Fjall or index files directly.
2. It should read `daemon.json`, health-check the socket, and become a client.
3. If metadata exists but the socket health check fails, MCP proxy startup treats the metadata as stale, removes it when autostart is allowed, starts a fresh daemon, and waits for a healthy socket before proxying requests.
4. If metadata exists but autostart is disabled, commands fail with a stale-metadata diagnostic and direct-mode remediation instead of proxying to a dead socket.
5. If the lock is held but the daemon is unhealthy, commands fail with a structured `store.busy_or_unhealthy` diagnostic instead of attempting a second writer.
6. A daemon writes `daemon.json` only after its local IPC socket is successfully bound; graceful shutdown removes metadata and socket files.

### IPC transport

Use local-only IPC:

- Unix: Unix domain socket under `$XDG_RUNTIME_DIR/hmg/default.sock`, falling back to `~/.local/share/hmg/run/default.sock` when no runtime dir exists.
- Windows: named pipe such as `\\.\pipe\hmg-default`.

The first protocol can be JSON-RPC using the existing MCP/HTTP logical request shapes to keep client adapters thin. It can later gain a more efficient transport without changing storage ownership.

### Write serialization

The daemon owns a bounded async write queue:

```text
client request
  -> validate scope/policy/admission
  -> enqueue write command
  -> single writer task assigns commit_sequence
  -> append WAL entry or transaction record
  -> apply graph mutation in memory engine
  -> persist atom/edge/snapshot/index metadata
  -> fsync / persist according to durability profile
  -> return committed result with commit_sequence and snapshot_version
```

Only the writer task mutates the hot graph, WAL checkpoint, Fjall partitions, semantic shard manifests, fingerprint index checkpoints, noise gate snapshot, and other store sidecars.

Read requests may run concurrently against an in-process committed snapshot/RwLock, but they must not observe partial writes. If read isolation is not yet formalized, the safe MVP is to route reads through the same actor and relax later.

### WAL and commit ordering

Introduce a store-level `commit_sequence` that is monotonic for all durable mutations.

For each write:

1. Reserve `commit_sequence = last_sequence + 1` inside the writer task.
2. Write a WAL transaction record containing:
   - operation type;
   - idempotency key;
   - request context;
   - atom/edge/snapshot payloads or deterministic write plan;
   - previous snapshot version;
   - target snapshot version.
3. Persist the WAL record before acknowledging success.
4. Apply mutations to the hot graph and persistent stores.
5. Record checkpoint only after all affected stores and sidecars are durable.

Crash recovery:

- On startup, load the latest durable snapshot/checkpoint.
- Replay WAL entries after the checkpoint in commit order.
- Skip already-applied idempotency keys or already-present atom/edge IDs.
- Rebuild or validate derived indexes if their checkpoint sequence lags the graph sequence.

### Idempotency and retries

Every mutating client request should carry or receive an idempotency key:

```text
client_id + request_id + operation_kind
```

The daemon stores a compact idempotency table keyed by this value and returns the prior committed result when a client retries after timeout or disconnect.

This prevents duplicate memory writes when an agent retries after an IPC failure.

### Compatibility bridge

During migration to the daemon, stdio MCP remains compatible by becoming a proxy:

```text
agent -> hmg-server stdio shim -> local daemon -> store
```

If no daemon is running, the shim starts one when daemon auto-start policy allows and then connects. Direct writable `hmg-server <data-dir>` remains available only for explicit development/debug modes or when the store lock is acquired.

### Minimal safety phase before full daemon

Before daemon rollout is complete, add a store lock to direct `hmg-server` startup. This does not provide multi-client sharing, but it prevents two stdio processes from corrupting the same store.

Behavior:

- First process acquires the lock and owns the store.
- Second process targeting the same store fails fast with a clear message or connects to the daemon if one is advertised.
- Doctor reports lock holder, store path, and migration guidance.

## Consequences

Positive:

- New users get one shared local memory store by default.
- Existing users are protected from silent cross-agent merges.
- The daemon gives HMG a real database-style concurrency boundary.
- The architecture supports future background compaction, index rebuilds, and hooks without multiple processes racing over sidecar files.

Trade-offs:

- A daemon adds lifecycle management: start, stop, status, health checks, logs, stale metadata cleanup.
- Stdio MCP integrations need a proxy path to preserve compatibility.
- Read isolation and idempotency require explicit protocol fields and tests.
- File locks are advisory and platform-specific; they prevent HMG processes from racing but cannot protect against arbitrary external file mutation.

Risks:

- If the daemon is unhealthy, agents may lose memory access until restart.
- If stale lock handling is too aggressive, a live writer could be interrupted; stale recovery must depend on actual lock acquisition, not PID checks alone.
- If derived indexes are updated outside the writer task, database invariants are broken.
- If old stores are merged without dry-run and backup, users may leak memories across contexts they intended to keep separate.

## Non-goals

- No automatic merge of legacy stores.
- No cloud sync or hosted service behavior.
- No transparent global LLM proxy changes.
- No change to memory governance semantics.

## Implementation Plan Summary

Detailed TODOs are tracked in:

```text
docs/plans/2026-05-20-local-store-daemon-todolist.md
```

Implemented phases:

1. Document and expose unified default store path.
2. Detect legacy stores and prompt explicit migration only.
3. Add direct-process store locking as a short-term safety gate.
4. Implement local daemon with single-writer ownership over JSON-RPC Unix-socket IPC.
5. Convert agent integrations and stdio MCP to daemon clients/proxies with policy-gated auto-start.
6. Add crash recovery, idempotency, bounded-write, and migration dry-run report tests.

Deferred phases:

- Windows named-pipe serving.
- Destructive `hmg store migrate --backup --apply` execution.
- Explicit daemon log-directory ADR/decision.

## Validation Required Before Implementation Is Considered Done

- New install init writes all default integrations to `~/.local/share/hmg/stores/default` or platform equivalent.
- Existing per-agent stores trigger warnings, not automatic movement.
- Two direct writable processes cannot open the same store concurrently.
- Multiple clients can concurrently call the daemon without duplicate sequences, duplicate atoms from retries, or partial reads.
- Crash after WAL append but before full persistence is recovered by replay.
- Crash after full persistence but before checkpoint does not duplicate writes.
- Derived indexes never advance beyond the graph commit sequence they represent.
- Legacy stdio MCP remains compatible through the proxy path.
