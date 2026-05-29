# Corrección y gobernanza

HMG utiliza un **modelo de corrección y gobernanza de solo agregar**. Los átomos nunca se sobrescriben silenciosamente. Las correcciones crean nuevos átomos con relaciones explícitas, y las transiciones de gobernanza preservan el historial completo.

## Estados del ciclo de vida de los átomos

### Polaridad

| Polaridad | Significado |
|---|---|
| `positive` | El átomo se afirma como verdadero |
| `negative` | El átomo ha sido negado o reemplazado |
| `neutral` | Informativo — sin afirmación de verdad |

### Estado epistémico

| Estado | Significado |
|---|---|
| `claimed` | Afirmación no verificada |
| `confirmed` | Verificado por evidencia o autoridad |
| `deprecated` | Ya no relevante pero no falso |
| `unknown` | Información insuficiente para clasificar |

### Estado de exposición (gobernanza)

| Estado | Recuperable | Significado |
|---|---|---|
| `normal` | ✅ Recuperación normal | Estado predeterminado |
| `quarantined` | ❌ Oculto de la recuperación | En revisión por sensibilidad |
| `sealed` | ❌ Oculto, inmutable | Restringido legalmente o por política |
| `tombstoned` | ❌ Oculto, carga opcional | Marcado para eliminación |
| `lesson` | ✅ Solo lección | Carga sensible reemplazada por lección segura |

## Flujo de corrección

```text
Átomo original (positive)
    │
    ├── negate ──→ Nuevo átomo (negative) + arista Supersedes
    ├── confirm_actual ──→ Polaridad original confirmada + arista Supersedes
    ├── confirm_necessary ──→ Necesidad original confirmada
    ├── demote ──→ Estado epistémico original degradado
    └── replace ──→ Nuevo átomo (positive) + arista Supersedes + nuevo contenido
```

### Acciones de corrección

| Acción | Efecto |
|---|---|
| `negate` | Crea un átomo de polaridad negativa que reemplaza al objetivo |
| `confirm_actual` | Confirma la precisión factual del átomo |
| `confirm_necessary` | Confirma que el átomo sigue siendo relevante |
| `demote` | Degrada el estado epistémico (ej: confirmed → deprecated) |
| `replace` | Crea un nuevo átomo con contenido actualizado, reemplaza el anterior |


## Flujo de gobernanza

```text
normal → quarantined (en revisión)
quarantined → sealed (bloqueado, inmutable)
quarantined → tombstoned (eliminado de la recuperación)
quarantined → normal (despejado, restaurado)
cualquiera → derive_lesson (reemplazar carga con resumen seguro)
```

### Acciones de gobernanza

| Acción | De → A | Caso de uso |
|---|---|---|
| `quarantine` | normal → quarantined | Contenido sospechoso de sensibilidad |
| `seal` | quarantined → sealed | Retención legal, cumplimiento |
| `tombstone` | quarantined → tombstoned | Eliminar de la recuperación |
| `derive_lesson` | cualquiera → lesson | Extraer lección segura, eliminar carga sensible |


## Historial de instantáneas

Cada acción de corrección y gobernanza crea una instantánea inmutable que preserva el estado del átomo en el momento de la transición.

`memory_history` devuelve la cadena completa:

```text
Átomo creado (v1)
  → Corregido: negate (v2, Supersedes v1)
    → Gobernado: tombstone (v2 oculto de la recuperación normal)
      → Lección derivada (v3, resumen seguro visible en la recuperación)
```

## Vistas de recuperación

| Vista | Muestra | Caso de uso |
|---|---|---|
| `normal` | Solo átomos activos | Uso diario del agente |
| `governance` | + Átomos en cuarentena/sellados | Revisión de cumplimiento |
| `audit` | + Todos los átomos incluyendo tombstonados | Investigación forense |

La recuperación normal excluye intencionalmente las cargas gobernadas. La recuperación de auditoría muestra todo para responsabilidad.
