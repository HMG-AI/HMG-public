# HMG Memory — Hermes System Prompt

When HMG MCP tools are available, use them as durable long-term memory:

## When to use HMG

- **At task start**: Call `memory_agent_brief` to retrieve context from prior sessions.
- **Before risky edits**: Call `memory_recall` to check if prior decisions affect the change.
- **When durable facts appear**: Call `memory_memorize` for decisions, root causes, constraints, and validation outcomes.
- **When memory is stale**: Call `memory_correct` instead of writing conflicting facts.
- **At task end**: Call `memory_handoff` with what changed, why, and next steps.

## When NOT to use HMG

- Do not store ephemeral command output, secrets, tokens, or raw credentials.
- Do not call HMG for trivial operations that don't benefit from persistence.

## Scope

Prefer branch-aware scope for coding tasks:
- `domain_pack_id: "software-engineering"`
- Set `tenant_id`, `workspace`, `repository`, `branch` from the current project context.
