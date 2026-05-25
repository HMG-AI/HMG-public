# HMG Security

## Data Storage

HMG stores all data locally using the Fjall embedded storage engine. No data is sent to any external service or cloud.

- No telemetry
- No analytics
- No network connections during normal operation
- All data stays on your machine

## Reporting Security Vulnerabilities

If you discover a security vulnerability in HMG:

1. **Do not** file a public issue
2. Report via [GitHub Security Advisories](https://github.com/HMG-AI/HMG-public/security/advisories/new)
3. We commit to a **48-hour** initial response time
4. We will work with you to coordinate a fix and disclosure

## Memory Governance

HMG provides built-in governance for handling sensitive data that may be accidentally memorized:

- **Quarantine**: Hide from normal recall while under review
- **Seal**: Permanently hide content, making the payload irretrievable
- **Derive Lesson**: Extract a safe, sanitized lesson from sensitive content

For example, if an agent accidentally memorizes an API key:

1. Quarantine the memory
2. Derive a lesson: "Always rotate keys after accidental exposure"
3. Seal the original content

## Scope

This security policy applies to the HMG Community Edition binary and the hmg-protocol crate.
