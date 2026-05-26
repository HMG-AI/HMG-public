# Conceptos de HMG

## Átomos de memoria

Los átomos son la unidad de datos fundamental en HMG — fragmentos de información persistente con metadatos estructurados.

### Modalidades

| Modalidad | Uso |
|---|---|
| `text` | Memoria textual general |
| `code` | Fragmentos de código o decisiones de arquitectura |
| `dialogue` | Registros de conversación |
| `observation` | Patrones de comportamiento observados |

## Alcance (Scope)

```
tenant_id → workspace → repository → branch → task_id / decision_id
```

- Correspondencia exacta priorizada al recuperar
- Fallback a niveles superiores si no hay resultados
- Sin alcance = memoria global

## Ciclo de corrección

HMG nunca sobrescribe. Las correcciones crean nuevos átomos:

| Acción | Efecto |
|---|---|
| `negate` | Crea átomo negativo, reemplaza objetivo |
| `confirm_actual` | Confirma exactitud factual |
| `confirm_necessary` | Confirma relevancia continua |
| `demote` | Degrada estado epistémico |
| `replace` | Reemplaza átomo viejo con nuevo contenido |

Ver [Corrección y gobernanza](correction-governance.md).

## Gobernanza

```
normal → quarantined → sealed / tombstoned / normal
cualquiera → lesson
```

## Recuperación (Recall)

| Formato | Uso |
|---|---|
| `compact` | Uso diario (predeterminado) |
| `summary` | Resumen legible |
| `full` | Detalles completos |
| `debug` | Información de diagnóstico |

## Modelo de grafo

Átomos conectados por aristas tipadas: `Supersedes`, `DerivesFrom`, `RelatesTo`, `ScopedBy`.

## Próximos pasos

- [Arquitectura](architecture.md)
- [Referencia API](api-reference.md)
- [Corrección y gobernanza](correction-governance.md)
