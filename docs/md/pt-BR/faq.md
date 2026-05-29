# FAQ

## Geral
### O que é HMG?
Sistema de memória persistente para agentes IA via MCP.

### É seguro?
Sim. Community: zero conexões de saída, localhost, sem telemetria.

### Plataformas?
Linux, macOS, Windows (WSL).

## Instalação
```bash
curl -fsSL https://raw.githubusercontent.com/HMG-AI/HMG-public/main/scripts/install.sh | sh
```

## Edições
| | Community | Developer | Enterprise |
|---|---|---|---|
| Átomos | 50.000 | Ilimitados | Ilimitados |
| Busca semântica | ❌ | ✅ | ✅ |
| One-Shot Recall | ✅ | ✅ | ✅ |
| SSO/RBAC | ❌ | ❌ | ✅ |

Upgrade: `hmg license apply <your-key> && hmg daemon restart`

## Problemas
- Agente não encontra HMG: `hmg doctor`
- Daemon não inicia: verificar porta (`lsof -i :3000`)
