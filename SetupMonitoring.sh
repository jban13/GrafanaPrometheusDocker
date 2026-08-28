#!/usr/bin/env bash
set -Eeuo pipefail

# Repository structure:
#   SetupMonitoring.sh
#   pve/pve.yml
#   prometheus/prometheus.yml
#
# The configuration files are copied from the repository to:
#   ~/pve/pve.yml
#   ~/prometheus/prometheus.yml
# They are then opened for editing before the relevant Docker container starts.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ROOT="${TARGET_ROOT:-$HOME}"

PVE_SOURCE="${SCRIPT_DIR}/pve/pve.yml"
PVE_DIR="${TARGET_ROOT}/pve"
PVE_CONFIG="${PVE_DIR}/pve.yml"

PROMETHEUS_SOURCE="${SCRIPT_DIR}/prometheus/prometheus.yml"
PROMETHEUS_DIR="${TARGET_ROOT}/prometheus"
PROMETHEUS_CONFIG="${PROMETHEUS_DIR}/prometheus.yml"

log() {
    printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"
}

fail() {
    printf '\nFEHLER: %s\n' "$*" >&2
    exit 1
}

select_editor() {
    if [[ -n "${EDITOR:-}" ]]; then
        read -r -a EDITOR_CMD <<< "$EDITOR"
    elif command -v nano >/dev/null 2>&1; then
        EDITOR_CMD=(nano)
    elif command -v vi >/dev/null 2>&1; then
        EDITOR_CMD=(vi)
    else
        fail "Kein Editor gefunden. Bitte nano installieren oder EDITOR setzen."
    fi
}

copy_and_edit() {
    local source_file="$1"
    local target_file="$2"
    local target_dir
    target_dir="$(dirname -- "$target_file")"

    HOST_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}')

    sed -i
        "s/DOCKER_HOST_IP/${HOST_IP}/g"
        "$PROMETHEUS_CONFIG"
    
    [[ -f "$source_file" ]] || fail "Quelldatei fehlt: $source_file"
    mkdir -p -- "$target_dir"

    # Falls Quelle und Ziel identisch sind, ist kein Kopieren erforderlich.
    if [[ "$(readlink -f -- "$source_file")" != "$(readlink -m -- "$target_file")" ]]; then
        if [[ -f "$target_file" ]]; then
            cp -- "$target_file" "${target_file}.bak.$(date '+%Y%m%d-%H%M%S')"
        fi
        cp -- "$source_file" "$target_file"
        log "Konfiguration kopiert nach $target_file"
    else
        log "Konfiguration liegt bereits am Ziel: $target_file"
    fi

    log "Oeffne $target_file zur Bearbeitung"
    "${EDITOR_CMD[@]}" "$target_file"
}

container_exists() {
    docker container inspect "$1" >/dev/null 2>&1
}

select_editor

log "Paketlisten aktualisieren und Docker installieren"
apt-get update
apt-get install -y docker.io curl
systemctl enable --now docker

# pve.yml vor dem docker pull kopieren und bearbeiten.
copy_and_edit "$PVE_SOURCE" "$PVE_CONFIG"

log "Prometheus-PVE-Exporter installieren"
docker pull prompve/prometheus-pve-exporter

if container_exists prometheus-pve-exporter; then
    log "Container prometheus-pve-exporter existiert bereits und wird beibehalten."
else
    docker run --init \
        --name prometheus-pve-exporter \
        --restart unless-stopped \
        -d \
        -p 0.0.0.0:9221:9221 \
        -v "${PVE_CONFIG}:/etc/prometheus/pve.yml:ro" \
        prompve/prometheus-pve-exporter
fi

docker ps
curl --fail --show-error http://localhost:9221/ || true

# prometheus.yml direkt vor der Prometheus-Installation kopieren und bearbeiten.
copy_and_edit "$PROMETHEUS_SOURCE" "$PROMETHEUS_CONFIG"

log "Prometheus installieren"
docker volume create prometheus-data >/dev/null
docker pull prom/prometheus

if container_exists prometheus; then
    log "Container prometheus existiert bereits und wird beibehalten."
else
    docker run \
        --name prometheus \
        --restart unless-stopped \
        -p 9090:9090 \
        -d \
        -v "${PROMETHEUS_CONFIG}:/etc/prometheus/prometheus.yml:ro" \
        -v prometheus-data:/prometheus \
        prom/prometheus
fi

log "Grafana installieren"
docker volume create grafana-storage >/dev/null
docker pull grafana/grafana-enterprise

if container_exists grafana; then
    log "Container grafana existiert bereits und wird beibehalten."
else
    docker run \
        --name grafana \
        --restart unless-stopped \
        -d \
        -p 3000:3000 \
        --volume grafana-storage:/var/lib/grafana \
        grafana/grafana-enterprise
fi

log "Installation abgeschlossen"
docker ps --filter name=prometheus-pve-exporter \
               --filter name=prometheus \
               --filter name=grafana

printf '\nPVE-Exporter: http://localhost:9221\n'
printf 'Prometheus:   http://localhost:9090\n'
printf 'Grafana:      http://localhost:3000\n'
