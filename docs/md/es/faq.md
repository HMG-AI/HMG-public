# FAQ

## General

### ¿Qué es HMG?
HMG (Holographic Memory Graph) es un sistema de memoria persistente para agentes IA — almacenamiento estructurado, recuperación inteligente, corrección y gobernanza vía MCP.

### ¿Por qué memoria persistente?
Sin memoria, los agentes olvidan todo cada sesión. Repiten errores, olvidan decisiones, no mantienen consistencia.

### ¿Es seguro?
Sí. Community: cero conexiones salientes, localhost, permisos de usuario, sin telemetría.

### ¿Plataformas soportadas?
Linux (x86_64, ARM64), macOS (Intel, Apple Silicon), Windows (WSL).

## Instalación

```bash
curl -fsSL https://raw.githubusercontent.com/HMG-AI/HMG-public/main/scripts/install.sh | sh
```

Conectar agente: `hmg init --agent cursor|codex|pi|windsurf|aider`

## Uso

- Memoria organizada como **átomos** con tipo, alcance y metadatos
- Corrección: nunca sobrescribe, crea nuevos átomos con aristas Supersedes
- Gobernanza: cuarentena, sellado, tombstone, lección derivada
- Community: One-Shot Recall (P1-P9). Developer: límites eliminados + consolidación automática.

## Ediciones

| Función | Community | Developer | Enterprise |
|---|---|---|---|
| Memorizar y recuperar | ✅ | ✅ | ✅ |
| Corrección y gobernanza | ✅ | ✅ | ✅ |
| Átomos | 50.000 | Ilimitados | Ilimitados |
| Búsqueda semántica | ❌ | ✅ | ✅ |
| One-Shot Recall | ✅ | ✅ | ✅ |
| SSO / RBAC | ❌ | ❌ | ✅ |

Upgrade: `hmg license apply <your-key> && hmg daemon restart`

## Resolución de problemas

- Agente no encuentra HMG: `hmg doctor`
- Daemon no inicia: verificar puerto (`lsof -i :3000`)
- Resultados incorrectos: verificar scope, usar perfil `debug`
