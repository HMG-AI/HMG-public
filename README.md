# HMG Public

This repository is the public AGPLv3 umbrella for HMG's open protocol and community ecosystem.

GitHub remote: https://github.com/monkseekee-max/HMG-public.git

License: AGPLv3

Source of truth and local workspaces:

- Private monorepo: `/home/seekee/Documents/Programming/HMG`
- Public staging bundle inside private monorepo: `/home/seekee/Documents/Programming/HMG/public`
- Public umbrella checkout: `/home/seekee/Documents/Programming/HMG-public`
- Website checkout: `/home/seekee/Documents/Programming/HMG-website`
- Website GitHub remote: `https://github.com/monkseekee-max/HMG-website.git` (private)

Rules:

- Do not copy private crates or internal ADRs here by hand.
- Generate or synchronize repositories here through the public export pipeline.
- Every exported repository must pass `scripts/check-public-export-boundary.sh` from the private monorepo before it is pushed.
- Keep high-value engine, eval, connector, enterprise, policy-pack, vault, and operational material out of this workspace.

Initial promotion bundle:

- `hmg-spec/`
- `hmg-protocol/`
- `hmg-mcp/` schema and documentation only
- `hmg-examples/` with synthetic examples
- `hmg-certification/` conformance skeleton
- brand/profile README and legal/support docs

Later additions:

- `hmg-sdk-python/`
- `hmg-sdk-js/`
- `hmg-cli/`
- `hmg-community-runtime/` after minimal runtime design and commercial licensing path are reviewed
