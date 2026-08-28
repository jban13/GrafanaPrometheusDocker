# Proxmox-Monitoring mit Prometheus und Grafana

Dieses Repository richtet eine Monitoring-Umgebung fuer Proxmox VE mit Docker ein. Dabei werden der Prometheus-PVE-Exporter, Prometheus und Grafana installiert und als Docker-Container gestartet.

Die Konfigurationsdateien bleiben zur besseren Uebersicht in eigenen Verzeichnissen im Repository. Das Installationsskript kopiert sie in das Home-Verzeichnis des ausfuehrenden Benutzers und oeffnet die jeweiligen Kopien vor der zugehoerigen Installation zur Bearbeitung.

## Repository-Struktur

```text
PVE-GrafanaDocker/
├── prometheus/
│   └── prometheus.yml
├── pve/
│   └── pve.yml
├── .gitattributes
├── CHANGELOG.md
├── LICENSE
├── README.md
└── SetupMonitoring.sh
```

## Voraussetzungen

- Ein Linux-System auf Basis von Debian oder Ubuntu
- Ein Benutzerkonto mit `sudo`-Berechtigung
- Netzwerkzugriff auf den Proxmox-VE-Host
- Internetzugriff zum Installieren von Paketen und Herunterladen der Docker-Images
- Ein in Proxmox VE eingerichteter Monitoring-Benutzer oder API-Token mit den erforderlichen Leserechten
- Ein Texteditor wie `nano` oder `vi`

Docker und `curl` werden bei Bedarf durch das Skript installiert.

## Proxmox-Benutzer vorbereiten

Vor der Installation muss in Proxmox VE ein Benutzer oder API-Token fuer das Monitoring eingerichtet werden. Hier wird ein Benutzer verwendet.

Der verwendete Zugang sollte nur die fuer das Auslesen der Monitoring-Daten notwendigen Rechte erhalten. Anschliessend werden die Zugangsdaten in der kopierten `pve.yml` eingetragen.

## Installation

### 1. Repository klonen

```bash
git clone https://github.com/jban13/PVE-GrafanaDocker
cd PVE-GrafanaDocker
```

### 2. Installationsskript ausfuehrbar machen

```bash
chmod +x SetupMonitoring.sh
```

### 3. Installationsskript starten

```bash
./SetupMonitoring.sh
```

Das Skript fuehrt die folgenden Schritte in dieser Reihenfolge aus.

## Ablauf des Installationsskripts

### 1. Docker und curl installieren

Das Skript aktualisiert zuerst die Paketlisten und installiert Docker sowie `curl`:

```bash
sudo apt-get update
sudo apt-get install -y docker.io curl
sudo systemctl enable --now docker
```

### 2. PVE-Konfiguration kopieren und bearbeiten

Die Vorlage aus dem Repository:

```text
pve/pve.yml
```

wird nach folgendem Ziel kopiert:

```text
~/pve/pve.yml
```

Direkt nach dem Kopieren wird die Zieldatei im ausgewaehlten Texteditor geoeffnet. Dort muessen insbesondere die Proxmox-Zugangsdaten und die TLS-Einstellung kontrolliert und angepasst werden.

Beispiel:

```yaml
default:
  user: monitoring@pve
  password: CHANGE_ME
  verify_ssl: false
```

Nach dem Speichern und Schliessen des Editors wird die Installation automatisch fortgesetzt. Erst danach laedt das Skript das Image fuer den Prometheus-PVE-Exporter herunter und startet den Container.

### 3. PVE-Exporter installieren

Der PVE-Exporter wird auf Port `9221` bereitgestellt. Die zuvor bearbeitete Konfigurationsdatei wird schreibgeschuetzt in den Container eingebunden:

```text
~/pve/pve.yml -> /etc/prometheus/pve.yml
```

Der lokale Endpunkt ist anschliessend unter folgender Adresse erreichbar:

```text
http://localhost:9221
```

Ein beispielhafter Aufruf fuer einen Proxmox-Host lautet:

```text
http://DOCKER-HOST:9221/pve?target=PROXMOX-IP
```

Dabei sind `DOCKER-HOST` und `PROXMOX-IP` durch die tatsaechlichen IP-Adressen zu ersetzen.

### 4. Prometheus-Konfiguration kopieren und bearbeiten

Nach dem Start des PVE-Exporters wird die Prometheus-Vorlage aus dem Repository:

```text
prometheus/prometheus.yml
```

nach folgendem Ziel kopiert:

```text
~/prometheus/prometheus.yml
```

Die kopierte Datei wird ebenfalls automatisch im Texteditor geoeffnet. Vor dem Speichern muessen insbesondere folgende Werte kontrolliert werden:

- IP-Adresse oder Hostname des Proxmox-VE-Hosts
- IP-Adresse oder Hostname des Docker-Hosts
- Port des PVE-Exporters, standardmaessig `9221`
- Modul-, Cluster- und Node-Einstellungen

Die Adresse unter `replacement` muss auf den PVE-Exporter zeigen. In der Regel ist dies die IP-Adresse des Docker-Hosts mit Port `9221`, nicht `localhost`.

Beispiel:

```yaml
scrape_configs:
  - job_name: "pve"
    static_configs:
      - targets:
          - "192.168.2.10"
    metrics_path: /pve
    params:
      module: [default]
      cluster: ["1"]
      node: ["1"]
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: "192.168.2.11:9221"
```

Nach dem Speichern und Schliessen des Editors beginnt die Prometheus-Installation.

### 5. Prometheus installieren

Das Skript erstellt das persistente Docker-Volume `prometheus-data` und startet Prometheus auf Port `9090`.

Die bearbeitete Konfigurationsdatei wird schreibgeschuetzt eingebunden:

```text
~/prometheus/prometheus.yml -> /etc/prometheus/prometheus.yml
```

Prometheus ist anschliessend erreichbar unter:

```text
http://DOCKER-HOST:9090
```

### 6. Grafana installieren

Fuer Grafana wird das persistente Docker-Volume `grafana-storage` erstellt. Grafana wird anschliessend auf Port `3000` gestartet.

Grafana ist erreichbar unter:

```text
http://DOCKER-HOST:3000
```

Bei einer neuen Grafana-Installation lauten die standardmaessigen Anmeldedaten normalerweise:

```text
Benutzername: admin
Passwort:      admin
```

Beim ersten Anmelden kann Grafana zur Aenderung des Passworts auffordern.

## Editor auswaehlen

Das Skript verwendet den Editor in dieser Reihenfolge:

1. Editor aus der Umgebungsvariable `EDITOR`
2. `nano`
3. `vi`

Das Skript kann beispielsweise ausdruecklich mit `nano` gestartet werden:

```bash
EDITOR=nano ./SetupMonitoring.sh
```

Oder mit `vim`:

```bash
EDITOR=vim ./SetupMonitoring.sh
```

Das Installationsskript wartet jeweils, bis der Editor geschlossen wurde. Erst danach wird der naechste Schritt ausgefuehrt.

## Alternatives Zielverzeichnis

Standardmaessig werden die kopierten Konfigurationsdateien im Home-Verzeichnis des ausfuehrenden Benutzers abgelegt:

```text
~/pve/pve.yml
~/prometheus/prometheus.yml
```

Ueber die Umgebungsvariable `TARGET_ROOT` kann ein anderes Stammverzeichnis verwendet werden:

```bash
sudo mkdir -p /opt/monitoring
sudo chown "$USER:$USER" /opt/monitoring
TARGET_ROOT=/opt/monitoring ./SetupMonitoring.sh
```

Die Dateien werden dann hier abgelegt:

```text
/opt/monitoring/pve/pve.yml
/opt/monitoring/prometheus/prometheus.yml
```

## Sicherung vorhandener Konfigurationen

Wenn am Ziel bereits eine gleichnamige Konfigurationsdatei vorhanden ist, erstellt das Skript vor dem Kopieren eine Sicherung mit Zeitstempel.

Beispiele:

```text
pve.yml.bak.20260828-102000
prometheus.yml.bak.20260828-102100
```

Danach wird die aktuelle Vorlage aus dem Repository kopiert und zur Bearbeitung geoeffnet.

> **Hinweis:** Bei einer erneuten Ausfuehrung des Skripts wird die vorhandene Zieldatei gesichert, aber anschliessend wieder durch die Vorlage aus dem Repository ersetzt. Individuelle Einstellungen muessen daher erneut kontrolliert werden.

## Container und Ports

Nach erfolgreicher Installation laufen folgende Container:

- `prometheus-pve-exporter` auf Port `9221`
- `prometheus` auf Port `9090`
- `grafana` auf Port `3000`

Die Container verwenden die Neustart-Richtlinie `unless-stopped` und werden nach einem Neustart des Docker-Hosts normalerweise automatisch wieder gestartet.

Status pruefen:

```bash
sudo docker ps
```

Logs anzeigen:

```bash
sudo docker logs prometheus-pve-exporter
sudo docker logs prometheus
sudo docker logs grafana
```

## Vorhandene Container

Falls ein Container mit demselben Namen bereits existiert, ersetzt das Skript ihn nicht automatisch. Es zeigt stattdessen einen entsprechenden Hinweis an.

Vor einer vollstaendigen Neuinstallation koennen vorhandene Container manuell entfernt werden:

```bash
sudo docker rm -f prometheus-pve-exporter
sudo docker rm -f prometheus
sudo docker rm -f grafana
```

> **Achtung:** Das Entfernen eines Containers entfernt nicht automatisch die persistenten Docker-Volumes. Konfigurations- und Messdaten sollten trotzdem vor groesseren Aenderungen gesichert werden.

## Fehlerbehebung

### PVE-Exporter antwortet nicht

Containerstatus und Logs pruefen:

```bash
sudo docker ps -a --filter name=prometheus-pve-exporter
sudo docker logs prometheus-pve-exporter
```

Ausserdem pruefen:

- Sind Benutzername und Passwort beziehungsweise API-Token korrekt?
- Besitzt der Proxmox-Benutzer ausreichende Leserechte?
- Ist der Proxmox-Host vom Docker-Host erreichbar?
- Ist `verify_ssl` passend zur TLS-Konfiguration gesetzt?

### Prometheus erreicht den Exporter nicht

Pruefen, ob der Exporter vom Docker-Host erreichbar ist:

```bash
curl http://localhost:9221/
```

Danach in `~/prometheus/prometheus.yml` kontrollieren, ob `replacement` auf die korrekte Adresse verweist:

```yaml
replacement: "DOCKER-HOST-IP:9221"
```

Nach einer Konfigurationsaenderung muss Prometheus neu gestartet werden:

```bash
sudo docker restart prometheus
```

### Ports sind bereits belegt

Belegte Ports koennen beispielsweise so geprueft werden:

```bash
sudo ss -lntp | grep -E ':9221|:9090|:3000'
```

Wenn einer der Ports bereits verwendet wird, muss entweder der bestehende Dienst beendet oder die Portzuordnung im Installationsskript angepasst werden.

## Sicherheitshinweise

- Keine echten Zugangsdaten in `pve/pve.yml` im Repository speichern.
- Fuer Proxmox nach Moeglichkeit einen eigenen Monitoring-Benutzer oder API-Token mit minimal erforderlichen Rechten verwenden.
- Die Weboberflaechen nicht ungeschuetzt aus dem Internet erreichbar machen.
- Fuer produktive Systeme Firewall-Regeln, TLS und sichere Grafana-Zugangsdaten konfigurieren.
- Das Grafana-Standardpasswort unmittelbar nach der ersten Anmeldung aendern.

## Lizenz und Nutzung

Ergaenze diesen Abschnitt entsprechend der Lizenz deines GitHub-Repositories.
