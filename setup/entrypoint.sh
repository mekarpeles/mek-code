#!/bin/bash
set -e

# Define session name
SESSION="mekos-core"

# Check if tmux is already running our session
if tmux has-session -t $SESSION 2>/dev/null; then
    echo "Session $SESSION already exists."
else
    echo "Starting new tmux session: $SESSION"
    # Start tmux session in detached mode running the daemon
    # We use 'python3 -u' to unbuffer output so we see logs
    tmux new-session -d -s $SESSION 'python3 -u /app/daemon.py'
fi

# Keep the container running (and maybe tail logs of the daemon?)
# Since daemon is in tmux, we can't easily tail its stdout here without redirecting to file.
# For simplicity, we just sleep infinity so docker stays up.
# Users debug by attaching to tmux.

echo "mekOS Container Started. Daemon running in tmux session '$SESSION'."
exec sleep infinity
