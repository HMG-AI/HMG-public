# Architecture HMG

Ce document fournit un aperçu de haut niveau du fonctionnement de HMG au niveau conceptuel — sans détails d'implémentation propriétaires.

## Visite guidée — TUI

HMG inclut une interface terminal (TUI) intégrée pour naviguer, rechercher et gérer votre stock de mémoire.

Lancez avec :

```bash
hmg tui
```

![HMG TUI — Tableau de bord](../img/tui-dashboard.png)

Le tableau de bord affiche le nombre d'atomes, l'état des index, la santé du daemon et les prochaines actions recommandées.

### Écran Doctor

Vérifiez toutes les intégrations et la préparation système :

![HMG TUI — Doctor](../img/tui-doctor.png)

### Écran Recall

Recherchez dans votre mémoire et visualisez les résultats projetés :

![HMG TUI — Recall](../img/tui-recall.png)

### Écran Timeline

Parcourez les événements de mémoire chronologiquement :

![HMG TUI — Timeline](../img/tui-timeline.png)

### Écran Integrations

Voyez quels agents sont détectés et configurés :

![HMG TUI — Integrations](../img/tui-integrations.png)

### Écran Store

Surveillez le statut du daemon, les chemins de stockage et les versions d'instantanés :

![HMG TUI — Store](../img/tui-daemon_store.png)

### Écran Settings

Configurez la langue (15 locales) et le thème :

![HMG TUI — Settings](../img/tui-settings.png)

## Vue d'ensemble du système

```
┌──────────────────────────────────────────────────────────┐
│                    AI Agent / IDE                         │
│  (Cursor, Claude Code, pi, Codex, Windsurf, ...)         │
└────────────┬─────────────────────────────┬───────────────┘
             │ MCP                          │ HTTP / SDK
             ▼                              ▼
┌──────────────────────────────────────────────────────────┐
│                    Binaire HMG                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐               │
│  │   MCP    │  │   HTTP   │  │   CLI    │               │
│  │ Handlers │  │    API   │  │  (hmg)   │               │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘               │
│       │             │             │                       │
│       └─────────────┼─────────────┘                       │
│                     ▼                                     │
│  ┌──────────────────────────────────────────┐            │
│  │         Moteur de mémoire                 │            │
│  │  ┌────────┐ ┌────────┐ ┌───────────┐    │            │
│  │  │ Graphe │ │ Index  │ │ Stockage  │    │            │
│  │  │ Modèle │ │(requête)│ │(persist.) │    │            │
│  │  └────────┘ └────────┘ └───────────┘    │            │
│  └──────────────────────────────────────────┘            │
│                     │                                     │
│                     ▼                                     │
│         Système de fichiers local (~/.local/share/hmg/)   │
└──────────────────────────────────────────────────────────┘
```

## Composants

### Interfaces

HMG fournit quatre surfaces d'accès :

| Interface | Protocole | Cas d'utilisation |
|---|---|---|
| **MCP** | Model Context Protocol | Intégration agent (principal) |
| **HTTP API** | REST + JSON | Intégration SDK, outils personnalisés |
| **CLI** | Terminal (commande `hmg`) | Administration, débogage, scripts |
| **TUI** | Terminal interactif (`hmg tui`) | Navigation et gestion visuelles |

Les quatre surfaces exposent les mêmes capacités — stockage, rappel, correction et gouvernance.

### Moteur de mémoire

Le cœur de HMG. Il gère :

- **Modèle de graphe** : Atomes connectés par des arêtes typées (Supersedes, DerivesFrom, RelatesTo, etc.)
- **Index** : Recherche par mots-clés, ordre temporel, regroupement catégoriel, et (Developer+) recherche sémantique
- **Stockage** : Stockage local persistant avec historique d'instantanés

### Intégration d'agents

`hmg init --agent <id>` configure un agent pour utiliser HMG comme couche mémoire. Agents supportés :

| Agent | Statut |
|---|---|
| Cursor | ✅ Supporté |
| pi (Codex fork) | ✅ Supporté |
| Claude Code | ✅ Supporté |
| Codex | ✅ Supporté |
| Windsurf | ✅ Supporté |
| Aider | ✅ Supporté |
| Continue | ✅ Supporté |

## Flux de données

### Mémoriser

```
Agent → "Souviens-toi de ça : ..." → HMG
  → Valider l'entrée
  → Créer un atome typé
  → Attacher portée et contexte
  → Indexer pour récupération (mots-clés + temporel + catégoriel)
  → Persister vers le stockage local
  → Retourner ID atome + accusé
```

![Agent appelant memory_memorize](../img/agent-memorize.png)

### Rappeler

```
Agent → "Quelle base de données avons-nous choisie ?" → HMG
  → Analyser l'intention de la requête
  → Récupérer les candidats depuis les index
  → Classer par pertinence, certitude, fraîcheur
  → Filtrer par portée et état de gouvernance
  → Projeter les atomes connexes par traversée de graphe
  → Formater la sortie selon l'Agent Tool Output Contract
  → Retourner résultat structuré + diagnostics
```

![Agent appelant memory_recall](../img/agent-recall.png)

### Corriger

```
Agent → "C'est faux, en fait c'est ..." → HMG
  → Créer un atome de correction (action + raison)
  → Lier par arête Supersedes
  → Mettre à jour la polarité/statut épistémique de l'original
  → Persister l'historique de correction
  → Retourner confirmation de correction
```

![Agent appelant memory_correct](../img/agent-correct.png)

### Gouverner

```
Admin → "Scelle cette mémoire sensible" → HMG
  → Valider l'action de gouvernance
  → Transitionner l'état d'exposition (visible → sealed)
  → Optionnellement dériver un atome de leçon sécurisée
  → Persister l'enregistrement de gouvernance
  → Le contenu original devient irrécupérable (sealed)
```

![Agent appelant memory_govern](../img/agent-govern.png)

## Stockage

HMG stocke toutes les données localement sur la machine où il s'exécute :

```
~/.local/share/hmg/
  stores/
    default/           ← Stock de mémoire par défaut
      graph/           ← Données d'atomes et d'arêtes
      indexes/         ← Index de recherche
      snapshots/       ← Historique correction/gouvernance
```

Aucune donnée ne quitte la machine dans les éditions Community et Developer Local.

## Architecture des éditions

HMG est un binaire unique contenant le code de toutes les éditions. L'édition active est déterminée au démarrage :

```
Binaire HMG
  │
  ├── Pas de clé de licence → Community Edition
  │     └── Recherche par mots-clés, 50K atomes, 5 agents, fonctionnalités de base
  │
  ├── HMG_LICENSE_KEY=hmg-dev-... → Developer Edition
  │     └── One-Shot Recall, consolidation auto, Domain Packs, illimité
  │
  ├── HMG_LICENSE_KEY=hmg-ent-... → Enterprise Edition
  │     └── Toutes les fonctionnalités, SSO, RBAC, multi-tenant, audit
  │
  └── HMG_CLOUD_TOKEN → Connecté au cloud
        └── Developer ou Enterprise via authentification cloud
```

Cela signifie :
- Pas de binaires séparés à maintenir
- La mise à niveau est instantanée : `export HMG_LICENSE_KEY=...` et redémarrage
- Les utilisateurs Community bénéficient de la même qualité binaire que Enterprise

## Frontières de sécurité

```
┌─────────────────────────────────┐
│      Processus agent             │
│   (exécute avec permissions user)│
└──────────────┬──────────────────┘
               │ MCP / HTTP (localhost)
               ▼
┌─────────────────────────────────┐
│      Processus HMG               │
│   (lié à localhost:8080)         │
│                                  │
│   Données mémoire : accès user   │
│   Pas de connexions sortantes (CE)│
│   Pas de télémétrie (CE)         │
└─────────────────────────────────┘
```

- L'édition Community établit **zéro connexion réseau sortante**
- HMG se lie par défaut à `localhost` — non exposé au réseau
- Les fichiers de stockage utilisent des permissions user uniquement

## Prochaines étapes

- [Concepts](concepts.md) — Atomes mémoire, correction, gouvernance, portée
- [Référence API](api-reference.md) — Tous les outils MCP et endpoints HTTP
- [Sécurité](security.md) — Modèle de sécurité et signalement
