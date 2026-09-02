# Changelog

## Unreleased

### Hinzugefügt
 
- Optionale Installation von Grafana Loki als Docker-Container
- Interaktive Abfrage, ob Loki installiert werden soll
- Auswahl einer bestimmten Loki-Version
- Automatische Ermittlung der neuesten stabilen Loki-Version über die GitHub-API, wenn keine Version angegeben wird
- Unterstützung von Loki-Versionsangaben mit und ohne vorangestelltes `v`
- Automatischer Download der offiziellen Loki-Konfiguration passend zur ausgewählten Loki-Version
- Ablage der Loki-Konfiguration unter `~/loki/loki-config.yaml`
- Sicherung einer vorhandenen Loki-Konfiguration mit Zeitstempel
- Optionale Bearbeitung der heruntergeladenen Loki-Konfiguration im Texteditor
- Validierung der Loki-Konfiguration mit der ausgewählten Loki-Version vor dem Erstellen des Containers
- Persistentes Docker-Volume `loki-data`
- Bereitstellung von Loki auf Port `3100`
- Automatische Prüfung des Loki-Readiness-Endpunkts
- Ausgabe der Loki-Adresse und der Push-URL für eine externe Grafana-Alloy-Installation
- Abfrage zum optionalen Neuerstellen eines vorhandenen Loki-Containers
- Anzeige des Docker-Images eines vorhandenen Loki-Containers
- Dokumentation zur Einbindung von Loki als Grafana-Datenquelle
- Dokumentation zur Übertragung von Logdateien mit Grafana Alloy
- Beispielkonfiguration für eine externe Grafana-Alloy-Installation
- Beispielabfragen für Loki mit LogQL
- Loki- und Alloy-spezifische Hinweise zur Fehlerbehebung
 
### Geändert
 
- Installationsskript um die optionale Loki-Installation erweitert
- Installationsanleitung um Grafana Loki ergänzt
- Beschreibung der verwendeten Ports um Port `3100` ergänzt
- Beschreibung der persistenten Docker-Volumes um `loki-data` ergänzt
- Beschreibung von `TARGET_ROOT` um die Loki-Konfiguration ergänzt
- Abschlussausgabe des Installationsskripts um Loki- und Alloy-Adressen erweitert
- Portprüfung in der Dokumentation um Port `3100` ergänzt
- Sicherheitshinweise um Empfehlungen zur Absicherung von Loki erweitert
- HTML-Artefakte aus URLs und Codebeispielen in der Dokumentation entfernt
- Git-Installation in der Dokumentation auf das benötigte Paket `git` vereinfacht
 
### Behoben
 
- Docker-Image und Konfigurationsdatei von Loki verwenden immer dieselbe Version
- Ungültige Loki-Konfigurationen werden vor dem Erstellen des Containers erkannt
- Ein vorhandener Loki-Container wird erst nach erfolgreicher Validierung der neuen Konfiguration entfernt
- Loki wird erst als erfolgreich gestartet betrachtet, wenn der Readiness-Endpunkt `ready` zurückgibt
- Temporäre oder leere Loki-Konfigurationsdateien werden erkannt
- Ungültige manuell eingegebene Loki-Versionsnummern werden abgewiesen
- Bereits vorhandene Loki-Daten bleiben beim Neuerstellen des Containers im Volume `loki-data` erhalten
 
### Sicherheit
 
- Loki-Konfiguration wird schreibgeschützt in den Container eingebunden
- Loki-Konfiguration wird vor dem Erstellen oder Ersetzen des Containers validiert
- Hinweis ergänzt, dass Loki in der verwendeten Konfiguration keine integrierte Authentifizierung bereitstellt
- Empfehlung ergänzt, Port `3100` ausschließlich aus vertrauenswürdigen Netzen erreichbar zu machen
- Empfehlung ergänzt, externen Zugriff über Firewall-Regeln oder einen authentifizierenden Reverse Proxy abzusichern
- Persistentes Loki-Volume wird in die empfohlene Sicherungsstrategie aufgenommen
 
### Geplant
 
- Vollständiger Funktionstest der optionalen Loki-Installation auf einem neu eingerichteten System
- Optionaler Einsatz eines Proxmox-API-Tokens
- Automatische Prüfung der PVE- und Prometheus-YAML-Konfigurationen
- Prüfung, ob die benötigten Ports bereits belegt sind
- Optionaler Aktualisierungsmodus für bestehende Container
- Erweiterte Statusprüfung nach der Installation
- Optionale automatische Einrichtung von Loki als Grafana-Datenquelle
- Optional konfigurierbare Aufbewahrungsdauer für Loki-Logdaten

## [1.0.0] - 2026-08-29

### Hinzugefügt
 
- Erste stabile Version der Monitoring-Umgebung
- Automatische Installation und Einrichtung des Prometheus-PVE-Exporters
- Automatische Installation und Einrichtung von Prometheus
- Automatische Installation und Einrichtung von Grafana Enterprise
- Interaktive Bearbeitung der Konfigurationsdateien vor dem Start der zugehörigen Container
- Automatische Ermittlung der Docker-Host-IP für Platzhalter in den Konfigurationsdateien
- Unterstützung der Umgebungsvariable `EDITOR`
- Automatische Auswahl von `nano` oder `vi`, falls `EDITOR` nicht gesetzt ist
- Unterstützung eines alternativen Zielverzeichnisses über `TARGET_ROOT`
- Sicherung vorhandener Konfigurationsdateien mit Zeitstempel
- Prüfung auf bereits vorhandene Docker-Container
- Persistente Docker-Volumes für Prometheus und Grafana
- Neustartrichtlinie `unless-stopped` für alle Docker-Container
- Ausführliche Installations-, Konfigurations- und Fehlerbehebungsanleitung
 
### Geändert
 
- Installationsablauf für den stabilen Einsatz überarbeitet
- PVE-Konfiguration wird vor dem Start des Prometheus-PVE-Exporters zur Bearbeitung geöffnet
- Prometheus-Konfiguration wird vor dem Start von Prometheus zur Bearbeitung geöffnet
- Benutzerabhängige Zielpfade ersetzen fest codierte Verzeichnisse
- Docker-Befehle wurden für bessere Lesbarkeit und Wartbarkeit strukturiert
- Status und erreichbare Dienstadressen werden nach der Installation ausgegeben
 
### Behoben
 
- Fehlerhafte Zeilenumbrüche und Fortsetzungszeichen in Docker-Befehlen
- Fehlerhafte Volume-Definition für Grafana
- Unvollständige Verzeichniswechsel im Installationsablauf
- Fehler durch fest eingetragene Benutzernamen in Volume-Pfaden
- Falsche oder fehlende Pfade beim Einbinden der Konfigurationsdateien
 
### Sicherheit
 
- PVE- und Prometheus-Konfigurationen werden schreibgeschützt in die Container eingebunden
- Empfehlung zur Verwendung eines separaten Proxmox-Monitoring-Benutzers oder API-Tokens
- Hinweis, keine echten Zugangsdaten im Repository zu speichern
- Hinweis zur Änderung des Grafana-Standardpassworts nach der ersten Anmeldung
- Hinweise zur Absicherung der Monitoring-Weboberflächen

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
