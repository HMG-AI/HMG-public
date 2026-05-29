# Концепции HMG

## Атомы памяти
Фундаментальная единица данных — фрагмент постоянной информации со структурированными метаданными.

### Модальности
`text` (общий), `code` (код), `dialogue` (диалоги), `observation` (наблюдения)

## Область (Scope)
```
tenant_id → workspace → repository → branch → task_id / decision_id
```

## Исправления
HMG никогда не перезаписывает. Исправления создают новые атомы: `negate`, `confirm_actual`, `confirm_necessary`, `demote`, `replace`.

## Управление
```
normal → quarantined → sealed / tombstoned / normal
любой → lesson
```

## Извлечение (Recall)
Форматы: `compact` (по умолчанию), `summary`, `full`, `debug`. Community: One-Shot Recall (P1-P9). Developer: безлимитный + автоматическая консолидация.

## Модель графа
Атомы соединены типизированными рёбрами: `Supersedes`, `DerivesFrom`, `RelatesTo`, `ScopedBy`.

См. [Исправление и управление](correction-governance.md).
