# mek-code

Self-hosted dockerized OpenCode instance with ollama/qwen3:4b-16k for M2 8GB RAM

## Architecture

Two Docker containers:
- **model** - Runs Ollama with qwen3:4b-16k model
- **assistant** - Runs OpenCode CLI (npm package)

They communicate via Docker's default bridge network. This is an all-in-Docker setup with CPU-only inference for complete isolation.

## Quick Start

### Option 1: One-Line Install (Recommended)

Run this single command to download and set up everything:

```bash
curl -fsSL https://raw.githubusercontent.com/mekarpeles/mek-code/main/install.sh | bash
```

This will:
- Clone the repository to `~/mek-code` (customize with `MEK_CODE_DIR` environment variable)
- Start both Docker containers
- Wait for Ollama to be ready
- Pull the qwen3:4b model
- Create the qwen3:4b-16k variant with extended context (16384 tokens)
- Verify the assistant container is running
- Display intermediate success messages at each step

### Option 2: Manual Install

1. Clone the repository:
```bash
git clone https://github.com/mekarpeles/mek-code.git
cd mek-code
```

2. Run the setup script:
```bash
./setup.sh
```

This will:
- Start both Docker containers
- Wait for Ollama to be ready
- Pull the qwen3:4b model
- Create the qwen3:4b-16k variant with extended context (16384 tokens)

## Usage

Access the assistant container:
```bash
docker compose exec assistant bash
```

Run OpenCode:
```bash
docker compose exec assistant opencode
```

Stop services:
```bash
docker compose down
```

## Configuration

OpenCode is configured via `config.json` which is copied into the assistant container at `/root/.config/opencode/config.json`.

The configuration uses:
- Provider: Ollama via OpenAI-compatible API
- Base URL: `http://model:11434/v1` (Docker service name)
- Model: qwen3:4b-16k with tool support

## Requirements

- Docker Desktop for Mac (Apple Silicon)
- At least 8GB RAM
- ~5-10GB free disk space for models

## Files

- `docker-compose.yml` - Service orchestration
- `Dockerfile` - Assistant container with Node.js 20.x and OpenCode
- `config.json` - OpenCode configuration
- `setup.sh` - Complete setup script
- `install.sh` - One-line installer script
- `workspace/` - Working directory mounted in assistant container
