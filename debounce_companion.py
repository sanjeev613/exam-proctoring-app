import re

file_path = "c:\\Users\\sanje\\exam_proctoring_app\\camera_companion\\companion_production.py"
with open(file_path, "r", encoding="utf-8") as f:
    code = f.read()

smoother_class = """
from collections import deque

class EventSmootherAndCooldown:
    def __init__(self, cooldown_seconds=15.0, require_consecutive=2):
        self.cooldown_seconds = cooldown_seconds
        self.require_consecutive = require_consecutive
        self.state_history = {}
        self.last_trigger_time = {}

    def process(self, event_name, is_detected, now):
        if event_name not in self.state_history:
            self.state_history[event_name] = deque(maxlen=self.require_consecutive)
            self.last_trigger_time[event_name] = 0.0
        
        self.state_history[event_name].append(bool(is_detected))
        
        consistently_detected = all(self.state_history[event_name]) and len(self.state_history[event_name]) == self.require_consecutive
        
        if consistently_detected:
            if now - self.last_trigger_time[event_name] > self.cooldown_seconds:
                self.last_trigger_time[event_name] = now
                return True
        return False
"""

code = code.replace("from collections import deque", smoother_class, 1)

init_smoother = """    bluetooth_monitor = BluetoothMonitor()
    person_phone_detector = PersonAndPhoneDetector()
    head_detector = HeadMovementDetector()
    speech_detector = SpeechDetector(sample_rate=16000)
    audio = AudioMonitor(speech_detector)
    audio.start()
    
    smoother = EventSmootherAndCooldown(cooldown_seconds=15.0, require_consecutive=2)"""

code = re.sub(r'    bluetooth_monitor = BluetoothMonitor\(\).*?audio\.start\(\)', init_smoother, code, flags=re.DOTALL)

# Add smoothing logic inside the loop before risk calculates
smooth_vars = """                bluetooth_detected = bluetooth_monitor.suspicious_present() or len(new_bluetooth_devices) > 0

                now_t = time.time()
                mobile_stable = smoother.process("mobile", mobile, now_t)
                multi_stable = smoother.process("multi", multi, now_t)
                speech_stable = smoother.process("speech", speech, now_t)
                away_stable = smoother.process("away", head.get("looking_away"), now_t)
                down_stable = smoother.process("down", gaze.get("looking_down"), now_t)
                side_stable = smoother.process("side", gaze.get("looking_side"), now_t)
                bt_stable = smoother.process("bt", bluetooth_detected, now_t)
                low_lighting_stable = smoother.process("lowlight", low_lighting, now_t)
"""
code = code.replace("                bluetooth_detected = bluetooth_monitor.suspicious_present() or len(new_bluetooth_devices) > 0", smooth_vars.strip('\n'))

# Update the payload to send stable variables for events, while keeping RAW for risk
old_payload = """                payload = {
                    "mobileDetected": mobile,
                    "phoneDetected": mobile,
                    "phoneCount": phones,
                    "personCount": persons,
                    "faceCount": faces,
                    "multiPerson": multi,
                    "speechDetected": speech,
                    "humanVoiceDetected": speech,
                    "speechEnergy": energy,
                    "bluetoothDetected": bluetooth_detected,
                    "bluetoothDevices": bluetooth_devices,
                    "bluetoothNewDevices": new_bluetooth_devices,
                    "bluetoothDeviceCount": len(bluetooth_devices),
                    "gazeDirection": gaze.get("direction"),
                    "lookingDown": gaze.get("looking_down"),
                    "lookingSide": gaze.get("looking_side"),
                    "handDetected": hands.get("detected"),
                    "handBelowFrame": hands.get("below_frame"),
                    "flashDetected": flash_detected,
                    "frameBrightness": current_brightness,
                    "lowLighting": low_lighting,
                    "headYaw": head.get("head_yaw", 0.0),
                    "headAngle": head.get("head_yaw", 0.0),
                    "lookingAway": head.get("looking_away", False),
                    "riskScore": risk,
                }"""
                
new_payload = """                payload = {
                    "mobileDetected": mobile_stable,
                    "phoneDetected": mobile_stable,
                    "phoneCount": phones,
                    "personCount": persons,
                    "faceCount": faces,
                    "multiPerson": multi_stable,
                    "speechDetected": speech_stable,
                    "humanVoiceDetected": speech_stable,
                    "speechEnergy": energy,
                    "bluetoothDetected": bt_stable,
                    "bluetoothDevices": bluetooth_devices,
                    "bluetoothNewDevices": new_bluetooth_devices,
                    "bluetoothDeviceCount": len(bluetooth_devices),
                    "gazeDirection": gaze.get("direction"),
                    "lookingDown": down_stable,
                    "lookingSide": side_stable,
                    "handDetected": hands.get("detected"),
                    "handBelowFrame": hands.get("below_frame"),
                    "flashDetected": flash_detected,
                    "frameBrightness": current_brightness,
                    "lowLighting": low_lighting_stable,
                    "headYaw": head.get("head_yaw", 0.0),
                    "headAngle": head.get("head_yaw", 0.0),
                    "lookingAway": away_stable,
                    "riskScore": risk,
                }"""
                
code = code.replace(old_payload, new_payload)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(code)

print("Companion update successful with event smoother logic.")
