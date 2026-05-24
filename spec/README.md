# HMG Specification

Normative specification for the HMG agent memory protocol concepts.

## Core Concepts

### Memory Atom
The fundamental unit of HMG. Each atom carries content, time, polarity,
epistemic state, governance exposure, and unified context.

### Correction/Governance Lifecycle
HMG uses append-only correction and governance rather than overwrite-and-forget.

**Correction actions:** negate, confirm_actual, confirm_necessary, demote, replace

**Governance actions:** quarantine, seal, tombstone, derive_lesson

### Epistemic States
- `possible` — unverified, possibly true
- `actual` — confirmed as actually true
- `necessary` — axiomatic, necessarily true

### Polarity
- `positive` — asserted as true
- `negative` — negated (corrected to false)
- `conditional` — true under certain conditions

### Exposure States
- `visible` — appears in normal recall
- `quarantined` — restricted, not in normal recall
- `sealed` — permanently locked
- `tombstoned` — content replaced with marker
- `lesson` — derived lesson from governed atom

### Scope
Hierarchical context: tenant → workspace → repository → branch → task

### Recall Views
- **normal** — standard recall for agents
- **governance** — includes quarantined/sealed atoms
- **audit** — full history including all transitions

## P-Type Query Matrix

| P-Type | Name | Description |
|---|---|---|
| P1 | Entity | "What is X?" |
| P2 | Process | "How does X work?" |
| P3 | Decision | "Why did we choose X?" |
| P4 | Status | "What is the current state of X?" |
| P5 | History | "What changed with X?" |
| P6 | Relation | "How does X relate to Y?" |
| P7 | Error | "Why is X failing?" |
| P8 | Instruction | "How should I do X?" |
| P9 | Context | "What should I know about X?" |
