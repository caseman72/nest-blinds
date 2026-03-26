#!/bin/bash
# Build script for chamber-remote
#
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${1:-chamber-remote.yaml}"
SECRETS="${2:-secrets.h}"

if [[ ! -f "$SCRIPT_DIR/$SECRETS" ]]; then
    echo "Error: ${SECRETS} not found. Copy secrets.example.h to ${SECRETS} and fill in values."
    exit 1
fi

# Parse secrets.h and extract value (no escaping needed - quotes protect from shell)
parse_secret() {
    grep "#define $1 " "$SCRIPT_DIR/$SECRETS" | sed 's/.*"\(.*\)"/\1/'
}

WIFI_SSID=$(parse_secret WIFI_SSID)
WIFI_PASSWORD=$(parse_secret WIFI_PASSWORD)
MQTT_BROKER=$(parse_secret MQTT_BROKER)
MQTT_USERNAME=$(parse_secret MQTT_USERNAME)
MQTT_PASSWORD=$(parse_secret MQTT_PASSWORD)
OTA_PASSWORD=$(parse_secret OTA_PASSWORD)

echo "Building chamber-remote..."
cd "$SCRIPT_DIR"

esphome \
    -l ERROR \
    -s wifi_ssid "$WIFI_SSID" \
    -s wifi_password "$WIFI_PASSWORD" \
    -s mqtt_broker "$MQTT_BROKER" \
    -s mqtt_username "$MQTT_USERNAME" \
    -s mqtt_password "$MQTT_PASSWORD" \
    -s ota_password "$OTA_PASSWORD" \
    compile "$CONFIG"
