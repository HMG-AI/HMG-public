# FAQ

## Allgemein

### Was ist HMG?
HMG (Holographic Memory Graph) ist ein persistentes Speichersystem für KI-Agenten. Es bietet strukturierte Speicherung, intelligenten Abruf, Korrekturverfolgung und Governance-Fähigkeiten — als lokaler Dienst über das MCP-Protokoll.

### Warum brauchen KI-Agenten persistenten Speicher?
Agenten ohne Speicher vergessen alles in jeder Sitzung. Sie wiederholen Fehler, vergessen Architekturentscheidungen und können keine projektübergreifende Konsistenz wahren. HMG gibt Agenten einen persistenten „Arbeitsspeicher".

### Ist HMG sicher?
Ja. Community Edition: Keine ausgehenden Netzwerkverbindungen, an localhost gebunden, Benutzer-only-Dateiberechtigungen, keine Telemetrie.

### Welche Plattformen werden unterstützt?
Linux (x86_64, ARM64), macOS (Intel, Apple Silicon), Windows (via WSL).

## Installation

### Wie installieren?
```bash
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
```

### Agent verbinden?
```bash
hmg init --agent cursor    # Cursor
hmg init --agent codex     # Claude Code / Codex
hmg init --agent pi        # Pi
```

## Nutzung

### Wie ist der Speicher organisiert?
Als **Atome** — strukturierte Informationseinheiten mit Typ, Scope und Metadaten, verbunden durch Graphkanten.

### Wie funktioniert Korrektur?
HMG überschreibt nie. Korrekturen erstellen neue Atome mit `Supersedes`-Kanten. Siehe [Korrektur und Governance](correction-governance.md).

### Was ist Governance?
Schutz sensibler Erinnerungen: Quarantäne, Versiegelung, Tombstone, Lektion ableiten.

## Editionen

| Funktion | Community | Developer | Enterprise |
|---|---|---|---|
| Speichern & Abrufen | ✅ | ✅ | ✅ |
| Korrektur & Governance | ✅ | ✅ | ✅ |
| Atomanzahl | 50.000 | Unbegrenzt | Unbegrenzt |
| Semantische Suche | ❌ | ✅ | ✅ |
| One-Shot Recall | ✅ | ✅ | ✅ |
| SSO / RBAC | ❌ | ❌ | ✅ |
| Preis | Kostenlos | Abo | Kontakt |

### Upgrade zu Developer?
```bash
hmg license apply <your-key>
hmg daemon restart
```

## Fehlerbehebung

- Agent findet HMG nicht: `hmg doctor` ausführen
- Daemon startet nicht: Port prüfen (`lsof -i :3000`)
- Falsche Ergebnisse: Scope-Felder prüfen, `debug`-Profil verwenden
