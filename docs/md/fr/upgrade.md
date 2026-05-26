# Guide de mise à niveau

Ce document explique comment mettre à niveau HMG et changer d'édition.

## Mise à niveau de HMG

### Depuis v0.9.x

```bash
# Télécharger la dernière version
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh

# Redémarrer le daemon
hmg daemon restart

# Vérifier la version
hmg --version
```

### Mise à niveau manuelle

```bash
# Linux x86_64
curl -L https://github.com/HMG-AI/HMG-public/releases/latest/download/hmg-x86_64-unknown-linux-gnu.tar.gz | tar -xzf - -C ~/.local/bin/

# macOS Apple Silicon
curl -L https://github.com/HMG-AI/HMG-public/releases/latest/download/hmg-aarch64-apple-darwin.tar.gz | tar -xzf - -C ~/.local/bin/
```

### Depuis v0.8.x

v0.9.x inclut des changements de format de stockage. HMG migre automatiquement :

```bash
hmg daemon start
# Migration automatique du format v0.8 au premier démarrage
```

La migration est automatique et irréversible. Sauvegarde recommandée :

```bash
cp -r ~/.local/share/hmg ~/.local/share/hmg.bak-v0.8
```

## Changement d'édition

HMG utilise un binaire unique. L'édition est déterminée par la clé de licence :

### Community → Developer

```bash
hmg license apply hmg-dev-xxxxx
hmg daemon restart
```

Débloque immédiatement : atomes illimités, recherche sémantique, One-Shot Recall, Domain Packs.

### Developer → Enterprise

```bash
hmg license apply hmg-ent-xxxxx
hmg daemon restart
```

Débloque immédiatement : SSO, RBAC, multi-tenant, export d'audit.

### Enterprise → Community

```bash
hmg license remove
hmg daemon restart
```

Retour aux limites Community. Les données sont conservées mais les atomes excédentaires deviennent en lecture seule.

## Compatibilité des données

| De → Vers | Action de migration |
|---|---|
| Community → Developer | Aucune migration |
| Community → Enterprise | Aucune migration |
| Developer → Enterprise | Aucune migration |
| v0.8 → v0.9 | Migration automatique (premier démarrage) |

## Journal des modifications

Voir [CHANGELOG.md](https://github.com/HMG-AI/HMG-public/blob/main/CHANGELOG.md) pour le journal complet.
