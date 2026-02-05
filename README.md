# mekOS

Your personalized, always-on life assistant.

## Architecture
- **Daemon**: Runs permanently in a tmux session within Docker.
- **Operator**: Interacts via `mekos`, a dashboard CLI.
- **Skills**: Sub-agents (tools) that perform tasks asynchronously.
- **Context**: Persistent memory files.

## Installation

1.  **Run the installer**:
    ```bash
    ./install.sh
    ```
    This will:
    -   Setup environment files (`mekos.env`, `user.env`).
    -   Build the Docker container.
    -   Start the daemon.

2.  **Start the Dashboard**:
    ```bash
    docker exec -it assistant mekos
    ```

## Directory Structure
-   `setup/`: Installation scripts, Docker config, and default envs.
-   `mailbox/`: Inbox/Outbox for agent communication.
-   `tasks/`: JSON state for active/completed tasks.
-   `skills/`: Python scripts defining agent capabilities.
-   `context/`: User personal context (gitignored).
-   `memory/`: Logs and long-term memory (gitignored).
