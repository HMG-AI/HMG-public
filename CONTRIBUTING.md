# Contributing to HMG

First: thank you for considering a contribution to HMG! We welcome contributions that improve the public ecosystem — protocol, SDKs, documentation, examples, and certification tests.

## Scope of Contributions

This repository contains **public protocol and ecosystem artifacts only**. The HMG engine is proprietary and not open for external contributions.

We accept contributions to:

| Area | Examples |
|---|---|
| **Protocol** | New wire types, schema fixes, spec clarifications |
| **SDKs** | Bug fixes, new language SDKs, API surface improvements |
| **Agent Adapters** | Integration configs and prompts for new AI agents |
| **Documentation** | Typos, new guides, translations, clarifications |
| **Examples** | New integration examples, platform-specific guides |
| **Certification** | New conformance tests, test infrastructure |
| **MCP schemas** | Schema fixes, new tool proposals |

We do **not** accept contributions to:
- Engine internals (recall engine, knowledge maintenance, ranking)
- Domain pack tuning (classification rules, extraction profiles)
- Evaluation datasets or benchmark fixtures
- Enterprise features (SSO, RBAC, audit)

### Agent Adapter Contributions

To add support for a new AI agent (e.g., Hermes, Aider, Continue.dev):

1. Create `examples/agent-adapter/your-agent/` with:
   - `README.md` — setup instructions for that agent
   - MCP config template (JSON)
   - System prompt fragment (Markdown)
   - Example session (Markdown)
2. Follow the existing [Hermes adapter](examples/agent-adapter/hermes/) as a template.
3. Your adapter is **purely configuration** — no HMG binary changes needed.

## Contribution Workflow

### 1. Sign your work (DCO)

We use the **Developer Certificate of Origin (DCO)**. Every commit must include a `Signed-off-by:` line:

```bash
git commit -s -m "fix: correct AtomView polarity parsing"
```

This certifies that you wrote the code or have the right to submit it. By signing off, you agree to the [Developer Certificate of Origin](https://developercertificate.org/).

### 2. Pull Request Process

1. **Fork** the repository
2. **Create a branch** from `main`: `git checkout -b my-feature`
3. **Make your changes** with clear, descriptive commits
4. **Sign off** every commit: `git commit -s`
5. **Open a PR** against `main` in this repository
6. **Fill in the PR template** completely
7. **Respond to review feedback**

### 3. PR Requirements

- [ ] All commits signed off (DCO)
- [ ] No proprietary algorithm details in code or comments
- [ ] No real user data, secrets, or internal endpoints
- [ ] Documentation updated if behavior changed
- [ ] Tests pass (if applicable)

### 4. Review

All PRs require at least one review from a maintainer. Reviews typically happen within 2-3 business days.

## Reporting Issues

### Bug Reports

Please use [GitHub Issues](https://github.com/HMG-AI/HMG-public/issues) and include:

1. HMG version (`hmg --version`)
2. Operating system and architecture
3. Steps to reproduce
4. Expected vs actual behavior
5. Relevant logs (redact any sensitive data)

### Security Vulnerabilities

**Do not report security vulnerabilities in public GitHub issues.**

Instead, email **security@hmg2ai.com** with:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Your suggested fix (if any)

See [`SECURITY.md`](SECURITY.md) for our full security policy.

## Code Style

### Rust (protocol / certification)

```bash
cargo fmt -- --check
cargo clippy -- -D warnings
```

### TypeScript (SDK)

```bash
npx prettier --check src/
npx tsc --noEmit
```

### Python (SDK)

```bash
black --check hmg/
mypy hmg/
```

### Documentation

- Use **English** for all public documentation
- Keep sentences clear and concise
- Use code examples generously
- Link to related docs where appropriate

## Questions?

- 💬 [GitHub Discussions](https://github.com/HMG-AI/HMG-public/discussions) — questions, ideas, show & tell
- 🐛 [GitHub Issues](https://github.com/HMG-AI/HMG-public/issues) — bugs and feature requests
- 📧 security@hmg2ai.com — security and private inquiries

## License

By contributing to this repository, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).
