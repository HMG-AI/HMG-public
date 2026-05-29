# Guia de atualização

## Atualizar HMG
```bash
curl -fsSL https://raw.githubusercontent.com/HMG-AI/HMG-public/main/scripts/install.sh | sh
hmg daemon restart
```

## Trocar edição
### Community → Developer
```bash
hmg license apply <your-key> && hmg daemon restart
```
### Developer → Enterprise
```bash
hmg license apply <your-key> && hmg daemon restart
```
### Enterprise → Community
```bash
hmg license remove && hmg daemon restart
```

## Compatibilidade
Community→Developer: sem migração. v0.8→v0.9: automática (backup recomendado).

Veja [CHANGELOG.md](https://github.com/HMG-AI/HMG-public/blob/main/CHANGELOG.md).
