# ADR-Veröffentlichungsklassifizierung

Gemäß ADR 2026-05-24 (v2) §Dokumentationsgrenze müssen alle ADRs vor der Veröffentlichung klassifiziert werden.

**Klassifizierungsdatum:** 2026-05-25

## Legende

| Markierung | Bedeutung |
|---|---|
| **Public** | Kann wie veröffentlicht werden |
| **Sanitize** | Nach Entfernung interner Details veröffentlichbar |
| **Private** | Muss im privaten Monorepo bleiben |

## Zusammenfassung

| Klassifizierung | Anzahl |
|---|---|
| **Public** | 2 (2026-05-20-local-store, 2026-05-24-agent-tool-output-contract-v2) |
| **Sanitize** | 6 |
| **Private** | 11 |

## Erforderliche Maßnahmen

1. 2 Public ADRs können sofort nach `export/docs/adr/` kopiert werden.
2. 6 Sanitize ADRs benötigen manuelle Überprüfung vor Veröffentlichung.
3. 11 Private ADRs bleiben auf unbestimmte Zeit im privaten Monorepo.
