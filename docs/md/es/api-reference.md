# Referencia API HMG — Community Edition

URL base HTTP: `http://localhost:3000` (predeterminado).

## Herramientas MCP

### `memory_memorize`
Almacena información duradera.

```json
{ "content": "Texto a memorizar", "source": "etiqueta-opcional", "modality": "text", "context": { "tenant_id": "tenant-acme", "workspace": "platform", "repository": "my-repo", "branch": "main" } }
```

### `memory_recall`
Recupera recuerdos relevantes.

```json
{ "query": "¿Qué base de datos elegimos?", "max_results": 10, "response_profile": "compact" }
```

Perfiles: `compact` (predeterminado), `summary`, `full`, `debug`. Formatos: `yaml`, `markdown`, `json`.

### `memory_correct`
Corrige, niega, confirma, degrada o reemplaza un átomo.

```json
{ "target_atom": "01KSEF...", "action": "replace", "reason": "Cambio a SQLite", "new_content": "Decisión: Usar SQLite." }
```

Acciones: `negate`, `confirm_actual`, `confirm_necessary`, `demote`, `replace`.

### `memory_govern`
Aplica gobernanza: cuarentena, sellado, tombstone o derivar lección.

```json
{ "target_atom": "01KSEF...", "action": "tombstone", "reason": "Contiene referencia a clave API sensible" }
```

### `memory_history` | `memory_handoff` | `memory_agent_brief` | `memory_stats`

## API HTTP

| Endpoint | Descripción |
|---|---|
| `POST /api/memorize` | Igual que memory_memorize |
| `POST /api/recall` | Igual que memory_recall |
| `POST /api/correct` | Igual que memory_correct |
| `POST /api/governance/{action}` | quarantine, seal, tombstone, derive_lesson |
| `GET /api/stats` | Estadísticas |
| `GET /api/graph/export` | Exportar grafo completo |
| `GET /api/snapshot/{atom_id}` | Historial de instantáneas |
| `GET /api/audit/{atom_id}` | Pista de auditoría completa |

## Alcance

```
tenant_id → workspace → repository → branch → task_id / decision_id
```

## Formato de respuesta

Éxito: `{ "success": true, "snapshot_version": 905 }`
Error: `{ "success": false, "error": "descripción del error" }`
