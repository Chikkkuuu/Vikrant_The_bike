import firebase_admin
from firebase_admin import credentials, db
import time

# Initialize Firebase
cred = credentials.Certificate("firebase_key.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://vikrantebike-default-rtdb.firebaseio.com/'
})

bike_id = "WB12JH5689"
base_path = f"/bike/{bike_id}/bike_control"

paths = {
    "angular_movement": f"{base_path}/angular_movement",
    "bike_controlled_from_phone": f"{base_path}/bike_controlled_from_phone",
    "headlight_front": f"{base_path}/headlight_front",
    "horn": f"{base_path}/horn",
    "indicator_left": f"{base_path}/indicator_left",
    "indicator_right": f"{base_path}/indicator_right",
    "linear_movement": f"{base_path}/linear_movement",
}

def get_value(path):
    try:
        ref = db.reference(path)
        return ref.get()
    except Exception as e:
        print(f"Error reading {path}: {e}")
        return None

def interpret(values):
    # Angular movement
    angular = values.get("angular_movement")
    if angular == -20:
        print("⬅Turn Left")
    elif angular == 20:
        print("Turn Right")
    else:
        print("⬆Going Straight")

    # Linear movement
    linear = values.get("linear_movement")
    if linear == -20:
        print("🏍️ Moving Forward")
    elif linear == 20:
        print("Moving Backward")
    else:
        print("Stopped")

    # Controlled from phone
    if values.get("bike_controlled_from_phone"):
        print("Bike is controlled from phone")
    else:
        print("Bike is NOT controlled from phone")

    # Headlight
    if values.get("headlight_front"):
        print("Headlight: ON")
    else:
        print("Headlight: OFF")

    # Horn
    if values.get("horn"):
        print("Horn: ON")
    else:
        print("Horn: OFF")

    # Indicators
    if values.get("indicator_left"):
        print("Left Indicator: ON")
    else:
        print("Left Indicator: OFF")

    if values.get("indicator_right"):
        print("Right Indicator: ON")
    else:
        print("Right Indicator: OFF")

    print("-" * 40)

'''
def interpret(values):
    """
    Single function to initialize (on first call) and control all actuator devices
    Controls: Motor, Servo, LEDs, Buzzer based on input values
    """
    
    # Static variables to maintain device state between calls
    if not hasattr(interpret, 'initialized'):
        interpret.initialized = False
        interpret.current_state = {}
        interpret.indicator_threads = {}
        
        # GPIO pins configuration
        interpret.motor_pin1 = 18      # Motor forward
        interpret.motor_pin2 = 19      # Motor backward  
        interpret.motor_enable = 12    # Motor PWM enable
        interpret.servo_pin = 21       # Servo control
        interpret.led_headlight = 25   # LED3 - Headlight
        interpret.led_left = 23        # LED1 - Left indicator
        interpret.led_right = 24       # LED2 - Right indicator
        interpret.buzzer_pin = 22      # Horn buzzer
        
        # PWM objects
        interpret.motor_pwm = None
        interpret.servo_pwm = None
    
    # Initialize hardware on first call
    if not interpret.initialized:
        print("Initializing actuator devices...")
        
        try:
            # Setup GPIO
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            
            # Setup motor pins
            GPIO.setup([interpret.motor_pin1, interpret.motor_pin2, interpret.motor_enable], GPIO.OUT)
            interpret.motor_pwm = GPIO.PWM(interpret.motor_enable, 1000)  # 1kHz
            interpret.motor_pwm.start(0)
            
            # Setup servo pin
            GPIO.setup(interpret.servo_pin, GPIO.OUT)
            interpret.servo_pwm = GPIO.PWM(interpret.servo_pin, 50)  # 50Hz for servo
            interpret.servo_pwm.start(7.5)  # Center position (90 degrees)
            
            # Setup LED and buzzer pins
            all_pins = [interpret.led_headlight, interpret.led_left, interpret.led_right, interpret.buzzer_pin]
            GPIO.setup(all_pins, GPIO.OUT)
            
            # Turn off all outputs initially
            GPIO.output([interpret.motor_pin1, interpret.motor_pin2], GPIO.LOW)
            GPIO.output(all_pins, GPIO.LOW)
            
            interpret.initialized = True
            print("All actuator devices initialized successfully!")
            
        except Exception as e:
            print(f"Initialization error: {e}")
            return
    
    # Helper function for indicator blinking
    def blink_indicator(pin, side):
        """Blink indicator LED in separate thread"""
        blink_count = 0
        while interpret.current_state.get(f"indicator_{side}", False) and blink_count < 20:
            GPIO.output(pin, GPIO.HIGH)
            time.sleep(0.3)
            GPIO.output(pin, GPIO.LOW)
            time.sleep(0.3)
            blink_count += 1
    
    # Control drive motor based on linear movement
    linear = values.get("linear_movement", 0)
    try:
        if linear == -20:  # Moving Forward
            GPIO.output(interpret.motor_pin1, GPIO.HIGH)
            GPIO.output(interpret.motor_pin2, GPIO.LOW)
            interpret.motor_pwm.ChangeDutyCycle(50)  # 70% speed
            print("🏍️ Motor: Moving Forward")
            
        elif linear == 20:  # Moving Backward  
            GPIO.output(interpret.motor_pin1, GPIO.LOW)
            GPIO.output(interpret.motor_pin2, GPIO.HIGH)
            interpret.motor_pwm.ChangeDutyCycle(30)  # 50% speed for safety
            print("Motor: Moving Backward")
            
        else:  # Stopped
            GPIO.output(interpret.motor_pin1, GPIO.LOW)
            GPIO.output(interpret.motor_pin2, GPIO.LOW)
            interpret.motor_pwm.ChangeDutyCycle(0)
            print("Motor: Stopped")
            
    except Exception as e:
        print(f"Motor control error: {e}")
    
    # Control servo motor for steering direction
    angular = values.get("angular_movement", 0)
    try:
        if angular == -20:  # Turn Left
            interpret.servo_pwm.ChangeDutyCycle(5)  # 0 degrees (full left)
            print("Servo: Turn Left")
            
        elif angular == 20:  # Turn Right
            interpret.servo_pwm.ChangeDutyCycle(10)  # 180 degrees (full right)
            print("Servo: Turn Right")
            
        else:  # Going Straight
            interpret.servo_pwm.ChangeDutyCycle(7.5)  # 90 degrees (center)
            print("Servo: Going Straight")
            
    except Exception as e:
        print(f"Servo control error: {e}")
    
    # Control headlight LED3
    headlight = values.get("headlight_front", False)
    try:
        if headlight:
            GPIO.output(interpret.led_headlight, GPIO.HIGH)
            print("LED3 (Headlight): ON")
        else:
            GPIO.output(interpret.led_headlight, GPIO.LOW)
            print("LED3 (Headlight): OFF")
            
    except Exception as e:
        print(f"Headlight control error: {e}")
    
    # Control horn buzzer
    horn = values.get("horn", False)
    try:
        if horn:
            GPIO.output(interpret.buzzer_pin, GPIO.HIGH)
            print("Buzzer (Horn): ON")
        else:
            GPIO.output(interpret.buzzer_pin, GPIO.LOW)
            print("Buzzer (Horn): OFF")
            
    except Exception as e:
        print(f"Horn control error: {e}")
    
    # Control indicator LEDs with blinking
    left_indicator = values.get("indicator_left", False)
    right_indicator = values.get("indicator_right", False)
    
    try:
        # Stop existing indicator threads
        for thread in interpret.indicator_threads.values():
            if thread.is_alive():
                thread.join(timeout=0.1)
        interpret.indicator_threads.clear()
        
        # Left Indicator (LED1)
        if left_indicator:
            interpret.current_state["indicator_left"] = True
            thread = threading.Thread(target=blink_indicator, args=(interpret.led_left, "left"))
            thread.daemon = True
            thread.start()
            interpret.indicator_threads["left"] = thread
            print("LED1 (Left Indicator): BLINKING")
        else:
            interpret.current_state["indicator_left"] = False
            GPIO.output(interpret.led_left, GPIO.LOW)
            print("LED1 (Left Indicator): OFF")
        
        # Right Indicator (LED2)
        if right_indicator:
            interpret.current_state["indicator_right"] = True
            thread = threading.Thread(target=blink_indicator, args=(interpret.led_right, "right"))
            thread.daemon = True
            thread.start()
            interpret.indicator_threads["right"] = thread
            print("LED2 (Right Indicator): BLINKING")
        else:
            interpret.current_state["indicator_right"] = False
            GPIO.output(interpret.led_right, GPIO.LOW)
            print("LED2 (Right Indicator): OFF")
            
    except Exception as e:
        print(f"Indicator control error: {e}")
    
    # Phone control status (informational)
    if values.get("bike_controlled_from_phone"):
        print("Bike is controlled from phone")
    else:
        print("Bike is NOT controlled from phone")
    
    print("-" * 40)

'''

def main():
    while True:
        start_time = time.time()

        values = {key: get_value(path) for key, path in paths.items()}
        interpret(values)

        elapsed = time.time() - start_time
        time.sleep(max(0, 0.01 - elapsed))  # ~10ms polling

if __name__ == "__main__":
    main()
