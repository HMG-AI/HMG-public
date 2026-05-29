# FAQ

## Général

### Qu'est-ce que HMG ?

HMG (Holographic Memory Graph) est un système de mémoire persistant pour les agents IA. Il offre un stockage structuré, un rappel intelligent, un suivi des corrections et des capacités de gouvernance — exécuté comme service local, intégré via le protocole MCP.

### Pourquoi les agents IA ont-ils besoin de mémoire persistante ?

Sans mémoire, les agents oublient tout à chaque session. Ils répètent les mêmes erreurs, oublient les décisions d'architecture, et ne maintiennent pas de cohérence entre projets. HMG donne aux agents une « mémoire de travail » persistante qui s'améliore avec le temps.

### HMG est-il sécurisé ?

Oui. L'édition Community :
- **Zéro connexion réseau sortante** — les données ne quittent jamais votre machine
- Lié à `localhost` — non exposé au réseau
- Stockage fichiers avec permissions utilisateur uniquement
- Pas de télémétrie ni d'analytique

Voir [Sécurité](security.md).

### Quelles plateformes sont supportées ?

- Linux (x86_64, ARM64)
- macOS (Intel, Apple Silicon)
- Windows (via WSL ou toolchain GNU)

## Installation et configuration

### Comment installer ?

```bash
curl -fsSL https://raw.githubusercontent.com/HMG-AI/HMG-public/main/scripts/install.sh | sh
```

Voir [Démarrage rapide](getting-started.md).

### Comment connecter mon agent ?

```bash
hmg init --agent cursor    # Cursor
hmg init --agent codex     # Claude Code / Codex
hmg init --agent pi        # Pi
hmg init --agent windsurf  # Windsurf
hmg init --agent aider     # Aider
```

### Puis-je personnaliser l'emplacement de stockage ?

Oui. Définissez la variable d'environnement `HMG_STORE_PATH` :

```bash
export HMG_STORE_PATH=/chemin/personnalisé/hmg-store
hmg daemon start
```

## Utilisation

### Comment la mémoire est-elle organisée ?

La mémoire est stockée sous forme d'**atomes** — unités d'information structurées avec type, portée et métadonnées. Les atomes sont interconnectés par des arêtes dans un graphe (remplacement, dérivation, association).

Voir [Concepts](concepts.md).

### Comment fonctionne la correction ?

HMG ne remplace jamais les mémoires. La correction crée de nouveaux atomes liés à l'original par une arête `Supersedes`. Supporte : négation, confirmation, rétrogradation et remplacement.

Voir [Correction et gouvernance](correction-governance.md).

### Qu'est-ce que la gouvernance ?

La gouvernance protège les mémoires sensibles. Actions : quarantaine (en révision), scellement (verrouillé), tombstone (suppression), dérivation de leçon (extraction d'un résumé sécurisé).

Voir [Correction et gouvernance](correction-governance.md).

### La mémoire est-elle recherchable ?

Oui. L'édition Community supporte la recherche par mots-clés. L'édition Developer ajoute la recherche sémantique vectorielle.

## Éditions

### Quelle est la différence entre Community, Developer et Enterprise ?

| Fonctionnalité | Community | Developer | Enterprise |
|---|---|---|---|
| Mémoriser et rappeler | ✅ | ✅ | ✅ |
| Correction et gouvernance | ✅ | ✅ | ✅ |
| Protocole MCP | ✅ | ✅ | ✅ |
| Nombre d'atomes | 50 000 | Illimité | Illimité |
| Recherche sémantique | ❌ | ✅ | ✅ |
| One-Shot Recall | ✅ | ✅ | ✅ |
| Domain Packs | ❌ | ✅ | Tous |
| SSO / RBAC | ❌ | ❌ | ✅ |
| Prix | Gratuit | Abonnement | Nous contacter |

### Comment passer à Developer ?

```bash
hmg license apply <your-key>
hmg daemon restart
```

Pas de réinstallation — même binaire.

Voir [Guide de mise à niveau](upgrade.md).

## Dépannage

### L'agent ne trouve pas les outils HMG

1. Vérifiez que le daemon fonctionne : `hmg daemon status`
2. Vérifiez la configuration agent : `hmg doctor`
3. Redémarrez votre agent/IDE

### `hmg daemon start` échoue

1. Vérifiez si le port est utilisé : `lsof -i :3000`
2. Vérifiez les permissions du chemin de stockage
3. Exécutez `hmg doctor` pour diagnostiquer

### Le rappel retourne des résultats incorrects

1. Vérifiez que les champs de portée sont corrects (repository, branch)
2. Essayez `response_profile: "debug"` pour voir les diagnostics
3. Vérifiez si des mémoires obsolètes nécessitent une correction
