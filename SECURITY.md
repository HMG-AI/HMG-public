# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| 1.2.x | ✅ |
| 1.0.x – 1.1.x | ✅ |
| 0.9.x | ⚠️ Security fixes only |
| < 0.9 | ❌ |

## Security Model

HMG stores **agent memory** — decisions, context, constraints, and correction history. It does **not** store source code, credentials (unless explicitly memorized), or conversation transcripts.

### Data locality

- **Community Edition**: All data stays on the local machine. No data is sent to any external service.
- **Developer Local**: Same as Community — fully offline, no network calls.
- **Developer Cloud / Enterprise**: Data is sent to HMG Cloud only when using cloud features. Transport is TLS-encrypted.

### What HMG does NOT collect

- Memory content, queries, or results (Community / Developer Local)
- User identity or organization name
- File paths, repository URLs, or project names
- Agent conversations or tool calls
- Any form of telemetry (Community Edition)

### Telemetry

Community Edition has **no telemetry**. No startup ping, no usage tracking, no phone-home. Your memory stays on your machine.

Developer and Enterprise editions may include optional anonymized telemetry for license compliance and product improvement. Telemetry can always be disabled via `HMG_TELEMETRY=off`.

## Reporting a Vulnerability

We take security seriously. If you discover a vulnerability in HMG, please report it responsibly.

### How to report

**Email:** monkseekee@gmail.com

Please include:
1. **Description** of the vulnerability
2. **Affected versions** (run `hmg --version`)
3. **Steps to reproduce**
4. **Potential impact**
5. **Suggested fix** (if any)

### What to expect

| Timeline | Action |
|---|---|
| Within 48 hours | Acknowledgment of your report |
| Within 5 business days | Initial assessment and severity classification |
| Within 30 days | Fix or mitigation plan |
| After fix | Public advisory and credit (unless you prefer to remain anonymous) |

### Responsible disclosure

- **Do not** disclose the vulnerability publicly until a fix is available
- **Do not** access, modify, or delete other users' data
- **Do not** use the vulnerability for personal gain or to cause harm

We commit to:
- Acknowledging every legitimate report
- Working with you to understand and resolve the issue
- Crediting you in the security advisory (unless you prefer anonymity)
- Not taking legal action against good-faith security research

## Known security considerations

### Local binary

HMG Community Edition runs as a local binary. It binds to `localhost` by default. Ensure your firewall rules prevent external access to HMG's HTTP port.

### Memory content

Memory atoms may contain sensitive information (API keys, passwords, internal URLs). Use HMG's **governance** features to quarantine or seal sensitive atoms:

```bash
# Seal a memory containing sensitive data
hmg govern <atom-id> --action seal --reason "Contains API key"

# Derive a safe lesson from a sensitive memory
hmg govern <atom-id> --action derive_lesson --reason "Incident review" --lesson "Always rotate keys after accidental commit"
```

### File permissions

HMG stores data in `~/.local/share/hmg/stores/default/` by default. Ensure this directory has appropriate permissions (`0700` recommended).

## Contact

- **Security email:** monkseekee@gmail.com
- **General inquiries:** monkseekee@gmail.com
- **Website:** https://hmg1ai.com/
