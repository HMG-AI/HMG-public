# Справочник API HMG — Community Edition

Базовый URL HTTP: `http://localhost:3000`

## Инструменты MCP

### `memory_memorize`
Сохраняет постоянную информацию.
```json
{ "content": "Текст для запоминания", "modality": "text" }
```

### `memory_recall`
Извлекает релевантные воспоминания.
```json
{ "query": "Какую базу данных мы выбрали?", "max_results": 10 }
```
Профили: `compact`, `summary`, `full`, `debug`. Форматы: `yaml`, `markdown`, `json`.

### `memory_correct`
Исправляет, отрицает, подтверждает, понижает или заменяет атом.
```json
{ "target_atom": "01KSEF...", "action": "replace", "reason": "Переход на SQLite", "new_content": "Решение: использовать SQLite." }
```

### `memory_govern`
Применяет управление: карантин, запечатывание, tombstone или извлечение урока.

### `memory_history` | `memory_handoff` | `memory_agent_brief` | `memory_stats`

## HTTP API
`POST /api/memorize` | `POST /api/recall` | `POST /api/correct` | `POST /api/governance/{action}` | `GET /api/stats` | `GET /api/graph/export` | `GET /api/snapshot/{atom_id}` | `GET /api/audit/{atom_id}`

## Область
```
tenant_id → workspace → repository → branch → task_id / decision_id
```
