# mekOS Implementation Plan: Tmux-based Persistence

## Goal
Implement a persistent, always-on agent using `tmux` inside the Docker container. `mekOS` effectively becomes a remote viewer/controller for this persistent session.

## User Review Required
-   **Architecture**: We will use `tmux` inside the container.
-   **Interaction**: `mekOS` will attach you to the live TUI of the running agent. You can detach with `Ctrl+b d` (or your tmux prefix), leaving the agent running.

## Proposed Changes

### 1. Docker & Environment
#### [MODIFY] [Dockerfile](file:///Users/internetarchive/Projects/mekos/Dockerfile)
-   Install `tmux`.
-   Update `CMD` to use a custom entrypoint script.

### 2. Persistent Session Management
#### [NEW] [workspace/entrypoint.sh](file:///Users/internetarchive/Projects/mekos/workspace/entrypoint.sh)
-   Check if tmux session "mekos" exists.
-   If not, start it: `tmux new-session -d -s mekos 'opencode'`.
-   Keep the container alive (e.g., `tail -f /dev/null` or wait on tmux).

### 3. The Host Interface
#### [MODIFY] [workspace/mekOS](file:///Users/internetarchive/Projects/mekos/workspace/mekOS)
-   Simplify significantly.
-   Command becomes: `docker exec -it assistant tmux attach -t mekos`.
-   Handle the case where the session might be dead (restart it if needed).

### 4. Agent Configuration
-   No changes needed to `AGENTS.md` specifically for this, but ensuring `opencode` runs in TUI mode is key.

## Verification Plan

### Manual Verification
-   Rebuild container.
-   Run `mekOS`.
-   Verify we see the OpenCode TUI.
-   Run a query.
-   Detach.
-   Run `mekOS` again.
-   Verify the previous query/state is still visible.
