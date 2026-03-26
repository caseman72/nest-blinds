# Nest Blinds

ESPHome-based blind controller using an AUNMAS dual relay module (ESP32-WROOM-32E) hidden inside a Nest Protect smoke alarm case.

## Hardware

**Board:** [AUNMAS Dual Channel Relay Module](https://www.amazon.com/dp/B0CDGP1LZT) (ESP32-WROOM-32E, 4MB flash, DC 5-60V)

Powered by the Nest Protect's 5V battery system (3x 1.5V AA). Relays are soldered to leads on a blind remote, simulating button presses to control 6 blinds.

### Pin Map

| Pin  | GPIO | Function     |
|------|------|--------------|
| DO1  | 16   | Blinds Up    |
| DO2  | 17   | Blinds Down  |
| LED  | 23   | Status LED   |

## Setup

1. Copy `secrets.example.h` to `secrets.h` and fill in your credentials
2. First flash via USB (requires external CP2102 adapter — no onboard USB):
   ```bash
   ./build.sh
   esptool --before no-reset --after hard-reset --baud 460800 \
     --port /dev/cu.usbserial-0001 --chip esp32 write-flash -z \
     --flash-size detect \
     0x1000 .esphome/build/nest-blinds/.pioenvs/nest-blinds/bootloader.bin \
     0x8000 .esphome/build/nest-blinds/.pioenvs/nest-blinds/partitions.bin \
     0x9000 .esphome/build/nest-blinds/.pioenvs/nest-blinds/ota_data_initial.bin \
     0x10000 .esphome/build/nest-blinds/.pioenvs/nest-blinds/firmware.bin
   ```
3. Subsequent updates via OTA:
   ```bash
   ./upload.sh nest-blinds.local
   ```

## Home Assistant

Auto-discovers via MQTT as a **cover** entity (`device_class: blind`) with:

- **Open** (up) and **Close** (down) actions
- 1.5s relay pulse to ensure all 6 blinds receive the signal
- No state tracking (someone can use the physical remote independently)

## MQTT Topics

| Topic | Description |
|-------|-------------|
| `nest-blinds/cover/blinds/state` | open / closed |
| `nest-blinds/cover/blinds/command` | OPEN / CLOSE |
| `nest-blinds/status` | online / offline |

## Quick Test

```bash
./blinds-down.sh
./blinds-up.sh
```
