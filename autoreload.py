import time
import subprocess
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import sys
import threading


SCRIPT_NAME = "main.py"

class ReloadHandler(FileSystemEventHandler):
    def __init__(self):
        self.process = None
        self.debounce_timer = None
        self.start_process(True)

    def start_process(self,prints):
        if self.process:
            self.process.kill()
        if prints :
            print(f"🔁 Running {SCRIPT_NAME}...")
        self.process = subprocess.Popen([sys.executable, "main.py"])
        

    def on_modified(self, event):
        if event.src_path.endswith(SCRIPT_NAME):
            # Cancel any scheduled restart
            if self.debounce_timer:
                self.debounce_timer.cancel()
            # Schedule a restart after short delay
            self.debounce_timer = threading.Timer(0.5, self.restart_script)
            self.debounce_timer.start()

    def restart_script(self):
        print(f"\n🔄 Detected change in {SCRIPT_NAME}, restarting...")
        self.start_process(False)

if __name__ == "__main__":
    event_handler = ReloadHandler()
    observer = Observer()
    observer.schedule(event_handler, ".", recursive=False)
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
        if event_handler.process:
            event_handler.process.kill()
    observer.join()