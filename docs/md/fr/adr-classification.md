# Classification de publication des ADR

Selon l'ADR 2026-05-24 (v2) §Frontière de documentation, tous les ADR doivent être classifiés avant toute publication. Ce document enregistre la classification de chaque ADR.

**Date de classification :** 2026-05-25

## Légende de classification

| Marque | Signification |
|---|---|
| **Public** | Peut être publié tel quel |
| **Sanitize** | Peut être publié après suppression des détails d'algorithmes/hooks internes |
| **Private** | Doit rester dans le monorepo privé — révèle des éléments propriétaires |

## Classification

| ADR | Titre | Classification | Justification |
|---|---|---|---|
| 2026-05-17 | Compilateur sémantique Domain Lens | **Sanitize** | L'ADR v2 indique « Publier le RFC uniquement — le concept est stratégique ; les détails du compilateur restent privés ». Supprimer l'implémentation du compilateur, garder le concept et la spécification de portée. |
| 2026-05-18 | Architecture d'échelle des cinq goulots | **Private** | Révèle les internes de réglage stockage/index et l'architecture de mise à l'échelle |
| 2026-05-18 | Matrice d'expériences de précision de rappel | **Private** | L'ADR v2 indique « Garder privé — révèle la méthodologie d'expérimentation » |
| 2026-05-19 | Plan de contrôle mémoire / Gateway LLM optionnel | **Private** | Révèle l'architecture du plan de contrôle (fonctionnalité entreprise) |
| 2026-05-20 | Agent Brief v2 compact localisé | **Sanitize** | L'ADR v2 indique « Assainir et publier — le format brief est un protocole ; supprimer les détails de rendu internes » |
| 2026-05-20 | Acquittements d'outil d'écriture compact | **Sanitize** | Le format de sortie est un protocole ; supprimer la logique de rendu interne |
| 2026-05-20 | Chemin de stockage local et daemon | **Public** | Installation publique / comportement du daemon — pas d'internes propriétaires |
| 2026-05-20 | Couche de requête gouvernée MemoryQL | **Private** | Révèle la logique de réécriture de requête gouvernée (propriétaire) |
| 2026-05-21 | Consolidation d'observation biomimétique | **Private** | L'ADR v2 indique « Garder privé — révèle l'architecture de consolidation » |
| 2026-05-21 | Runtime communautaire standard ouvert v1 | **Private** | Remplacé par v2 ; v1 décrit un modèle source-available non utilisé. Garder pour l'historique. |
| 2026-05-21 | Ratatui Hippocampus TUI | **Sanitize** | Le TUI est intégré au binaire ; publier concept/fonctionnalités, supprimer les détails de rendu de panneau |
| 2026-05-23 | Conformité d'adoption agent | **Sanitize** | L'ADR v2 indique « Assainir et publier — le protocole d'adoption est public ; supprimer les détails de chemins de hooks internes » |
| 2026-05-23 | Profils de sortie d'outil agent | **Sanitize** | Les profils de sortie font partie du contrat de sortie d'outil agent (protocole public) |
| 2026-05-24 | Portée mémoire agent et rappel orienté requête | **Sanitize** | Le modèle de portée est public (spec §6) ; supprimer les internes de classement/scoring |
| 2026-05-24 | Contrat de sortie d'outil agent v2 | **Public** | L'ADR v2 indique « Publier — c'EST le standard de protocole » |
| 2026-05-24 | Moteur One-Shot Recall | **Private** | L'ADR v2 indique « Garder privé — révèle le principal fossé défensif » |
| 2026-05-24 | Standard ouvert v2 (cet ADR) | **Private** | Contient la stratégie commerciale complète, la tarification, le playbook défensif, l'ébauche de licence — garder privé |
| 2026-05-24 | Métriques de qualité v0.9.2 | **Private** | L'ADR v2 indique « Garder privé — révèle le réglage de performance » |

## Résumé

| Classification | Nombre | ADR |
|---|---|---|
| **Public** | 2 | 2026-05-20-local-store, 2026-05-24-agent-tool-output-contract-v2 |
| **Sanitize** | 6 | 2026-05-17, 2026-05-20 (brief, compact), 2026-05-21 (tui), 2026-05-23 (adoption, profiles), 2026-05-24 (scope) |
| **Private** | 11 | 2026-05-18 (les deux), 2026-05-19, 2026-05-20 (memoryql), 2026-05-21 (observation, osr-v1), 2026-05-23 (consolidation), 2026-05-24 (oneshot, osr-v2, quality) |

## Actions requises

1. Les 2 ADR Public peuvent être copiés immédiatement vers `export/docs/adr/`.
2. Les 6 ADR Sanitize nécessitent une révision manuelle pour supprimer les sections propriétaires.
3. Les 11 ADR Private restent dans le monorepo privé indéfiniment.
