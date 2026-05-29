# Arquitectura HMG

## Tour visual — TUI

```bash
hmg tui
```


### Pantallas: Doctor | Recall | Timeline | Integrations | Store | Settings


## Vista general del sistema

```
AI Agent / IDE → (MCP / HTTP) → HMG Binario → Motor de Memoria → Sistema de archivos local
```

## Interfaces

| Interfaz | Protocolo | Uso |
|---|---|---|
| **MCP** | Model Context Protocol | Integración de agente (principal) |
| **HTTP API** | REST + JSON | Integración SDK |
| **CLI** | Terminal (`hmg`) | Administración, debugging |
| **TUI** | Terminal interactivo (`hmg tui`) | Navegación visual |

## Agentes soportados

Cursor, pi, Claude Code, Codex, Windsurf, Aider, Continue — todos ✅

## Almacenamiento

```
~/.local/share/hmg/stores/default/
  graph/  indexes/  snapshots/
```

Ningún dato sale de la máquina en Community y Developer Local.

## Arquitectura de ediciones

Un solo binario. La edición se determina al iniciar:

- Sin licencia → Community (50K átomos, 5 agentes)
- `<key>` → Developer (ilimitado, One-Shot Recall)
- `<key>` → Enterprise (SSO, RBAC, multi-tenant)

## Límites de seguridad

- Community: cero conexiones de red salientes
- Vinculado a localhost por defecto
- Archivos con permisos de solo usuario

## Próximos pasos

- [Conceptos](concepts.md)
- [Referencia API](api-reference.md)
- [Seguridad](security.md)
