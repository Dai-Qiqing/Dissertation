
# **PeriSense** 

## Social Comfort Wearable Device — ESP32 + MAX30102 + HC‑SR04

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-ESP32-red.svg)](https://www.espressif.com/)
[![Flutter](https://img.shields.io/badge/flutter-supported-blue.svg)](https://flutter.dev/)
[![MQTT](https://img.shields.io/badge/protocol-MQTT-orange.svg)](https://mqtt.org/)

> **An edge-aware, privacy-focused wrist-worn device that infers a user’s social comfort from distance and physiological signals.**

This repository documents a wrist-worn prototype built on ESP32 that combines ultrasonic distance sensing (HC‑SR04) and physiological monitoring (MAX30102). Telemetry is published via MQTT to a companion Flutter app or local display for real-time visualization and historical analysis.

---

## 🏗️ System Architecture (Overview)

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Wrist Device   │    │   MQTT Broker     │    │  Flutter App /   │
│  (ESP32 MCU)    │◄──►│  (local / cloud)  │◄──►│  Web/Display     │
│ • HC‑SR04        │    │                  │    │ • Dashboard      │
│ • MAX30102       │    │                  │    │ • Live & History │
│ • OLED (I2C)     │    │                  │    │ • Device Config  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

The device runs lightweight firmware responsible for sampling, simple filtering, state evaluation, and MQTT publishing. The companion app handles visualization, device management, threshold configuration and analytics.

---

## 🧩 Core Features

- **Distance Awareness (HC‑SR04)** — classify proximity into three levels: *comfortable*, *warn*, *danger*.
- **Physiological Monitoring (MAX30102)** — measure heart rate (BPM) and blood oxygen (SpO₂) (prototype logic — see notes).
- **Wireless Telemetry (MQTT)** — publish lightweight telemetry messages to an MQTT broker for real-time monitoring.
- **Local Feedback (OLED I²C)** — simple text-based prompts on an OLED screen to minimize rendering overhead and improve reliability.
- **Companion App (Flutter)** — real-time dashboard, live interaction view, history & analytics, and device settings.

---

## 🧰 Hardware Bill of Materials

- **ESP32 dev board** (standard ESP32)
- **MAX30102** (heart rate & SpO₂ sensor)
- **HC‑SR04** (ultrasonic distance sensor)
- **0.96" OLED (I²C)** — SSD1306, driven with U8g2
- Power supply: 3.3V regulator or Li‑ion battery + charging circuit
- Jumper wires, connectors, wrist strap / enclosure materials

---

## 🔌 Wiring (Matches the firmware)

> The wiring below matches the provided firmware. The code calls `Wire.begin(5, 4)` and constructs `U8G2_SSD1306_128X64_NONAME_F_HW_I2C` — both MAX30102 and the OLED share the same I²C pins (SDA=GPIO5, SCL=GPIO4).

### MAX30102 (I²C)
```
GPIO5  -> SDA
GPIO4  -> SCL
3V3    -> VCC
GND    -> GND
```

### 0.96" OLED (I²C)
```
VCC  -> 3V3
GND  -> GND
SDA  -> GPIO5
SCL  -> GPIO4
```

### HC‑SR04 (Ultrasonic)
```
VCC    -> 3V3
GND    -> GND
Trig   -> GPIO2
Echo   -> GPIO3
```

### EMG / ECG (Analog)
```
ECG module -> Analog pin A0 (ecgPin = 0)
```

> ⚠️ Important: Using OLED and MAX30102 on the same I²C bus may cause address conflicts or initialization-order issues. Earlier iterations switched the display to SPI to avoid this. See the Alternatives & Fixes section if you encounter problems.

---

## 📦 Firmware (ESP32) — Implementation Details

The firmware (located in `/firmware/`) uses these components and behaviors:

- Libraries: `Wire`, `U8g2lib` (OLED), `MAX30105` (MAX3010x family), `WiFi`, `Ticker`, `PubSubClient` (MQTT), `ArduinoJson`.
- OLED initialization: `U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(..., clock=4, data=5);` and `Wire.begin(5,4);` in `setup()`.
- MAX30102: `particleSensor.begin()` and `particleSensor.setup()` called in `setup()`; `readHeartRate()` also calls `particleSensor.begin()` (redundant — see improvements).
- Ultrasonic: `trigPin = 2`, `echoPin = 3`, distance computed using `pulseIn` and converted to cm.
- ECG (analog): `ecgPin = 0`, `analogReadResolution(12)`, voltage calculated as `ecgValue * (3.3 / 4095.0)`.
- WiFi and MQTT: WiFi credentials are configured in code (recommend moving to `arduino_secrets.h`); MQTT uses credentials from `arduino_secrets.h` and connects to `mqtt_server:mqtt_port`.
- MQTT topic: the firmware publishes to `student/HD_top` with a small JSON payload.
- Publish cadence: a `Ticker` increments a `count` every 1 second; when `count >= 1` the loop calls `pubMQTTmsg()` and resets `count` — roughly once per second.
- OLED update is throttled to `SCREEN_UPDATE_INTERVAL = 200 ms`.

### Telemetry payload (current firmware)

The firmware currently publishes the following JSON (distance and heart rate only):

```json
{
  "distance": 75,
  "heartRate": 82
}
```

To include additional fields (spo2, ecg, timestamp), expand the `StaticJsonDocument` size in `pubMQTTmsg()` and add the fields.

---

## 📚 Dependencies & Installation

Install the following libraries via Arduino IDE Library Manager or PlatformIO `lib_deps`:

- **U8g2** (`U8g2lib`) — OLED driver
- **SparkFun MAX3010x Particle Sensor Library** (`MAX30105.h`) — or a compatible MAX30102 library
- **PubSubClient** — MQTT client
- **ArduinoJson** — for JSON serialization (v6 style used)
- **Ticker** — periodic callbacks
- `Wire` and `WiFi` (included in the ESP32 core)

**PlatformIO `lib_deps` example:**

```ini
lib_deps =
  olikraus/U8g2@^2.27.11
  sparkfun/SparkFun MAX3010x Particle Sensor@^1.2.0
  knolleary/PubSubClient@^2.8
  bblanchon/ArduinoJson@^6.23.0
  paulstoffregen/Ticker@^1.1.0
```

---

## 🔧 arduino_secrets.h (template)

Create `/firmware/include/arduino_secrets.h` (git‑ignored) with these entries used by the firmware:

```cpp
// arduino_secrets.h
#define SECRET_MQTTUSER "your_mqtt_user"
#define SECRET_MQTTPASS "your_mqtt_password"
#define SECRET_MQTTSERVER "192.168.1.100"
#define SECRET_MQTTPORT 1883
```

> Do **not** commit real credentials to the repository. Use `.gitignore` to exclude this file.

---

## 🚀 Build & Upload (PlatformIO)

1. Open the `firmware` folder in VS Code with PlatformIO.
2. Edit `src/config.h` or `include/arduino_secrets.h` to set WiFi & MQTT credentials.
3. Run `PlatformIO: Build` then `PlatformIO: Upload` to flash the ESP32.

**Arduino IDE notes:**
- Install the listed libraries via Library Manager
- Select the correct ESP32 board and COM port
- Upload `main.cpp` (or the project sketch)

---

## ⚠️ Runtime Notes & Troubleshooting

- **I²C conflict**: If MAX30102 and OLED do not coexist, switch OLED to SPI or change device addresses. To use SPI with U8g2, replace the constructor with an SPI variant and remap pins.
- **Heart rate logic**: Current `readHeartRate()` uses `particleSensor.getIR()` and returns a randomized `heartRate` when IR is high. Replace with a proper beat detection algorithm for production use.
- **MQTT diagnostics**: `connectMQTTServer()` prints detailed `mqttClient.state()` diagnostics (e.g., -4 timeout, 4 auth error). Use these messages to troubleshoot broker connectivity and credentials.
- **Power & safety**: Do not connect 9V modules directly to ESP32; validate module voltage ranges and use proper level shifting or isolation.

---

## 🔭 Improvements & Recommendations

- Move OLED to SPI if you encounter I²C address issues.
- Implement proper MAX30102 beat detection instead of random values.
- Add timestamps, SpO₂, and ECG fields to telemetry and increase JSON buffer accordingly.
- Add reconnection/backoff logic for MQTT and WiFi.
- Reduce publish frequency to save bandwidth and power, or implement event-based reporting.

---

## 🤝 Contributing

Contributions are welcome! Please submit PRs or Issues. Keep secrets out of commits.

---

## License
MIT License — see the LICENSE file for details.

---

If you want, I can now:

- generate `platformio.ini` and an example `config.h` (with `.gitignore`),
- provide the exact wiring & U8g2 constructor to switch the OLED to SPI, or
- produce an improved `readHeartRate()` example (basic beat detection + filtering) in C++.

