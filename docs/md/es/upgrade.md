# Guía de actualización

## Actualizar HMG

### Desde v0.9.x
```bash
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
hmg daemon restart
```

### Desde v0.8.x
v0.9.x incluye cambios de formato. Migración automática al primer inicio. Backup recomendado:
```bash
cp -r ~/.local/share/hmg ~/.local/share/hmg.bak-v0.8
```

## Cambiar edición

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

## Compatibilidad de datos

Community→Developer: sin migración. Community→Enterprise: sin migración. v0.8→v0.9: automática.

Ver [CHANGELOG.md](https://github.com/HMG-AI/HMG-public/blob/main/CHANGELOG.md).
