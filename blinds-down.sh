#!/bin/bash
# Press blinds down button via MQTT
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SECRETS="$SCRIPT_DIR/secrets.h"

parse_secret() { grep "#define $1 " "$SECRETS" | sed 's/.*"\(.*\)"/\1/'; }

mosquitto_pub \
    -h "$(parse_secret MQTT_BROKER)" \
    -p 8883 \
    -u "$(parse_secret MQTT_USERNAME)" \
    -P "$(parse_secret MQTT_PASSWORD)" \
    --cafile /etc/ssl/cert.pem \
    -t 'nest-blinds/button/blinds_down/command' \
    -m 'PRESS'
