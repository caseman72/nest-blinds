#!/bin/bash
# Upload script for nest-blinds
# First flash:  ./upload.sh /dev/cu.usbserial-0001
# OTA updates:  ./upload.sh nest-blinds.local
#
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEVICE="${1:-nest-blinds.local}"
CONFIG="${2:-nest-blinds.yaml}"
SECRETS="${3:-secrets.h}"

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

echo "Uploading to $DEVICE..."
cd "$SCRIPT_DIR"

esphome \
    -s wifi_ssid "$WIFI_SSID" \
    -s wifi_password "$WIFI_PASSWORD" \
    -s mqtt_broker "$MQTT_BROKER" \
    -s mqtt_username "$MQTT_USERNAME" \
    -s mqtt_password "$MQTT_PASSWORD" \
    -s ota_password "$OTA_PASSWORD" \
    run "$CONFIG" --no-logs --device "$DEVICE"
