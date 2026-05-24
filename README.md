# HMG Public Artifacts

Open protocol, SDK, documentation, and certification artifacts for the
HMG (Holographic Memory Graph) agent memory system.

## Directory Layout

```text
spec/              — Normative specification: atom lifecycle, correction/governance, scope, recall views
protocol/          — Wire-safe Rust DTO types (hmg-protocol crate)
sdk-ts/            — TypeScript SDK
sdk-python/        — Python SDK
mcp/               — MCP tool schema definitions
examples/          — Integration quickstarts with synthetic data
docs/              — Public documentation
certification/     — Conformance test suite for HMG Compatible / HMG Certified
openapi/           — Sanitized OpenAPI specification
pi-agent/          — Pi coding agent package (@hmg_ai/pi-agent)
```

## Quick Start

```bash
# Install HMG Community Edition
curl -L https://get.hmg.ai | sh

# Start memory service
hmg daemon start

# Integrate with your agent
hmg init --agent cursor
```

## License

All content in this repository is licensed under [Apache-2.0](LICENSE),
except where otherwise noted.

HMG is a product of [HMG AI](https://hmg.ai).
