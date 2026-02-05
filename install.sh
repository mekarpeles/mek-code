#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}mekOS Installer${NC}"

# 1. Environment Setup
echo "Checking environment files..."
for f in setup/env/*.default; do
    filename=$(basename "$f" .default)
    if [ ! -f "$filename" ]; then
        echo "Creating $filename from defaults..."
        cp "$f" "$filename"
    else
        echo "$filename exists, skipping."
    fi
done

# 2. Check Dependencies
if ! command -v docker >/dev/null 2>&1; then
    echo "Error: Docker not installed."
    exit 1
fi

# 3. Build & Start Container
echo -e "${GREEN}Building mekOS container...${NC}"
docker compose up -d --build

# 4. Setup Llama.cpp
echo -e "${GREEN}Configuring Llama.cpp (for M2 Mac)...${NC}"

LLAMA_DIR="setup/llama.cpp"
MODEL_URL="https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf"
MODEL_PATH="setup/models/qwen2.5-3b-instruct-q4_k_m.gguf"

# Clone and Build
if [ ! -d "$LLAMA_DIR" ]; then
    echo "Cloning llama.cpp..."
    git clone https://github.com/ggerganov/llama.cpp "$LLAMA_DIR"
    echo "Building llama.cpp (Metal enabled)..."
    cd "$LLAMA_DIR"
    make clean && make
    cd ../..
else
    echo "llama.cpp already exists. Skipping build."
fi

# Download Model
mkdir -p setup/models
if [ ! -f "$MODEL_PATH" ]; then
    echo "Downloading Qwen 2.5 3B Instruct (GGUF)..."
    curl -L "$MODEL_URL" -o "$MODEL_PATH"
else
    echo "Model already downloaded."
fi

# Create start script
cat > start_llm.sh <<EOF
#!/bin/bash
echo "Starting Llama.cpp Server..."
./setup/llama.cpp/llama-server \
    -m $MODEL_PATH \
    -c 16384 \
    --host 0.0.0.0 \
    --port 8080 \
    -ngl 99
EOF
chmod +x start_llm.sh

# 5. Finalize
echo -e "${GREEN}Installation Complete!${NC}"
echo ""
echo -e "1. Start the LLM Server: ${YELLOW}./start_llm.sh${NC}"
echo -e "2. In a new tab, Start mekos: ${YELLOW}docker exec -it assistant mekos${NC}"
