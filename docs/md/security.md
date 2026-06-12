# Security

For the full security policy and vulnerability reporting, see [`SECURITY.md`](../SECURITY.md).

## Quick reference

| Topic | Details |
|---|---|
| **Data locality** | Community/Developer Local: all data stays on your machine |
| **Network** | Community Edition: zero outbound connections, no telemetry |
| **Binding** | Binds to `localhost:3000` by default |
| **Storage** | `~/.local/share/hmg/` with user-only permissions |
| **Vulnerability reporting** | security@hmg1ai.com |

## Memory governance for sensitive data

```bash
# Quarantine — hide from recall while reviewing
hmg govern <atom-id> --action quarantine --reason "May contain credentials"

# Seal — permanently make content irretrievable
hmg govern <atom-id> --action seal --reason "Contains API key"

# Derive lesson — extract a safe lesson from sensitive content
hmg govern <atom-id> --action derive_lesson \
  --reason "Incident review" \
  --lesson "Always rotate keys after accidental commit"
```
