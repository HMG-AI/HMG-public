# HMG Public Workspace

This local directory is the staging workspace for exported public HMG repositories.

Source of truth:

- Private monorepo: `/home/seekee/Documents/Programming/HMG`
- Public staging bundle inside private monorepo: `/home/seekee/Documents/Programming/HMG/public`
- Export workspace: `/home/seekee/Documents/Programming/HMG-public`
- Website checkout: `/home/seekee/Documents/Programming/HMG-website`

Rules:

- Do not copy private crates or internal ADRs here by hand.
- Generate or synchronize repositories here through the public export pipeline.
- Every exported repository must pass `scripts/check-public-export-boundary.sh` from the private monorepo before it is pushed.
- Keep high-value engine, eval, connector, enterprise, policy-pack, vault, and operational material out of this workspace.

Expected future directories:

- `hmg-spec/`
- `hmg-protocol/`
- `hmg-mcp/`
- `hmg-sdk-python/`
- `hmg-sdk-js/`
- `hmg-examples/`
- `hmg-certification/`
- `hmg-community-runtime/` after license and boundary review
