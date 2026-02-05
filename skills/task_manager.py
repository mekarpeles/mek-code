#!/usr/bin/env python3
import sys
import json
import os
import argparse
from datetime import datetime

STATUS_FILE = "/app/state/tasks.json"

def load_status():
    if not os.path.exists(STATUS_FILE):
        return {"subagents": [], "history": []}
    try:
        with open(STATUS_FILE, "r") as f:
            return json.load(f)
    except:
        return {"subagents": [], "history": []}

def save_status(data):
    with open(STATUS_FILE, "w") as f:
        json.dump(data, f, indent=2)

def list_tasks():
    data = load_status()
    print("LOGGED SUBAGENTS:")
    if not data["subagents"] and not data["history"]:
        print("  (No activity logged)")
        return

    if data["subagents"]:
        print("\n[RUNNING / QUEUED]")
        for task in data["subagents"]:
            print(f"  - {task['name']} (ID: {task['id']}) - Status: {task['status']}")
            
    if data["history"]:
        print("\n[HISTORY]")
        for task in data["history"][-5:]: # Show last 5
            print(f"  - {task['name']} (ID: {task['id']}) - {task['result']}")

def add_task(name, status="running"):
    data = load_status()
    task_id = len(data["subagents"]) + len(data["history"]) + 1
    task = {
        "id": task_id,
        "name": name,
        "status": status,
        "started_at": str(datetime.now())
    }
    data["subagents"].append(task)
    save_status(data)
    print(f"Subagent '{name}' (ID: {task_id}) started.")

def complete_task(task_id, result="done"):
    data = load_status()
    # Find task
    found = None
    for i, t in enumerate(data["subagents"]):
        if str(t["id"]) == str(task_id):
            found = t
            del data["subagents"][i]
            break
    
    if found:
        found["result"] = result
        found["completed_at"] = str(datetime.now())
        data["history"].append(found)
        save_status(data)
        print(f"Task {task_id} completed.")
    else:
        print(f"Task {task_id} not found in running list.")

def main():
    parser = argparse.ArgumentParser(description="Task/Subagent Manager")
    subparsers = parser.add_subparsers(dest="command")
    
    subparsers.add_parser("list", help="List all skills/tasks")
    
    add_p = subparsers.add_parser("start", help="Register a starting subagent")
    add_p.add_argument("name", help="Name of subagent/skill")
    
    done_p = subparsers.add_parser("complete", help="Mark subagent as complete")
    done_p.add_argument("id", help="Task ID")
    done_p.add_argument("--result", default="success", help="Result summary")

    args = parser.parse_args()

    if args.command == "list":
        list_tasks()
        # Also list available skills from directory
        print("\nAVAILABLE SKILLS (in /workspace/skills):")
        try:
            skills = [d for d in os.listdir("/workspace/skills") if os.path.isdir(os.path.join("/workspace/skills", d))]
            for s in skills:
                print(f"  - {s}")
        except Exception as e:
            print(f"  Error reading skills: {e}")

    elif args.command == "start":
        add_task(args.name)
    elif args.command == "complete":
        complete_task(args.id, args.result)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
