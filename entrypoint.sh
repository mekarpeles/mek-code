#!/bin/bash
set -e

echo "================================================"
echo "Starting OpenCode Agent Container"
echo "================================================"

# Wait for Ollama to be ready
echo "Waiting for Ollama service to be ready..."
until curl -s http://model:11434/api/tags > /dev/null 2>&1; do
    echo "Ollama is unavailable - sleeping"
    sleep 2
done
echo "Ollama is ready!"

# Pull the qwen3:4b-16k model if not already present
echo "Checking if model qwen3:4b-16k is available..."
if ! curl -s http://model:11434/api/tags | grep -q "qwen3:4b-16k"; then
    echo "Pulling model qwen3:4b-16k (this may take a while)..."
    curl -X POST http://model:11434/api/pull -d '{"name": "qwen3:4b-16k"}' &
    PULL_PID=$!
    
    # Show progress
    while kill -0 $PULL_PID 2>/dev/null; do
        echo "Still pulling model..."
        sleep 10
    done
    wait $PULL_PID
    echo "Model qwen3:4b-16k pulled successfully!"
else
    echo "Model qwen3:4b-16k is already available."
fi

echo "================================================"
echo "OpenCode Agent is ready!"
echo "================================================"
echo ""
echo "To use OpenCode with Ollama:"
echo "  - Ollama API is available at: http://model:11434"
echo "  - Model: qwen3:4b-16k"
echo ""
echo "Example usage:"
echo "  export OLLAMA_API_BASE=http://model:11434"
echo "  # Use your OpenCode CLI commands here"
echo ""

# Execute the command passed to docker run
exec "$@"
