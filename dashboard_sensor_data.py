import random
import sys
import atexit
import signal
from flask import Flask, render_template_string, jsonify

try:
    import pyrebase
    firebase_enabled = True
except ImportError:
    firebase_enabled = False
    print("⚠️ Pyrebase not installed. Firebase disabled.")

if firebase_enabled:
    try:
        firebase = pyrebase.initialize_app(firebase_config)
        db = firebase.database()
    except Exception as e:
        print(f"⚠️ Firebase initialization failed: {e}")
        firebase_enabled = False

BIKE_NUMBER = "WB12JH5689"
BASE_PATH = f"bike/{BIKE_NUMBER}/bike_dashboard"

# Helper: Set bike_connected status
def set_bike_connected_status(status):
    if firebase_enabled:
        try:
            db.child(f"{BASE_PATH}/bike_connected").set(status)
            print(f"ℹ️ bike_connected set to '{status}'")
        except Exception as e:
            print(f"⚠️ Failed to set bike_connected status: {e}")

# Handle graceful exit
def on_exit():
    print("Application exiting... setting bike_connected to 'off'")
    set_bike_connected_status("off")

atexit.register(on_exit)

# Handle SIGINT/SIGTERM
def signal_handler(sig, frame):
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

# Simulated sensor data
def get_sensor_data():
    return {
        "location": (
            round(random.uniform(12.9700, 12.9800), 6),
            round(random.uniform(77.5900, 77.6000), 6)
        ),
        "acceleration": round(random.uniform(15.0, 20.0), 2),
        "battery_voltage": round(random.uniform(35.0, 65.0), 2),
        "motor_temp": round(random.uniform(30, 50), 1),
        "co_detected": random.choice([False] * 8 + [True])
    }

'''
def get_sensor_data():

    # Static variables to maintain sensor objects between calls
    if not hasattr(get_sensor_data, 'initialized'):
        get_sensor_data.initialized = False
        get_sensor_data.gps = None
        get_sensor_data.gps_serial = None
        get_sensor_data.ads = None
        get_sensor_data.battery_channel = None
        get_sensor_data.co_channel = None
        get_sensor_data.mpu = None
        get_sensor_data.dht = None
        get_sensor_data.co_threshold = 1.5  # Volts
    
    # Initialize sensors on first call
    if not get_sensor_data.initialized:
        print("Initializing sensors...")
        
        # Initialize GPS
        try:
            get_sensor_data.gps_serial = serial.Serial("/dev/ttyS0", baudrate=9600, timeout=10)
            get_sensor_data.gps = adafruit_gps.GPS(get_sensor_data.gps_serial, debug=False)
            get_sensor_data.gps.send_command(b"PMTK314,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0")
            get_sensor_data.gps.send_command(b"PMTK220,1000")
            print("GPS initialized successfully")
        except Exception as e:
            print(f"GPS initialization failed: {e}")
            get_sensor_data.gps = None
        
        # Initialize ADC
        try:
            i2c = busio.I2C(board.SCL, board.SDA)
            get_sensor_data.ads = ADS.ADS1115(i2c)
            get_sensor_data.battery_channel = AnalogIn(get_sensor_data.ads, ADS.P0)
            get_sensor_data.co_channel = AnalogIn(get_sensor_data.ads, ADS.P1)
            print("ADC initialized successfully")
        except Exception as e:
            print(f"ADC initialization failed: {e}")
            get_sensor_data.ads = None
        
        # Initialize Accelerometer
        try:
            if 'i2c' not in locals():
                i2c = busio.I2C(board.SCL, board.SDA)
            get_sensor_data.mpu = adafruit_mpu6050.MPU6050(i2c)
            print("Accelerometer initialized successfully")
        except Exception as e:
            print(f"Accelerometer initialization failed: {e}")
            get_sensor_data.mpu = None
        
        # Initialize Temperature Sensor
        try:
            get_sensor_data.dht = adafruit_dht.DHT22(board.D4)
            print("Temperature sensor initialized successfully")
        except Exception as e:
            print(f"Temperature sensor initialization failed: {e}")
            get_sensor_data.dht = None
        
        get_sensor_data.initialized = True
        print("All sensors initialized!")
    
    # Collect GPS data
    location = None
    if get_sensor_data.gps:
        try:
            get_sensor_data.gps.update()
            if get_sensor_data.gps.has_fix:
                lat = round(get_sensor_data.gps.latitude, 6)
                lon = round(get_sensor_data.gps.longitude, 6)
                location = (lat, lon)
            else:
                print("Waiting for GPS fix...")
        except Exception as e:
            print(f"GPS read error: {e}")
    
    # Collect battery voltage
    battery_voltage = None
    if get_sensor_data.battery_channel:
        try:
            raw_voltage = get_sensor_data.battery_channel.voltage
            battery_voltage = round(raw_voltage * (65.0 / 3.3), 2)
        except Exception as e:
            print(f"Battery voltage read error: {e}")
    
    # Collect acceleration data
    acceleration = None
    if get_sensor_data.mpu:
        try:
            accel_x, accel_y, accel_z = get_sensor_data.mpu.acceleration
            magnitude = (accel_x**2 + accel_y**2 + accel_z**2)**0.5
            acceleration = round(magnitude, 2)
        except Exception as e:
            print(f"Acceleration read error: {e}")
    
    # Collect temperature data
    motor_temp = None
    if get_sensor_data.dht:
        try:
            temperature = get_sensor_data.dht.temperature
            motor_temp = round(temperature, 1) if temperature is not None else None
        except Exception as e:
            print(f"Temperature read error: {e}")
    
    # Collect CO detection data
    co_detected = None
    if get_sensor_data.co_channel:
        try:
            co_voltage = get_sensor_data.co_channel.voltage
            co_detected = co_voltage > get_sensor_data.co_threshold
        except Exception as e:
            print(f"CO detection error: {e}")
    
    return {
        "location": location,
        "acceleration": acceleration,
        "battery_voltage": battery_voltage,
        "motor_temp": motor_temp,
        "co_detected": co_detected,
        "timestamp": time.time()
    }
'''


MAX_VOLTAGE = 65.0
MIN_VOLTAGE = 35.0

HTML_DASHBOARD = """
<!DOCTYPE html>
<html>
<head>
    <title>Smart Bike Dashboard</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {
            background-color: #0f111a;
            color: white;
            font-family: 'Segoe UI', sans-serif;
            margin: 0;
            padding: 0;
            text-align: center;
        }
        .container {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 20px;
            padding: 40px 20px;
        }
        .card {
            background: #1f1f2e;
            padding: 20px;
            border-radius: 16px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.4);
            width: 260px;
            transition: transform 0.2s ease;
        }
        .card:hover {
            transform: scale(1.03);
        }
        h1 {
            color: #00ffaa;
            margin-top: 30px;
        }
        .title {
            font-size: 1.2em;
            color: #00c2ff;
        }
        .value {
            font-size: 2em;
            margin-top: 10px;
        }
        .alert {
            color: orange;
            font-weight: bold;
        }
    </style>
    <script>
        async function fetchData() {
            const res = await fetch('/data');
            const data = await res.json();

            document.getElementById("speed").innerText = data.speed + " km/h";
            document.getElementById("battery").innerText = data.battery + "%";
            document.getElementById("temp").innerText = data.temperature + " °C";
            document.getElementById("accel").innerText = data.acceleration + " m/s²";
            document.getElementById("location").innerText = data.location.lat + ", " + data.location.lon;
            document.getElementById("alert").innerText = data.alert;
            document.getElementById("distance").innerText = data.distance + " km";

            document.getElementById("alert").style.color = data.alert === "All systems normal" ? "lime" : "orange";
        }

        setInterval(fetchData, 2000);
        window.onload = fetchData;
    </script>
</head>
<body>
    <h1>🏍 Smart Bike Dashboard</h1>
    <div class="container">
        <div class="card">
            <div class="title">Speed</div>
            <div class="value" id="speed">-- km/h</div>
        </div>
        <div class="card">
            <div class="title">Battery</div>
            <div class="value" id="battery">--%</div>
        </div>
        <div class="card">
            <div class="title">Motor Temp</div>
            <div class="value" id="temp">-- °C</div>
        </div>
        <div class="card">
            <div class="title">Acceleration</div>
            <div class="value" id="accel">-- m/s²</div>
        </div>
        <div class="card">
            <div class="title">Location</div>
            <div class="value" id="location">--, --</div>
        </div>
        <div class="card">
            <div class="title">Distance Travelled</div>
            <div class="value" id="distance">-- km</div>
        </div>
        <div class="card alert">
            <div class="title">Alert</div>
            <div class="value" id="alert">--</div>
        </div>
    </div>
</body>
</html>
"""

# Flask app
app = Flask(__name__)

@app.route('/')
def dashboard():
    return render_template_string(HTML_DASHBOARD)

@app.route('/data')
def data():
    sensor = get_sensor_data()
    dt = 1
    speed = sensor['acceleration'] * dt * 3.6
    distance_delta = round(speed * (dt / 3600), 2)

    battery_pct = max(0, min(100, ((sensor['battery_voltage'] - MIN_VOLTAGE) / (MAX_VOLTAGE - MIN_VOLTAGE)) * 100))

    alert = ""
    if sensor["motor_temp"] > 45:
        alert = "Overheating!"
    elif sensor["co_detected"]:
        alert = "CO Gas Detected!"
    else:
        alert = "All systems normal"

    total_distance = distance_delta

    if firebase_enabled:
        try:
            prev = db.child(f"{BASE_PATH}/distance_travelled").get()
            if prev.val():
                try:
                    previous_distance = float(prev.val())
                    total_distance += round(previous_distance, 2)
                except ValueError:
                    print("⚠️ Invalid previous distance value in Firebase")

            gps_string = f"{sensor['location'][0]},{sensor['location'][1]}"

            db.child(f"{BASE_PATH}/speed").set(round(speed, 1))
            db.child(f"{BASE_PATH}/acceleration").set(sensor['acceleration'])
            db.child(f"{BASE_PATH}/battery_percentage").set(round(battery_pct, 1))
            db.child(f"{BASE_PATH}/charge").set(battery_pct > 20)
            db.child(f"{BASE_PATH}/gps_location").set(gps_string)
            db.child(f"{BASE_PATH}/distance_travelled").set(round(total_distance, 2))

        except Exception as e:
            print(f"⚠️ Firebase update error: {e}")

    response = {
        "speed": round(speed, 1),
        "acceleration": sensor['acceleration'],
        "battery": round(battery_pct, 1),
        "temperature": sensor['motor_temp'],
        "location": {
            "lat": sensor['location'][0],
            "lon": sensor['location'][1]
        },
        "distance": round(total_distance, 2),
        "alert": alert
    }

    return jsonify(response)

# App entry point
if __name__ == '__main__':
    set_bike_connected_status("on")
    print("✅ Application started... setting bike_connected to 'on'")
    app.run(debug=True, host="0.0.0.0")
