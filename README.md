# Vikrant: High-Performance Smart E-Bike Ecosystem

Vikrant is an advanced, IoT-integrated electric vehicle control and monitoring system developed for the **SIEP E-Bike Challenge**[cite: 23]. This project replaces traditional e-bike frameworks with a smart, connected ecosystem featuring a secure hardware access layer and real-time telemetry.

## System Architecture

The architecture is divided into two primary execution environments: the **Actuator Control Engine** and the **Telemetry & Dashboard Service**.
### 1. Actuator Control Engine (`Firmware/bike_control.py`)
This script manages high-frequency polling (~10ms) of the Firebase Real-time Database to drive physical hardware.
* **Drive Control:** Interprets `linear_movement` values to manage motor states (Forward, Backward, Stopped) with safe duty cycles (30% for reverse, 50% for forward).
* **Steering Logic:** Translates `angular_movement` into PWM duty cycles for servo-based steering (5% for full left, 10% for full right, 7.5% for center).
* **Lighting & Audio:** Manages GPIO states for the headlight LED, horn buzzer, and asynchronous threading for blinking left/right indicator LEDs.
* **Hardware Initialization:** Features a robust static initialization routine for GPIO BCM mode, PWM objects (Motor at 1kHz, Servo at 50Hz), and error-resilient pin setup.
### 2. Telemetry & Dashboard Service (`Firmware/dashboard_sensor_data.py`)
A Flask-based web server that simulates/collects sensor data and synchronizes it with the cloud for remote monitoring.
* **Dynamic Analytics:** Calculates real-time speed and `distance_delta` based on acceleration and time intervals ($dt = 1s$).
* **Battery Management (BMS):** Computes `battery_percentage` using a linear mapping between 35V (0%) and 65V (100%).
* **Safety Alert System:** Monitored triggers for `motor_temp` (> 45°C) and CO Gas detection to broadcast critical alerts.
* **Connectivity Management:** Utilizes `atexit` and `signal` handlers to automatically update the `bike_connected` status to "off" upon application exit, ensuring accurate system availability tracking.

## Database Architecture
The **Firebase Real-time Database** is architected to prioritize low-latency command execution and high-frequency telemetry updates.
* **Vehicle Identity (`bike/{reg_no}/bike_Details`)**: Stores the immutable vehicle profile and the `bike_last_controlled_time` to audit system usage.
* **Command Node (`bike/{reg_no}/bike_control`)**: Contains boolean and integer flags for real-time actuation, such as `headlight_front`, `horn`, and `angular_movement`.
* **Telemetry Node (`bike/{reg_no}/bike_dashboard`)**: A high-frequency stream of vehicle dynamics including `speed` (**71.2 km/h**), `battery_percentage` (**35.2%**), and live `gps_location`.
* **User Security (`user_details`)**: Bridges Firebase Authentication UIDs with specific vehicle access permissions, supporting the **Secure Hardware Access Layer**.

## Repository Structure
The codebase is organized to separate firmware logic, mobile development, and cloud functions for maximum modularity.
```text
Vikrant_The_bike/
├── Firmware
|    ├── bike_control.py                  # Actuator control: Motor, Servo, and GPIO logic
|    ├── dashboard_sensor_data.py         # Telemetry engine: Flask server and Firebase sync
└── vikrant/                              # Flutter Mobile Command Center
|    ├── android/ & ios/                  # Native platform-specific configurations and permissions.
|    ├── assets/                          # Custom NicoMoji-Regular fonts and vehicle branding assets.
|    ├── functions/                       # Node.js backend logic for automated SOS and user auth.
|    ├── lib/                             # Dart Source Code
|    │   ├── data/                        # Models for mapping Firebase JSON to local objects.
|    │   ├── screens/                     # UI for Dashboard, Play Mode, and Real-time Telemetry.
|    │   ├── widgets/                     # Modular components: Google Maps integration and Auth forms.
|    │   └── main.dart                    # Application entry point and Firebase initialization.
|    └── pubspec.yaml                     # Project dependencies (firebase_core, google_maps_flutter).
└── LICENSE                               # MIT Open Source License
```

## Deployment and Setup
### Hardware Integration
* **Calibration:** Verify I2C/UART addressing for BMS, GPS, and MPU6050 nodes in `bike_control.py`.
* **Power Management:** Requires a stable **5V/3A supply** for the Raspberry Pi 4, isolated from the motor rail to prevent EMI interference.
### Software Configuration
1. **Python Backend:**
   ```bash
   pip install firebase-admin paho-mqtt
   # Place serviceAccountKey.json in the root directory
   python Firmware/bike_control.py
   python Firmware/dashboard_sensor_data.py
   ```
2. **Flutter Mobile App:**
   ```bash
   cd vikrant
   flutter pub get
   flutter run
   ```

## Professional Profile
* **Developer:** Ritul Raj Bhakat (Firmware Developer)
* **Achievement:** Top ranking in the national-level **SIEP E-Bike Challenge**.
* **Contact:** [ritulraj384@gmail.com](mailto:ritulraj384@gmail.com) | [LinkedIn](https://www.linkedin.com/in/ritul-raj-bhakat-521202277/) | [Github](https://github.com/Chikkkuuu) | [Portfolio](https://ritulrajbhakatportfolio.vercel.app/)
