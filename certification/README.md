# HMG Certification

Conformance test suite for HMG-compatible implementations.

## Certification Levels

| Level | Requirements |
|---|---|
| **HMG Protocol Compatible** | Implements wire schema + lifecycle semantics |
| **HMG Community Compatible** | Passes local runtime conformance suite |
| **HMG Certified** | Passes compatibility + governance + audit + security review |

## Running Tests

```bash
cd certification
cargo test
```

## Test Categories

- `wire-schema` — request/response shapes match the protocol
- `lifecycle-semantics` — correction/governance state transitions are correct
- `response-shapes` — output contract matches specification
