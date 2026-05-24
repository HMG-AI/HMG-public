# HMG Examples

Integration quickstarts and synthetic data for HMG.

## Quickstart

### TypeScript

```typescript
import { HMGClient } from '@hmg_ai/sdk-ts';

const client = new HMGClient({ baseUrl: 'http://localhost:8080' });

// Store a memory
await client.memorize({
  content: 'We chose PostgreSQL for the main database because of JSON support',
  context: { repository: 'my-app', branch: 'main' },
});

// Recall memories
const result = await client.recall({ query: 'database choice' });
console.log(result.atoms);
```

### Python

```python
from hmg import HMGClient

client = HMGClient(base_url="http://localhost:8080")

# Store a memory
client.memorize(
    content="API uses JWT tokens with 24h expiry",
    repository="my-api",
    branch="main",
)

# Recall memories
result = client.recall(query="authentication approach")
for atom in result.atoms:
    print(atom.content)
```

## Synthetic Fixtures

The `synthetic-fixtures/` directory contains sample data for testing
integrations. No real user data is included.
