# HMG Public Release SOP

This is the public release and contribution SOP for HMG Community artifacts.
It describes what the public repository publishes, how public documentation is updated, and what checks contributors should run before a public-facing change.

For security reasons, this document intentionally excludes private source repositories, internal infrastructure, private deployment automation, credentials, and proprietary implementation details.

## Public Surfaces

| Surface | Purpose |
|---|---|
| `README.md` | Public overview, quick start, editions, links |
| `docs/` | GitHub Pages documentation site |
| `docs/md/` | Markdown documentation source |
| `protocol/` | Public wire-safe Rust protocol crate |
| `mcp/schemas/tools.json` | Public MCP tool schema |
| `openapi/hmg-server.yaml` | Public HTTP API contract |
| `sdk-python/` | Python SDK package source |
| `sdk-ts/` | TypeScript SDK package source |
| `certification/` | Public conformance tests |
| `scripts/install.sh`, `scripts/install.ps1` | Public installers |

## Release Principles

1. Public artifacts must be safe to redistribute and review.
2. Public docs must describe user-visible behavior, not private implementation internals.
3. Published version numbers must stay consistent across README badges, SDK metadata, protocol crates, certification crates, and the public manifest.
4. Security and governance claims must be backed by public docs, schemas, tests, or release artifacts.
5. GitHub Pages documentation is deployed from `docs/**` on the public repository `main` branch.

## Public Release Checklist

Run this checklist before publishing a public release or public documentation update:

- Confirm `README.md` and `docs/md/*` describe current user-visible behavior.
- Confirm edition tables match the current public manifest and license behavior.
- Confirm public install commands point to GitHub Releases under the public repository.
- Confirm `openapi/`, `mcp/schemas/`, SDKs, `protocol/`, and `certification/` are in sync for API-affecting changes.
- Confirm no private implementation notes, internal repository paths, private hosts, credentials, or unreleased roadmap commitments are present.
- Run the public leak check:

```bash
bash scripts/check-export-leak.sh
```

- Run protocol and certification tests when protocol or SDK-facing behavior changes:

```bash
cd protocol && cargo test
cd ../certification && cargo test
```

## Documentation Publishing

Public documentation is published through GitHub Pages.

1. Edit Markdown docs in `docs/md/` and any mirrored top-level docs in `docs/` when needed.
2. Update `docs/md/README.md` and `docs/README.md` so the new document is discoverable.
3. If the site homepage should link to the document, update `docs/index.html`.
4. Commit and push to `main`.
5. GitHub Pages deploys automatically for changes under `docs/**`.

## Safe Content Rules

Public docs may include:

- Installation and quick-start instructions.
- Edition and license behavior visible to users.
- Public API, MCP, SDK, and protocol references.
- High-level architecture and security model.
- Contribution, support, upgrade, and troubleshooting guidance.

Public docs must not include:

- Private source repository paths or internal branch names.
- Internal server paths, deploy hosts, private runbooks, or credentials.
- Proprietary ranking, ingestion, storage, consolidation, or recall implementation details.
- Internal ADRs, engineering TODOs, raw benchmark data, or private release-blocker notes.
- Secrets, tokens, cryptographic key material, customer data, or real production identifiers.

## Contributor Flow

1. Open an issue or discussion for non-trivial changes.
2. Keep changes scoped to one public surface when possible.
3. Update docs and examples with behavior changes.
4. Run the checks relevant to the touched surface.
5. Submit a pull request with:
   - Summary of user-visible change.
   - Validation commands run.
   - Any compatibility or migration notes.

## Security Reporting

Report vulnerabilities through GitHub Security Advisories for the public repository.
Do not open a public issue for a suspected vulnerability or sensitive data exposure.

## Release Notes

Public release notes should describe:

- User-visible features and fixes.
- Install or upgrade changes.
- API, MCP, SDK, or protocol compatibility notes.
- Known limitations that affect public users.

Release notes should avoid private implementation details and internal incident history unless a sanitized, user-actionable security advisory has been approved.
