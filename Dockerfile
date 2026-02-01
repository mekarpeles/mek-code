FROM python:3.11-slim

# Install system dependencies including curl (needed for Node.js install)
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x (REQUIRED for OpenCode which is an npm package)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install OpenCode globally
RUN npm install -g opencode

# Create config directory
RUN mkdir -p /root/.config/opencode

# Copy config file
COPY config.json /root/.config/opencode/config.json

# Set working directory
WORKDIR /workspace

# Keep container running
CMD ["sleep", "infinity"]
