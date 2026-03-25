# Vikrant: High-Performance Smart E-Bike Ecosystem
**Vikrant** is an award-winning IoT-powered electric vehicle control and monitoring system engineered for the **SIEP E-Bike Challenge**. As the **IoT & Innovation Head**, I spearheaded a 6-member cross-functional team to architect a secure, real-time telemetry and hardware access layer that replaces traditional e-bike frameworks with a smart, connected ecosystem.

## Advanced Engineering Features
### 1. Secure Hardware Access Layer
* **Multi-Factor Ignition:** Engineered a secure access layer using a **Raspberry Pi 4**, integrating a biometric fingerprint sensor and a matrix keypad to replace standard key-based ignitions.
* **Access Control:** Developed bare-metal logic to manage hardware-level authentication before the motor controller is engaged.
### 2. Custom IoT Suite & Telemetry
* **Real-Time Analytics:** Designed a secure GUI dashboard to monitor mission-critical data, including speed, battery health/percentage, and distance.
* **Cloud Synchronization:** Utilized **Firebase** and **MQTT** for low-latency data sync, ensuring the mobile app and physical bike stay updated in real-time.
* **Anti-Theft Intelligence:** Implemented GPS-based geo-fencing and remote vehicular control directly from a mobile application.
### 3. Safety & Innovation
* **Auto-Balancing Mechanism:** Conceptualized and integrated an automated balancing mechanism to enhance rider stability.
* **Communication Protocols:** Validated low-level **UART** and **I2C** interfaces between the central Raspberry Pi gateway, motor controllers, and distributed sensor nodes.
* **Emergency Response:** Integrated GPS and GSM modules to broadcast live location and SOS alerts in the event of critical system failures or crashes.

## Technical Stack

| Category | Tools & Technologies |
| :--- | :--- |
| **Microcontrollers** | Raspberry Pi 4 (Central Gateway), ESP32 (Edge Nodes), Arduino |
| **Languages** | Embedded C, Python (Telemetry & Control), C++, and Dart (Flutter) |
| **Protocols** | I2C, SPI, UART, MQTT, and BLE |
| **Backend** | Firebase Real-time Database and Cloud Storage |

## Repository Structure

```bash
Vikrant_The_bike/
├── bike_control.py           # Core firmware logic for sensor fusion and actuation
├── dashboard_sensor_data.py  # Telemetry processing and GUI data handling
├── Database_Structure.png    # Relational mapping for Firebase & MQTT topics
├── vikrant/                  # Flutter-based mobile command center
│   ├── lib/                  # Native Dart source files for the UI
│   ├── pubspec.yaml          # Dependency management (Firebase, Google Maps SDK)
│   └── ... 
└── ...
```

## Setup & Deployment
### Hardware Integration
* **Sensor Calibration:** Ensure all I2C/UART nodes (BMS, GPS, MPU6050) are addressed correctly as per the `bike_control.py` configuration.
* **Power Management:** The Raspberry Pi 4 requires a stable **5V/3A supply**, ideally isolated from the main motor power rail to prevent EMI interference.
### Software Configuration
#### Python Backend
```bash
pip install firebase-admin paho-mqtt
# Ensure serviceAccountKey.json is in the root directory
python bike_control.py
```
#### Flutter Mobile App
```bash
cd vikrant
flutter pub get
flutter run
```

## Achievements & Impact
* **National Ranking:** Led the team to a top-tier ranking in the national-level **SIEP E-Bike Challenge**.
* **Technical Leadership:** Managed the end-to-end System Development Life Cycle (SDLC), transitioning the project from an early-stage prototype to a production-ready system.

### Database Structure
The project utilizes a **Firebase Real-time Database** combined with an **MQTT Broker** to ensure low-latency synchronization between the bike's hardware and the mobile application.
  * **Vehicle Telemetry:** Stores real-time strings for `speed`, `distance`, and `battery_percentage`.
  * **System Status:** Monitors `indicator_status` and `BMS_health` for the live dashboard.
  * **Security Layer:** Manages `geo-fence_coordinates` and `biometric_auth_logs` for anti-theft monitoring.
  * **Emergency Node:** Dedicated path for `SOS_alerts` and `live_GPS_coordinates` triggered by impact sensors.

### Project Roadmap
The development follows a modular **Agile/SDLC** approach, transitioning from core hardware stability to advanced AI-driven features.
#### Phase 1: Core Systems (Completed)
  * **Framework:** Established Raspberry Pi 4 as the central IoT gateway and ESP32 for edge node sensing.
  * **Connectivity:** Validated UART/I2C communication protocols and integrated Firebase for cloud data sync.
  * **Security:** Implemented biometric ignition and keypad authentication.
#### Phase 2: Performance & Stability (In Progress)
  * **Auto-Balancing:** Finalizing the PID control logic for the automated balancing mechanism.
  * **Power Optimization:** Engineering an isolated power rail to mitigate EMI interference between the motor and telemetry sensors.
  * **Advanced Analytics:** Integrating edge-processing to calculate ride efficiency and battery depletion curves locally.
#### Phase 3: Future Enhancements (Planned)
  * **Offline Mode:** Implementing a local SQLite buffer for data logging during cellular dead zones, with automated sync on reconnect.
  * **Edge AI Integration:** Exploring TinyML concepts for predictive maintenance alerts based on motor vibration patterns.
  * **V2X Communication:** Expansion of the SOS system to include Vehicle-to-Everything (V2X) basic safety messaging.

### License & Contact
  * **Developer:** Ritul Raj Bhakat (Firmware Developer)
  * **License:** MIT License
  * **Contact:** [ritulraj384@gmail.com](mailto:ritulraj384@gmail.com) 
  * **Professional Links:** [LinkedIn](https://www.linkedin.com/in/ritul-raj-bhakat-521202277/) | [Portfolio](https://github.com/Chikkkuuu) | [GitHub](https://github.com/Chikkkuuu) 
