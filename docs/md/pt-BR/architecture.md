# Arquitetura HMG

## TUI
```bash
hmg tui
```

![HMG TUI — Dashboard](../img/tui-dashboard.png)

## Visão geral
```
AI Agent / IDE → (MCP / HTTP) → Binário HMG → Motor de Memória → Sistema de arquivos local
```

## Interfaces
| Interface | Protocolo | Uso |
|---|---|---|
| **MCP** | Model Context Protocol | Integração de agente (primário) |
| **HTTP API** | REST + JSON | Integração SDK |
| **CLI** | Terminal (`hmg`) | Administração |
| **TUI** | Terminal interativo (`hmg tui`) | Navegação visual |

## Agentes suportados
Cursor, pi, Claude Code, Codex, Windsurf, Aider, Continue — todos ✅

## Armazenamento
`~/.local/share/hmg/stores/default/` — Nenhum dado sai da máquina (Community/Developer Local).

## Edições
Binário único. Edição determinada pela chave de licença:
- Sem licença → Community (50K átomos, 5 agentes)
- `hmg-dev-...` → Developer (ilimitado, One-Shot Recall)
- `hmg-ent-...` → Enterprise (SSO, RBAC, multi-tenant)

## Segurança
Community: zero conexões de rede de saída. Vinculado ao localhost. Permissões de apenas usuário.
