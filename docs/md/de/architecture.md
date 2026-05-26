# HMG Architektur

Dieses Dokument bietet einen hochrangigen Überblick über die Funktionsweise von HMG auf konzeptioneller Ebene.

## Visuelle Tour — TUI

HMG verfügt über eine integrierte Terminal-UI (TUI) zum Durchsuchen, Suchen und Verwalten Ihres Speichers.

```bash
hmg tui
```

![HMG TUI — Dashboard](../img/tui-dashboard.png)

### Doctor-Bildschirm

![HMG TUI — Doctor](../img/tui-doctor.png)

### Recall-Bildschirm

![HMG TUI — Recall](../img/tui-recall.png)

### Timeline-Bildschirm

![HMG TUI — Timeline](../img/tui-timeline.png)

### Integrations-Bildschirm

![HMG TUI — Integrations](../img/tui-integrations.png)

### Store-Bildschirm

![HMG TUI — Store](../img/tui-daemon_store.png)

### Settings-Bildschirm

![HMG TUI — Settings](../img/tui-settings.png)

## Systemübersicht

```
┌──────────────────────────────────────────────────────────┐
│                    AI Agent / IDE                         │
│  (Cursor, Claude Code, pi, Codex, Windsurf, ...)         │
└────────────┬─────────────────────────────┬───────────────┘
             │ MCP                          │ HTTP / SDK
             ▼                              ▼
┌──────────────────────────────────────────────────────────┐
│                    HMG-Binärdatei                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐               │
│  │   MCP    │  │   HTTP   │  │   CLI    │               │
│  │ Handlers │  │    API   │  │  (hmg)   │               │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘               │
│       └─────────────┼─────────────┘                       │
│                     ▼                                     │
│  ┌──────────────────────────────────────────┐            │
│  │         Speicher-Engine                   │            │
│  │  Graph │ Index │ Speicher                  │            │
│  └──────────────────────────────────────────┘            │
│                     │                                     │
│           Lokales Dateisystem (~/.local/share/hmg/)       │
└──────────────────────────────────────────────────────────┘
```

## Komponenten

### Schnittstellen

| Schnittstelle | Protokoll | Anwendungsfall |
|---|---|---|
| **MCP** | Model Context Protocol | Agent-Integration (primär) |
| **HTTP API** | REST + JSON | SDK-Integration, benutzerdefinierte Tools |
| **CLI** | Terminal (`hmg` Befehl) | Verwaltung, Debugging, Skripte |
| **TUI** | Interaktives Terminal (`hmg tui`) | Visuelle Navigation und Verwaltung |

### Unterstützte Agenten

| Agent | Status |
|---|---|
| Cursor | ✅ Unterstützt |
| pi (Codex fork) | ✅ Unterstützt |
| Claude Code | ✅ Unterstützt |
| Codex | ✅ Unterstützt |
| Windsurf | ✅ Unterstützt |
| Aider | ✅ Unterstützt |
| Continue | ✅ Unterstützt |

## Datenfluss

### Speichern

```
Agent → "Merke dir das: ..." → HMG
  → Eingabe validieren → Typisiertes Atom erstellen → Scope anhängen
  → Indizieren → Persistieren → Atom-ID + Bestätigung zurückgeben
```

![Agent ruft memory_memorize auf](../img/agent-memorize.png)

### Abrufen

```
Agent → "Welche Datenbank haben wir gewählt?" → HMG
  → Abfrageintention analysieren → Kandidaten abrufen → Rangieren
  → Nach Scope filtern → Verwandte Atome projizieren → Formatieren → Zurückgeben
```

![Agent ruft memory_recall auf](../img/agent-recall.png)

## Speicherung

```
~/.local/share/hmg/stores/default/
  graph/           ← Atom- und Kantendaten
  indexes/         ← Suchindizes
  snapshots/       ← Korrektur/Governance-Historie
```

Keine Daten verlassen die Maschine in Community und Developer Local.

## Editionsarchitektur

HMG ist eine einzelne Binärdatei. Die aktive Edition wird beim Start bestimmt:

- Kein Lizenzschlüssel → Community (50K Atome, 5 Agenten)
- `HMG_LICENSE_KEY=hmg-dev-...` → Developer (unbegrenzt, One-Shot Recall)
- `HMG_LICENSE_KEY=hmg-ent-...` → Enterprise (SSO, RBAC, Multi-Tenant)

Upgrade ist sofort: `export HMG_LICENSE_KEY=...` und Neustart.

## Sicherheitsgrenzen

- Community Edition: **Keine ausgehenden Netzwerkverbindungen**
- Standardmäßig an `localhost` gebunden
- Speicherdateien mit Benutzer-only-Berechtigungen

## Nächste Schritte

- [Konzepte](concepts.md)
- [API-Referenz](api-reference.md)
- [Sicherheit](security.md)
