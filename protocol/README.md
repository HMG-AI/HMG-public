# hmg-protocol

Wire-safe public DTO types for the HMG agent memory protocol.

This crate defines the data shapes that appear in HMG's HTTP, MCP, gRPC,
and SDK interfaces. It is intentionally minimal — containing only the types
that agents and users see, with no ranking, scoring, or internal algorithm
details.

## Types

| Type | Description |
|---|---|
| `AtomView` | A memory atom as seen over the wire |
| `Polarity` | Assertion polarity (positive / negative / conditional) |
| `EpistemicStatus` | Degree of belief (possible / actual / necessary) |
| `ExposureState` | Governance visibility (visible / quarantined / sealed / tombstoned / lesson) |
| `CorrectionAction` | Operations to correct a memory atom |
| `GovernanceAction` | Operations to govern a memory atom's lifecycle |
| `ScopeRef` | Hierarchical scope reference (tenant → workspace → repo → branch) |
| `MemoryContextView` | Unified context for memory operations |
| `RecallResponse` | Agent Tool Output Contract v2 recall result |
| `MemorizeAck` | Acknowledgment for memory write operations |
| `HandoffSummary` | Cross-session context handoff |
| `AgentBrief` | Compact session-start context |

## Usage

```rust
use hmg_protocol::{AtomView, CorrectionAction, ScopeRef, RecallResponse};

// Parse a correction action from wire format
let action = CorrectionAction::from_str("negate");
assert_eq!(action, Some(CorrectionAction::Negate));

// Build a scope for a coding agent
let scope = ScopeRef::coding_agent("my-tenant", "platform", "my-repo", "main");
```

## License

Apache-2.0
