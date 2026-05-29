# Conceitos HMG

## Átomos de memória
Unidade fundamental de dados — fragmento de informação persistente com metadados estruturados.

### Modalidades
`text` (geral), `code` (código), `dialogue` (conversas), `observation` (padrões observados)

## Escopo (Scope)
```
tenant_id → workspace → repository → branch → task_id / decision_id
```

## Correção
HMG nunca sobrescreve. Correções criam novos átomos: `negate`, `confirm_actual`, `confirm_necessary`, `demote`, `replace`.

## Governança
```
normal → quarantined → sealed / tombstoned / normal
qualquer → lesson
```

## Recuperação (Recall)
Formatos: `compact` (padrão), `summary`, `full`, `debug`. Community: busca por palavras-chave. Developer: busca semântica.

## Modelo de grafo
Átomos conectados por arestas: `Supersedes`, `DerivesFrom`, `RelatesTo`, `ScopedBy`.

Veja [Correção e governança](correction-governance.md).
