# Upgrade-Leitfaden

## HMG aktualisieren

### Von v0.9.x
```bash
curl -fsSL https://github.com/HMG-AI/HMG-public/releases/latest/download/install.sh | sh
hmg daemon restart
hmg --version
```

### Von v0.8.x
v0.9.x enthält Speicherformatänderungen. Automatische Migration beim ersten Start. Backup empfohlen:
```bash
cp -r ~/.local/share/hmg ~/.local/share/hmg.bak-v0.8
```

## Edition wechseln

### Community → Developer
```bash
hmg license apply hmg-dev-xxxxx
hmg daemon restart
```
Sofort freigeschaltet: Unbegrenzte Atome, semantische Suche, One-Shot Recall, Domain Packs.

### Developer → Enterprise
```bash
hmg license apply hmg-ent-xxxxx
hmg daemon restart
```
Sofort freigeschaltet: SSO, RBAC, Multi-Tenant, Audit-Export.

### Enterprise → Community
```bash
hmg license remove
hmg daemon restart
```
Daten bleiben erhalten, über dem Limit liegende Atome werden schreibgeschützt.

## Datenkompatibilität

| Von → Nach | Migration |
|---|---|
| Community → Developer | Keine |
| Community → Enterprise | Keine |
| Developer → Enterprise | Keine |
| v0.8 → v0.9 | Automatisch (erster Start) |

Siehe [CHANGELOG.md](https://github.com/HMG-AI/HMG-public/blob/main/CHANGELOG.md) für das vollständige Änderungsprotokoll.
