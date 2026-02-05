#!/usr/bin/env python3
import argparse
import os
import sys

AGENT_FILE = "/app/AGENTS.md"

def update_agent_md(name, description, command):
    """Appends the new skill to AGENTS.md"""
    entry = f"\n### {name}\n**Description**: {description}\n**Command**: `{command}`\n"
    
    try:
        with open(AGENT_FILE, "r") as f:
            content = f.read()
        
        # Check if skill already exists
        if f"### {name}" in content:
            print(f"Skill {name} already exists in AGENTS.md. Skipping registration.")
            # Implementation detail: We might want to update it, but simple append is safer for now.
            return

        with open(AGENT_FILE, "a") as f:
            f.write(entry)
        print(f"Registered {name} in {AGENT_FILE}")
    except Exception as e:
        print(f"Error updating AGENT.md: {e}")

def main():
    parser = argparse.ArgumentParser(description="Create or update a skill")
    parser.add_argument("--name", required=True, help="Name of the skill")
    parser.add_argument("--instruction", required=True, help="Description/Instruction for the skill")
    parser.add_argument("--code", help="Python code for the skill")
    
    args = parser.parse_args()
    
    skill_dir = os.path.join("/app/skills", args.name)
    os.makedirs(skill_dir, exist_ok=True)
    
    # Create README
    readme_path = os.path.join(skill_dir, "README.md")
    with open(readme_path, "w") as f:
        f.write(f"# {args.name}\n\n{args.instruction}")
    
    # Create Script
    script_path = os.path.join(skill_dir, "run.py")
    code = args.code if args.code else f"print('Skill {args.name} is not yet implemented.')"
    
    with open(script_path, "w") as f:
        f.write(code)
    
    print(f"Skill {args.name} created at {skill_dir}")
    
    # Register
    command = f"python3 {script_path}"
    update_agent_md(args.name, args.instruction, command)

if __name__ == "__main__":
    main()
