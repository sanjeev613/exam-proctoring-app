import re

file_path = "c:\\Users\\sanje\\exam_proctoring_app\\camera_companion\\companion_production.py"
with open(file_path, "r", encoding="utf-8") as f:
    code = f.read()

# Make SESSION_ID global and initially empty if it's the default dummy one
code = re.sub(
    r'SESSION_ID\s*=\s*os\.getenv\("COMPANION_SESSION_ID", ".*?"\)',
    'SESSION_ID = os.getenv("COMPANION_SESSION_ID", "")',
    code
)

fetch_logic = """
def update_session_id():
    global SESSION_ID
    try:
        r = requests.get(f"{BACKEND_URL}/api/companion/active-session", timeout=2)
        if r.status_code == 200:
            data = r.json()
            new_session = data.get("sessionId")
            if new_session and new_session != SESSION_ID:
                logging.info(f"Session updated to {new_session}")
                SESSION_ID = new_session
    except Exception as e:
        pass

def send(payload):
"""

code = code.replace("def send(payload):", fetch_logic)

# Replace the beginning of sending to avoid sending if no session
send_modify = """    if not SESSION_ID:
        return
    body = {"sessionId": SESSION_ID, **payload}"""

code = code.replace('    body = {"sessionId": SESSION_ID, **payload}', send_modify)

# Call update_session_id in the main loop
loop_start = """            if not ok or frame is None:
                logging.warning("Frame grab failed")
                time.sleep(0.3)
                continue"""
                
loop_modify = """            if not ok or frame is None:
                logging.warning("Frame grab failed")
                time.sleep(0.3)
                continue

            if frame_count % 15 == 0:
                update_session_id()"""
code = code.replace(loop_start, loop_modify)


with open(file_path, "w", encoding="utf-8") as f:
    f.write(code)

print("Companion update successful")
