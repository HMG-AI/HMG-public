---
name: hmg
description: HMG durable coding-agent memory for pi. Use when coding tasks need branch-aware memory, prior decisions, recall before risky edits, or end-of-task handoffs.
---

# HMG Memory

Use HMG as durable coding-agent memory in pi sessions.

## Guidance

- Call `hmg_agent_brief` at the start of coding tasks when memory may contain relevant context.
- Call `hmg_recall` before risky edits or when prior decisions may affect the change.
- Call `hmg_handoff` before ending substantial coding tasks.
- Do not store secrets, tokens, raw credentials, or noisy transient command output.
- Use `hmg_correct` for stale memories and `hmg_govern` for sensitive or unsafe memories.
