import os
import sys
import time
import threading
import subprocess
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

SCRIPT_NAME = "bot.py"  # Entry point to restart when any .py file changes

class ReloadHandler(FileSystemEventHandler):
    def __init__(self):
        self.process = None
        self.debounce_timer = None
        self.start_process(first_run=True)

    def start_process(self, first_run=False):
        os.system('cls' if os.name == 'nt' else 'clear')
        if self.process:
            self.process.kill()
        if first_run:
            print(f"🔁 Starting {SCRIPT_NAME}...")
        else:
            print(f"\n🔄 Change detected in Python files. Restarting {SCRIPT_NAME}...")
        self.process = subprocess.Popen([sys.executable, SCRIPT_NAME])

    def on_modified(self, event):
        if event.is_directory:
            return
        if event.src_path.endswith(".py"):  # Only restart for Python files
            if self.debounce_timer:
                self.debounce_timer.cancel()
            self.debounce_timer = threading.Timer(0.5, self.restart_script)
            self.debounce_timer.start()

    def restart_script(self):
        self.start_process(first_run=False)

if __name__ == "__main__":
    event_handler = ReloadHandler()
    observer = Observer()
    observer.schedule(event_handler, ".", recursive=True)  # Watch all subfolders too
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n🛑 Shutting down watcher...")
        observer.stop()
        if event_handler.process:
            event_handler.process.kill()
    observer.join()