# Correction et gouvernance

HMG utilise un **modèle de correction et de gouvernance à ajout uniquement**. Les atomes ne sont jamais écrasés silencieusement. Au lieu de cela, les corrections créent de nouveaux atomes avec des relations explicites, et les transitions de gouvernance préservent l'historique complet.

## États du cycle de vie des atomes

### Polarité

Chaque atome possède une polarité indiquant son statut de vérité :

| Polarité | Signification |
|---|---|
| `positive` | L'atome est affirmé comme vrai |
| `negative` | L'atome a été nié ou remplacé |
| `neutral` | Informationnel — aucune assertion de vérité |

### Statut épistémique

| Statut | Signification |
|---|---|
| `claimed` | Affirmation non vérifiée |
| `confirmed` | Vérifié par des preuves ou une autorité |
| `deprecated` | Plus pertinent mais pas faux |
| `unknown` | Informations insuffisantes pour classifier |

### État d'exposition (gouvernance)

| État | Rappelable | Signification |
|---|---|---|
| `normal` | ✅ Rappel normal | État par défaut |
| `quarantined` | ❌ Masqué du rappel | En cours de révision pour sensibilité |
| `sealed` | ❌ Masqué, immuable | Restreint légalement ou par politique |
| `tombstoned` | ❌ Masqué, charge utile optionnelle | Marqué pour suppression |
| `lesson` | ✅ Leçon uniquement | Charge sensible remplacée par une leçon sécurisée |

## Flux de correction

Les corrections créent des arêtes `Supersedes` explicites entre les atomes :

```text
Atome original (positive)
    │
    ├── negate ──→ Nouvel atome (negative) + arête Supersedes
    ├── confirm_actual ──→ Polarité originale confirmée + arête Supersedes
    ├── confirm_necessary ──→ Nécessité originale confirmée
    ├── demote ──→ Statut épistémique original abaissé
    └── replace ──→ Nouvel atome (positive) + arête Supersedes + nouveau contenu
```

### Actions de correction

| Action | Effet |
|---|---|
| `negate` | Crée un atome de polarité négative qui remplace la cible |
| `confirm_actual` | Confirme l'exactitude factuelle de l'atome |
| `confirm_necessary` | Confirme que l'atome reste pertinent |
| `demote` | Abaisse le statut épistémique (ex: confirmed → deprecated) |
| `replace` | Crée un nouvel atome avec un contenu mis à jour, remplace l'ancien |

![Agent appelant memory_correct (replace)](../img/agent-correct.png)

## Flux de gouvernance

Les transitions de gouvernance protègent les mémoires sensibles ou obsolètes :

```text
normal → quarantined (en cours de révision)
quarantined → sealed (verrouillé, immuable)
quarantined → tombstoned (supprimé du rappel)
quarantined → normal (effacé, restauré)
tout → derive_lesson (remplacer la charge par un résumé sécurisé)
```

### Actions de gouvernance

| Action | De → Vers | Cas d'utilisation |
|---|---|---|
| `quarantine` | normal → quarantined | Contenu soupçonné de sensibilité |
| `seal` | quarantined → sealed | Conservation légale, conformité |
| `tombstone` | quarantined → tombstoned | Suppression du rappel |
| `derive_lesson` | tout → lesson | Extraire une leçon sécurisée, supprimer la charge sensible |

![Agent appelant memory_govern (quarantine)](../img/agent-govern.png)

## Historique des instantanés

Chaque action de correction et de gouvernance crée un instantané immuable.
Les instantanés préservent l'état de l'atome au moment de la transition.

L'outil `memory_history` retourne la chaîne complète :

```text
Atome créé (v1)
  → Corrigé : negate (v2, Supersedes v1)
    → Gouverné : tombstone (v2 masqué du rappel normal)
      → Leçon dérivée (v3, résumé sécurisé visible dans le rappel)
```

## Vues de rappel

HMG prend en charge trois vues de rappel avec des règles de visibilité différentes :

| Vue | Affiche | Cas d'utilisation |
|---|---|---|
| `normal` | Atomes actifs uniquement (polarité positive, exposition normal) | Usage agent quotidien |
| `governance` | + Atomes en quarantaine/scellés | Revue de conformité |
| `audit` | + Tous les atomes y compris tombstonés, chaîne de correction complète | Investigation forensique |

Le rappel normal exclut intentionnellement les charges gouvernées. Le rappel d'audit affiche tout pour la responsabilité.
