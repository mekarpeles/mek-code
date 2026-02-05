# mekOS Architecture: The "Smart Operator"

## Vision
mekOS is not just a chat window; it is a **Dashboard and Dispatcher**. The core Assistant acts as an always-on "Operator" that manages sub-agents and reports back to the user.

## Core Architectural Decisions

### 1. The Filesystem Event Bus (The "Hyperion" Model)
We will adopt the Hyperion folder structure for state management. This is robust, simple, and easy to debug.
-   `/workspace/state/inbox/`: Incoming messages for the Assistant (from User or Sub-agents).
-   `/workspace/state/outbox/`: Responses from the Assistant.
-   `/workspace/state/tasks.json`: The "Database" of active tasks/sub-agents.

### 2. The Daemon (The "Brain")
-   Runs inside a **detachable Tmux session** (`assistant-core`) in the container.
-   **Script**: `daemon.py`
-   **Loop**:
    1.  Blocks waiting for files in `inbox`.
    2.  Reads message.
    3.  Updates state (if it's a task update).
    4.  Runs OpenCode (via library call or subprocess) to generate response/decision.
    5.  Dispatches sub-agents (via `subprocess` in background) or writes reply to `outbox`.

### 3. The Client (`mekOS`)
-   Run on the host (via `docker exec`).
-   **Startup**:
    1.  Reads `tasks.json` and `outbox`.
    2.  Prints: "Welcome back. You have X unread updates."
    3.  Lists active tasks.
-   **Interaction**:
    -   User types -> Writes JSON to `inbox`.
    -   Polls `outbox` for reply.

## Detailed Component Plan

### A. Docker & Environment
-   **Tools**: Install `tmux` (for debugging) and `watchdog` (for file bus).
-   **Entrypoint**: Starts the `daemon.py` inside a tmux session.

### B. The Daemon (`workspace/daemon.py`)
-   **Class `MekOSDaemon`**:
    -   `watch_inbox()`: Uses `watchdog` to trigger on `.json` creation.
    -   `process_message()`:
        -   If from USER: Send to OpenCode.
        -   If from SUBAGENT (e.g. "Task Complete"): Update `task.json`, maybe notify User.
    -   `opencode_wrapper`: Intefaces with the LLM.

### C. The Tooling / Skills
-   **Task Manager**: Already started, needs to read/write `tasks.json`.
-   **Sub-agent Protocol**: Sub-agents (like `skill_creator`) must communicate by writing to `inbox` upon completion, not just printing to stdout.

### D. The Client (`workspace/mekOS`)
-   Python TUI (using `rich` or standard ANSI) to render the "Dashboard" view.
-   Handles the "REPL" loop by writing to filesystem.

## Why this is better than just Tmux?
-   **Structured Data**: You get a real dashboard ("4 unread items"), not just a text log.
-   **Async**: Sub-agents can run for hours and drop a file in `inbox` when done. The Daemon picks it up immediately.
-   **Extensible**: Any tool that can write a JSON file can interact with mekOS.

## Implementation Steps
1.  **Dockerfile**: Add `tmux`, `watchdog`.
2.  **Daemon**: Create the smart dispatcher script.
3.  **Client**: Update `mekOS` to be the dashboard.
4.  **Skills**: Update `task_manager` to support the file bus.
