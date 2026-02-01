FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install OpenCode CLI
# Using pip to install open-code-cli if it exists, otherwise clone from GitHub
RUN pip install --no-cache-dir \
    requests \
    openai \
    anthropic \
    && pip install --no-cache-dir open-code-cli || \
    (git clone https://github.com/modelcontextprotocol/open-code.git /tmp/open-code && \
     cd /tmp/open-code && \
     pip install -e . && \
     rm -rf /tmp/open-code/.git)

# Create workspace directory
RUN mkdir -p /workspace

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV OLLAMA_API_BASE=http://model:11434

# Copy entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["/bin/bash"]
