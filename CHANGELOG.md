# Changelog

## Unreleased

### Geplant
- Erster Funktionstest
- Optionaler Einsatz eines Proxmox-API-Tokens
- Automatische Prüfung der YAML-Konfigurationen
- Prüfung, ob die benötigten Ports bereits belegt sind
- Optionaler Aktualisierungsmodus für bestehende Container
- Erweiterte Statusprüfung nach der Installation

## [0.0.1] - 2026-08-28

### Hinzugefügt

- Automatisches Kopieren der PVE-Konfiguration aus dem Repository
- Automatisches Kopieren der Prometheus-Konfiguration aus dem Repository
- Öffnen der kopierten Konfigurationsdateien in einem Texteditor
- Unterstützung der Umgebungsvariable `EDITOR`
- Automatische Auswahl von `nano` oder `vi`, falls `EDITOR` nicht gesetzt ist
- Unterstützung eines alternativen Zielverzeichnisses über `TARGET_ROOT`
- Sicherung bereits vorhandener Konfigurationsdateien mit Zeitstempel
- Prüfung, ob Docker-Container bereits vorhanden sind
- Neustartrichtlinie `unless-stopped` für alle Container
- Ausführliche Installations- und Konfigurationsanleitung in der `README.md`
- Hinweise zur Fehlerbehebung und Absicherung der Installation

### Geändert

- Die Dateien `pve.yml` und `prometheus.yml` bleiben als eigenständige Vorlagen im Repository erhalten
- `pve/pve.yml` wird vor dem Herunterladen und Starten des PVE-Exporters nach `~/pve/pve.yml` kopiert
- Die kopierte `pve.yml` wird vor dem Docker-Pull zur Bearbeitung geöffnet
- `prometheus/prometheus.yml` wird vor der Prometheus-Installation nach `~/prometheus/prometheus.yml` kopiert
- Die kopierte `prometheus.yml` wird vor dem Start des Prometheus-Containers zur Bearbeitung geöffnet
- Fest codierte Pfade wie `/home/user` wurden durch benutzerabhängige Pfade ersetzt
- Docker-Volumes werden für Prometheus und Grafana automatisch angelegt
- Die Docker-Befehle wurden für eine bessere Lesbarkeit auf mehrere Zeilen verteilt

### Behoben

- Fehlerhafte Zeilenumbrüche in den ursprünglichen `docker run`-Befehlen
- Fehlerhafte Escape-Zeichen beim Grafana-Volume
- Fehlende Fortsetzungszeichen in mehrzeiligen Shellbefehlen
- Unvollständige Verzeichniswechsel im ursprünglichen Installationsablauf
- Fehler durch einen fest eingetragenen Benutzernamen in den Volume-Pfaden

### Sicherheit

- Konfigurationsdateien werden schreibgeschützt in die Container eingebunden
- Dokumentation weist darauf hin, keine echten Zugangsdaten im Repository abzulegen
- Empfehlung zur Verwendung eines separaten Proxmox-Monitoring-Benutzers oder API-Tokens ergänzt
- Hinweis zur Änderung des Grafana-Standardpassworts ergänzt

## [0.0.0] - 2026-08-28

### Hinzugefügt

- Erstes Installationsskript für die Monitoring-Umgebung
- Installation von Docker über `apt-get`
- Installation des Prometheus-PVE-Exporters als Docker-Container
- Installation von Prometheus als Docker-Container
- Installation von Grafana Enterprise als Docker-Container
- Persistentes Docker-Volume für Prometheus
- Persistentes Docker-Volume für Grafana
- Bereitstellung der folgenden Dienste:
  - PVE-Exporter auf Port `9221`
  - Prometheus auf Port `9090`
  - Grafana auf Port `3000`
- Beispielkonfiguration für den Prometheus-PVE-Exporter
- Beispielkonfiguration für Prometheus
- Grundlegende Installationsanleitung
