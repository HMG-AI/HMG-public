# HMG Konzepte

Dieses Dokument erklärt die Kernkonzepte von HMG: Speicheratome, Scope, Korrektur, Governance und Abruf.

## Speicheratome

Speicheratome sind die grundlegende Dateneinheit in HMG. Jedes Atom ist ein persistentes Informationsfragment mit strukturierten Metadaten.

### Atomstruktur

```
Atom {
  id:          ULID
  text:        String
  modality:    text|code|dialogue|observation
  source:      String
  polarity:    positive|negative|neutral
  epistemic:   claimed|confirmed|deprecated|unknown
  exposure:    normal|quarantined|sealed|tombstoned|lesson
  scope: { tenant_id, workspace, repository, branch, task_id, decision_id }
  timestamps:  created_at, updated_at
}
```

### Modalitäten

| Modalität | Verwendung |
|---|---|
| `text` | Allgemeine Texterinnerungen (Entscheidungen, Notizen, Beobachtungen) |
| `code` | Code-Snippets oder Architekturentscheidungen |
| `dialogue` | Gesprächsaufzeichnungen oder Interaktionen |
| `observation` | Passiv beobachtete Verhaltensmuster |

## Scope (Bereich)

Scope definiert die Kontextgrenzen der Erinnerung. HMG verwendet ein hierarchisches Scope-Modell:

```
tenant_id → workspace → repository → branch → task_id / decision_id
```

- **Exakte Übereinstimmung priorisieren**: Bei Abruf mit `branch` werden Zweig-spezifische Erinnerungen priorisiert
- **Fallback**: Keine Ergebnisse auf Zweigebene → Repository-, Workspace-, Tenant-Ebene
- **Leerer Scope**: Erinnerungen ohne Scope sind global

## Korrektur-Lebenszyklus

HMG überschreibt niemals Erinnerungen. Korrekturen erstellen neue Atome:

| Aktion | Wirkung |
|---|---|
| `negate` | Negativ-polares Atom erstellen, Ziel ersetzen |
| `confirm_actual` | Sachliche Richtigkeit bestätigen |
| `confirm_necessary` | Fortlaufende Relevanz bestätigen |
| `demote` | Epistemischen Status herabstufen |
| `replace` | Altes Atom durch neuen Inhalt ersetzen |

Siehe [Korrektur und Governance](correction-governance.md).

## Governance-Lebenszyklus

```
normal → quarantined → sealed / tombstoned / normal
beliebig → lesson
```

Siehe [Korrektur und Governance](correction-governance.md).

## Abruf (Recall)

Abruf ruft relevante Erinnerungen aus dem Speicher ab.

| Format | Verwendung |
|---|---|
| `compact` | Tägliche Agent-Nutzung (Standard) |
| `summary` | Menschlich lesbares Summary |
| `full` | Volle Details |
| `debug` | Diagnoseinformationen |

## Graphmodell

Atome sind durch typisierte Kanten verbunden: `Supersedes`, `DerivesFrom`, `RelatesTo`, `ScopedBy`.

## Domain Packs

Vordefinierte Erinnerungsvorlagen und Scope-Strategien. Mit `domain_pack_id` aktivieren.

## Nächste Schritte

- [Architektur](architecture.md)
- [API-Referenz](api-reference.md)
- [Korrektur und Governance](correction-governance.md)
