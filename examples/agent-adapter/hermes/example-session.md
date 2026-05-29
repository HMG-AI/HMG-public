# Example: Hermes Session with HMG Memory

This shows a Hermes agent session using HMG for persistent memory.

## Session Start

Hermes automatically calls `memory_agent_brief`:

```
→ memory_agent_brief({
    query: "current task status and recent decisions",
    domain_pack_id: "software-engineering"
  })

← Brief:
  - Last session: implemented JWT auth middleware
  - Decision: use RS256 over HS256 for asymmetric key verification
  - Risk: token revocation not yet implemented
  - Next step: add token blacklist endpoint
```

## During Task — Storing a Decision

Hermes makes an architectural choice and persists it:

```
→ memory_memorize({
    content: "Decided to use Redis for token blacklist with TTL matching JWT expiry (24h)",
    source: "architecture-review",
    modality: "text",
    domain_pack_id: "software-engineering"
  })

← Stored atoms: [01KSM3ABC...]
```

## Before Risky Edit — Recalling Context

Hermes is about to modify the auth middleware, checks for related decisions:

```
→ memory_recall({
    query: "auth middleware JWT token decisions",
    max_results: 5,
    domain_pack_id: "software-engineering"
  })

← Recall:
  [0.92] Decided to use Redis for token blacklist with TTL matching JWT expiry
  [0.87] Use RS256 over HS256 for asymmetric key verification
  [0.71] Token revocation not yet implemented — risk
```

## Session End — Handoff

Hermes summarizes the session for the next agent:

```
→ memory_handoff({
    summary: "Implemented token blacklist endpoint using Redis SET with TTL. 
              Added /api/auth/revoke POST endpoint. Tests pass (12/12). 
              Remaining: integrate blacklist check in auth middleware, 
              add E2E test for revoked token rejection."
  })

← Handoff stored. Session atoms: 4
```
