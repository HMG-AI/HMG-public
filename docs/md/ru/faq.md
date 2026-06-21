# Часто задаваемые вопросы

## Общие
### Что такое HMG?
Система постоянной памяти для ИИ-агентов через MCP.

### Безопасно ли?
Да. Community: нуль исходящих соединений, localhost, без телеметрии.

### Платформы?
Linux, macOS, Windows (WSL).

## Установка
```bash
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
```

## Выпуски
| | Community | Developer | Enterprise |
|---|---|---|---|
| Атомы | 50 000 | Безлимит | Безлимит |
| Семантический поиск | ❌ | ✅ | ✅ |
| One-Shot Recall | ✅ | ✅ | ✅ |
| SSO/RBAC | ❌ | ❌ | ✅ |

Обновление: `hmg license apply <your-key> && hmg daemon restart`

## Устранение неполадок
- Агент не находит HMG: `hmg doctor`
- Демон не запускается: проверить порт (`lsof -i :7654`)
