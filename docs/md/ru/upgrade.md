# Руководство по обновлению

## Обновление HMG
```bash
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
hmg daemon restart
```

## Смена выпуска
### Community → Developer
```bash
hmg license apply hmg-dev-xxxxx && hmg daemon restart
```
### Developer → Enterprise
```bash
hmg license apply hmg-ent-xxxxx && hmg daemon restart
```
### Enterprise → Community
```bash
hmg license remove && hmg daemon restart
```

## Совместимость данных
Community→Developer: без миграции. v0.8→v0.9: автоматическая (рекомендуется резервная копия).

См. [CHANGELOG.md](https://github.com/HMG-AI/HMG-public/blob/main/CHANGELOG.md).
