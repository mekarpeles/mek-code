#!/bin/bash
set -e  # Exit on any error

echo "🚀 Starting OpenCode + Ollama Docker setup..."

# Check Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Start services
echo "📦 Starting Docker containers..."
docker compose up -d

# Wait for model service to be healthy
echo "⏳ Waiting for Ollama to be ready..."
MAX_RETRIES=30
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if docker compose exec model ollama list >/dev/null 2>&1; then
        echo "✅ Ollama is ready"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "   Waiting... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "❌ Ollama failed to start"
    echo "   Check logs with: docker compose logs model"
    exit 1
fi

# Pull qwen3:4b model
echo "📥 Pulling qwen3:4b model (this may take a few minutes)..."
docker compose exec model ollama pull qwen3:4b

# Create 16k context variant
echo "🔧 Creating qwen3:4b-16k variant with extended context..."
docker compose exec model sh -c 'cat > /tmp/qwen3-16k.modelfile << EOF
FROM qwen3:4b
PARAMETER num_ctx 16384
EOF'
if ! docker compose exec model ollama list | grep -q "qwen3:4b-16k"; then
    echo "❌ Failed to create qwen3:4b-16k model"
    exit 1
fi

docker compose exec model ollama create qwen3:4b-16k -f /tmp/qwen3-16k.modelfile

echo "✅ Setup complete!"
echo ""
echo "🎉 OpenCode is ready to use!"
echo ""
echo "To access the agent container:"
echo "  docker compose exec agent bash"
echo ""
echo "To use OpenCode:"
echo "  docker compose exec agent opencode"
echo ""
echo "To stop services:"
echo "  docker compose down"
