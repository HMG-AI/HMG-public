# Referência API HMG — Community Edition

URL base: `http://localhost:3000`

## Ferramentas MCP

### `memory_memorize`
Armazena informações duradouras.
```json
{ "content": "Texto para memorizar", "modality": "text" }
```

### `memory_recall`
Recupera memórias relevantes.
```json
{ "query": "Qual banco de dados escolhemos?", "max_results": 10 }
```
Perfis: `compact`, `summary`, `full`, `debug`. Formatos: `yaml`, `markdown`, `json`.

### `memory_correct`
Corrige, nega, confirma, rebaixa ou substitui um átomo.
```json
{ "target_atom": "01KSEF...", "action": "replace", "reason": "Mudou para SQLite", "new_content": "Decisão: Usar SQLite." }
```

### `memory_govern`
Aplica governança: quarentena, lacramento, tombstone ou derivar lição.

### `memory_history` | `memory_handoff` | `memory_agent_brief` | `memory_stats`

## API HTTP
`POST /api/memorize` | `POST /api/recall` | `POST /api/correct` | `POST /api/governance/{action}` | `GET /api/stats` | `GET /api/graph/export` | `GET /api/snapshot/{atom_id}` | `GET /api/audit/{atom_id}`

## Escopo
```
tenant_id → workspace → repository → branch → task_id / decision_id
```
