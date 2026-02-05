#!/usr/bin/env python3
import sys
import os
import json
import time
import uuid
import subprocess
from datetime import datetime
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# Paths
BASE_DIR = "/app"
MAILBOX_DIR = os.path.join(BASE_DIR, "mailbox")
INBOX_DIR = os.path.join(MAILBOX_DIR, "inbox")
OUTBOX_DIR = os.path.join(MAILBOX_DIR, "outbox")
TASKS_DIR = os.path.join(BASE_DIR, "tasks")
TASKS_FILE = os.path.join(TASKS_DIR, "running.json") # Default tracking file

# Ensure state directories exist
os.makedirs(INBOX_DIR, exist_ok=True)
os.makedirs(OUTBOX_DIR, exist_ok=True)

class InboxHandler(FileSystemEventHandler):
    def __init__(self, daemon):
        self.daemon = daemon

    def on_created(self, event):
        if not event.is_directory and event.src_path.endswith('.json'):
            print(f"DEBUG: New message in inbox: {event.src_path}")
            # Use specific processing delay or queue
            time.sleep(0.1) 
            self.daemon.process_message(event.src_path)

class MekOSDaemon:
    def __init__(self):
        print("Starting mekOS Daemon...")
        self.ensure_tasks_file()
        
    def ensure_tasks_file(self):
        if not os.path.exists(TASKS_FILE):
            with open(TASKS_FILE, "w") as f:
                json.dump({"tasks": [], "history": []}, f)

    def process_message(self, filepath):
        try:
            with open(filepath, "r") as f:
                msg = json.load(f)
            
            # Identify sender
            source = msg.get("source", "unknown")
            print(f"Processing message {msg.get('id')} from {source}")

            if source == "user":
                self.handle_user_message(msg)
            elif source == "system":
                # System notification (e.g. task update)
                pass # Can implement routing later
            
            # Move to processed (optional, for now we leave it or delete)
            # os.remove(filepath) 
            # Ideally move to 'processed' folder.
            # For this MVP, let's delete to keep inbox clean for the watcher
            os.remove(filepath)
            
        except Exception as e:
            print(f"Error processing message {filepath}: {e}")

    def handle_user_message(self, msg):
        prompt = msg.get("text")
        msg_id = msg.get("id")
        
        # Invoke OpenCode
        # Uses 'run' to allow one-shot inference with current context
        # We might want to pass more context if 'opencode run' doesn't stay 'warm' well enough
        # But 'opencode run' is the CLI way.
        
        print(f"Invoking Agent with: {prompt}")
        
        try:
            cmd = ["opencode", "run", prompt]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
            
            response_text = result.stdout.strip()
            if result.returncode != 0:
                response_text = f"Agent Error: {result.stderr}"

            # Write reply
            self.send_reply(msg_id, response_text)
            
        except Exception as e:
            self.send_reply(msg_id, f"System Error: {str(e)}")

    def send_reply(self, correlation_id, text):
        reply = {
            "id": str(uuid.uuid4()),
            "correlation_id": correlation_id,
            "text": text,
            "timestamp": str(datetime.now()),
            "source": "assistant"
        }
        
        filename = f"{reply['id']}.json"
        path = os.path.join(OUTBOX_DIR, filename)
        
        with open(path, "w") as f:
            json.dump(reply, f, indent=2)
        print(f"Reply written to {path}")

    def start(self):
        observer = Observer()
        observer.schedule(InboxHandler(self), INBOX_DIR, recursive=False)
        observer.start()
        print(f"Watching {INBOX_DIR}...")
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            observer.stop()
        observer.join()

if __name__ == "__main__":
    daemon = MekOSDaemon()
    daemon.start()
