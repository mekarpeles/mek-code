FROM python:3.11-slim

# Install system dependencies including curl (needed for Node.js install)
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    tmux \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x (REQUIRED for OpenCode which is an npm package)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install python dependencies
RUN pip3 install watchdog --break-system-packages

# Install OpenCode globally
RUN npm install -g opencode-ai

# Create config directory
RUN mkdir -p /root/.config/opencode

# Copy config file
COPY setup/config.json /root/.config/opencode/config.json

# Set working directory
WORKDIR /app

# Copy application code
COPY setup/daemon.py /app/daemon.py
COPY setup/entrypoint.sh /app/entrypoint.sh
COPY AGENTS.md /app/AGENTS.md
COPY skills /app/skills

# Copy CLI tool
COPY setup/mekos-cli /app/bin/mekos
RUN chmod +x /app/bin/mekos /app/entrypoint.sh

# Set PATH
ENV PATH="/app/bin:/app:$PATH"
ENV PYTHONPATH="/app"

# Run entrypoint script
CMD ["/app/entrypoint.sh"]
