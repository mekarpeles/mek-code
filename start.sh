#!/bin/bash
# Quick start script for mek-code

set -e

echo "================================================"
echo "mek-code - OpenCode with Ollama Setup"
echo "================================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running"
    echo "   Please start Docker Desktop and try again"
    exit 1
fi

echo "✓ Docker is running"

# Check if docker compose is available
if ! docker compose version > /dev/null 2>&1; then
    echo "❌ Error: Docker Compose is not available"
    echo "   Please install Docker Compose v2 and try again"
    exit 1
fi

echo "✓ Docker Compose is available"
echo ""

# Start the services
echo "Starting services..."
echo ""
docker compose up -d

echo ""
echo "================================================"
echo "Services started successfully!"
echo "================================================"
echo ""
echo "Waiting for Ollama to be ready..."

# Wait for Ollama to be healthy
max_wait=60
waited=0
while [ $waited -lt $max_wait ]; do
    if docker compose ps model | grep -q "healthy"; then
        echo "✓ Ollama is ready!"
        break
    fi
    echo "  Still waiting... ($waited/$max_wait seconds)"
    sleep 5
    waited=$((waited + 5))
done

if [ $waited -ge $max_wait ]; then
    echo "⚠ Warning: Ollama took longer than expected to start"
    echo "   You can check logs with: docker compose logs model"
fi

echo ""
echo "================================================"
echo "Setup Complete!"
echo "================================================"
echo ""
echo "The agent container will now pull the qwen3:4b-16k model."
echo "This may take 5-10 minutes on first run."
echo ""
echo "To monitor progress:"
echo "  docker compose logs -f agent"
echo ""
echo "To access the agent shell:"
echo "  docker compose exec agent bash"
echo ""
echo "To stop the services:"
echo "  docker compose down"
echo ""
echo "For more commands, see: make help"
echo ""
