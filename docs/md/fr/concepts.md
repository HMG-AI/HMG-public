# HMG — Concepts

Ce document explique les concepts fondamentaux de HMG : les atomes de mémoire, la portée, la correction, la gouvernance et le rappel.

## Atomes de mémoire

L'atome de mémoire est l'unité de données fondamentale dans HMG. Chaque atome est un fragment d'information persistant avec des métadonnées structurées.

### Structure d'un atome

```
Atom {
  id:          ULID          // Identifiant unique
  text:        String        // Contenu mémorisé
  modality:    text|code|dialogue|observation
  source:      String        // Étiquette de source
  polarity:    positive|negative|neutral
  epistemic:   claimed|confirmed|deprecated|unknown
  exposure:    normal|quarantined|sealed|tombstoned|lesson
  scope: {
    tenant_id, workspace, repository, branch, task_id, decision_id
  }
  timestamps:  created_at, updated_at
}
```

### Modalités

| Modalité | Usage |
|---|---|
| `text` | Mémoire textuelle générale (décisions, notes, observations) |
| `code` | Extraits de code ou décisions d'architecture |
| `dialogue` | Enregistrements de conversation ou interactions |
| `observation` | Patterns de comportement observés passivement |

## Portée (Scope)

La portée définit les limites contextuelles de la mémoire. HMG utilise un modèle de portée hiérarchique :

```
tenant_id         // Organisation ou compte
  └── workspace   // Groupe de projets ou équipe
       └── repository  // Base de code
            └── branch  // Branche
                 ├── task_id     // Tâche
                 └── decision_id // Décision
```

### Comportement de la portée

- **Correspondance exacte prioritaire** : Si un `branch` est fourni lors du rappel, HMG priorise les mémoires de cette branche
- **Remontée** : Si aucun résultat au niveau de la branche, remonte aux niveaux repository, workspace, tenant
- **Portée vide** : Les mémoires sans portée sont traitées comme globales

## Cycle de vie de correction

HMG ne remplace jamais les mémoires. Au lieu de cela, la correction crée de nouveaux atomes connectés par des arêtes :

### Actions de correction

| Action | Effet |
|---|---|
| `negate` | Crée un atome de polarité négative, remplace la cible |
| `confirm_actual` | Confirme l'exactitude factuelle |
| `confirm_necessary` | Confirme la pertinence continue |
| `demote` | Abaisse le statut épistémique |
| `replace` | Remplace l'ancien atome par un nouveau contenu |

Chaque correction crée un historique d'instantanés immuable.

Voir [Correction et gouvernance](correction-governance.md) pour plus de détails.

## Cycle de vie de gouvernance

La gouvernance protège les mémoires sensibles ou obsolètes :

```
normal → quarantined → sealed     (verrouillé)
                    → tombstoned  (supprimé)
                    → normal      (restauré)
tout   → lesson                   (leçon extraite)
```

Les atomes gouvernés sont masqués du rappel normal mais conservés dans la piste d'audit.

Voir [Correction et gouvernance](correction-governance.md) pour plus de détails.

## Rappel (Recall)

Le rappel récupère les mémoires pertinentes depuis le stockage.

### Flux de rappel

```
Requête → Analyse d'intention → Recherche d'index → Classement → Filtrage de portée → Projection par traversée de graphe → Formatage de sortie
```

### Formats de réponse

| Format | Usage |
|---|---|
| `compact` | Usage agent quotidien (par défaut) |
| `summary` | Résumé lisible par l'humain |
| `full` | Détails complets |
| `debug` | Informations de diagnostic incluses |

### Recherche sémantique

L'édition Community prend en charge la recherche par mots-clés. L'édition Developer ajoute la recherche sémantique vectorielle.

## Modèle de graphe

Les atomes sont interconnectés par des arêtes typées :

| Type d'arête | Signification |
|---|---|
| `Supersedes` | Relation de correction/remplacement |
| `DerivesFrom` | Relation de dérivation/apprentissage |
| `RelatesTo` | Association générale |
| `ScopedBy` | Appartenance de portée |

La traversée de graphe permet aux opérations de rappel de projeter des mémoires connexes au-delà des résultats correspondant directement.

## Packs de domaine

Les packs de domaine sont des modèles de mémoire et des stratégies de portée prédéfinis :

- **Software Engineering** : Modèle de portée pour les bases de code, branches et tâches
- Packs de domaine personnalisés (Developer/Enterprise)

Activés avec le paramètre `domain_pack_id`.

## Prochaines étapes

- [Architecture](architecture.md) — Fonctionnement de haut niveau de HMG
- [Référence API](api-reference.md) — Tous les outils MCP et endpoints HTTP
- [Correction et gouvernance](correction-governance.md) — Flux détaillés de correction et gouvernance
