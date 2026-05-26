# Korrektur und Governance

HMG verwendet ein **append-only Korrektur- und Governance-Modell**. Atome werden nie stillschweigend überschrieben. Stattdessen erstellen Korrekturen neue Atome mit expliziten Beziehungen, und Governance-Übergänge bewahren die vollständige Historie.

## Atom-Lebenszykluszustände

### Polarität

Jedes Atom hat eine Polarität, die seinen Wahrheitsstatus angibt:

| Polarität | Bedeutung |
|---|---|
| `positive` | Das Atom wird als wahr behauptet |
| `negative` | Das Atom wurde negiert oder ersetzt |
| `neutral` | Informational — keine Wahrheitsbehauptung |

### Epistemischer Status

| Status | Bedeutung |
|---|---|
| `claimed` | Ungeprüfte Behauptung |
| `confirmed` | Durch Beweise oder Autorität verifiziert |
| `deprecated` | Nicht mehr relevant, aber nicht falsch |
| `unknown` | Nicht genügend Informationen zur Klassifizierung |

### Offenlegungszustand (Governance)

| Zustand | Abrufbar | Bedeutung |
|---|---|---|
| `normal` | ✅ Normaler Abruf | Standardzustand |
| `quarantined` | ❌ Vom Abruf verborgen | Überprüfung wegen Sensibilität |
| `sealed` | ❌ Verborgen, unveränderlich | Rechtlich oder richtlinienmäßig eingeschränkt |
| `tombstoned` | ❌ Verborgen, Payload optional | Zur Löschung markiert |
| `lesson` | ✅ Nur Lektion | Sensible Payload durch sichere Lektion ersetzt |

## Korrekturfluss

Korrekturen erstellen explizite `Supersedes`-Kanten zwischen Atomen:

```text
Originalatom (positive)
    │
    ├── negate ──→ Neues Atom (negative) + Supersedes-Kante
    ├── confirm_actual ──→ Originalpolarität bestätigt + Supersedes-Kante
    ├── confirm_necessary ──→ Originalnotwendigkeit bestätigt
    ├── demote ──→ Epistemischer Status des Originals herabgestuft
    └── replace ──→ Neues Atom (positive) + Supersedes-Kante + neuer Inhalt
```

### Korrekturaktionen

| Aktion | Wirkung |
|---|---|
| `negate` | Erstellt ein Atom mit negativer Polarität, das das Ziel ersetzt |
| `confirm_actual` | Bestätigt die faktische Genauigkeit des Atoms |
| `confirm_necessary` | Bestätigt, dass das Atom weiterhin relevant ist |
| `demote` | Stuft den epistemischen Status herab (z.B. confirmed → deprecated) |
| `replace` | Erstellt ein neues Atom mit aktualisiertem Inhalt, ersetzt das alte |

![Agent ruft memory_correct (replace) auf](../img/agent-correct.png)

## Governance-Fluss

Governance-Übergänge schützen sensible oder veraltete Erinnerungen:

```text
normal → quarantined (unter Überprüfung)
quarantined → sealed (gesperrt, unveränderlich)
quarantined → tombstoned (vom Abruf entfernt)
quarantined → normal (freigestellt, wiederhergestellt)
beliebig → derive_lesson (Payload durch sichere Zusammenfassung ersetzen)
```

### Governance-Aktionen

| Aktion | Von → Nach | Anwendungsfall |
|---|---|---|
| `quarantine` | normal → quarantined | Verdächtig sensibler Inhalt |
| `seal` | quarantined → sealed | Juristischer Halter, Compliance |
| `tombstone` | quarantined → tombstoned | Vom Abruf löschen |
| `derive_lesson` | beliebig → lesson | Sichere Lektion extrahieren, sensible Payload entfernen |

![Agent ruft memory_govern (quarantine) auf](../img/agent-govern.png)

## Snapshot-Historie

Jede Korrektur- und Governance-Aktion erstellt einen unveränderlichen Snapshot.
Snapshots bewahren den Zustand des Atoms zum Zeitpunkt des Übergangs.

Das Werkzeug `memory_history` gibt die vollständige Kette zurück:

```text
Atom erstellt (v1)
  → Korrigiert: negate (v2, Supersedes v1)
    → Governed: tombstone (v2 vom normalen Abruf verborgen)
      → Lektion abgeleitet (v3, sichere Zusammenfassung im Abruf sichtbar)
```

## Abrufansichten

HMG unterstützt drei Abrufansichten mit unterschiedlichen Sichtbarkeitsregeln:

| Ansicht | Zeigt | Anwendungsfall |
|---|---|---|
| `normal` | Nur aktive Atome (positive Polarität, normaler Offenlegung) | Tägliche Agent-Nutzung |
| `governance` | + Isolierte/versiegelte Atome | Compliance-Überprüfung |
| `audit` | + Alle Atome inklusive tombstonierte, vollständige Korrekturkette | Forensische Untersuchung |

Der normale Abruf schließt absichtlich governante Payloads aus. Der Audit-Abruf zeigt alles für Rechenschaftspflicht.
