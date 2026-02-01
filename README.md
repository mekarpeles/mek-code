# mek-code

Self-hosted dockerized OpenCode instance with Ollama/qwen3:4b-16k for M2 8GB RAM

## Overview

This project provides a fully containerized Docker Compose setup for OpenCode CLI with Ollama, optimized for M2 Mac development with 8GB RAM.

## Architecture

The setup consists of two separate Docker containers:

1. **`model`** - Configures and runs `ollama/qwen3:4b-16k`
2. **`agent`** - Configures and runs OpenCode CLI

These containers communicate via Docker's internal network. This architecture sacrifices GPU acceleration but keeps the system clean and isolated. All models and data are stored in Docker volumes for persistence.

## Prerequisites

- Docker Desktop for Mac (Apple Silicon version)
- Docker Compose (included with Docker Desktop)
- At least 8GB RAM available
- Approximately 5-10GB free disk space for models and containers

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mekarpeles/mek-code.git
   cd mek-code
   ```

2. **Start the services:**
   ```bash
   docker-compose up -d
   ```

   This will:
   - Start the Ollama service
   - Pull the `qwen3:4b-16k` model (first time only - may take 5-10 minutes)
   - Start the OpenCode agent container

3. **Check the status:**
   ```bash
   docker-compose ps
   ```

4. **Access the OpenCode agent:**
   ```bash
   docker-compose exec agent bash
   ```

   Inside the container, you can use OpenCode CLI commands with the configured Ollama backend.

## Usage

### Using OpenCode in the Agent Container

Once inside the agent container:

```bash
# The environment is pre-configured to use Ollama
# OLLAMA_API_BASE is set to http://model:11434
# OPENCODE_MODEL is set to qwen3:4b-16k

# Use OpenCode commands here
# Example (adjust based on actual OpenCode CLI usage):
# opencode <your-command>
```

### Testing Ollama Connection

You can verify the Ollama service is working:

```bash
# From the host machine
curl http://localhost:11434/api/tags

# From inside the agent container
curl http://model:11434/api/tags
```

### Viewing Logs

```bash
# View all logs
docker-compose logs

# View logs for a specific service
docker-compose logs model
docker-compose logs agent

# Follow logs in real-time
docker-compose logs -f
```

## Configuration

### Model Configuration

To use a different Ollama model, edit the `docker-compose.yml` file:

```yaml
environment:
  - OPENCODE_MODEL=your-model-name:tag
```

And update the `entrypoint.sh` to pull the correct model.

### Custom OpenCode Configuration

Place your custom configuration files in the `config/` directory. They will be mounted as read-only in the agent container at `/app/config/`.

## Management

### Stop the services:
```bash
docker-compose down
```

### Stop and remove volumes (clean slate):
```bash
docker-compose down -v
```

### Rebuild the agent container:
```bash
docker-compose build agent
docker-compose up -d agent
```

### Pull model updates:
```bash
docker-compose exec model ollama pull qwen3:4b-16k
```

## Volumes

The setup uses two Docker volumes for data persistence:

- `ollama_data` - Stores Ollama models and configuration
- `agent_data` - Stores workspace data for the OpenCode agent

## Network

Both containers are connected via the `mek-code-network` bridge network, allowing them to communicate using service names as hostnames.

## Resource Considerations for M2 Mac (8GB RAM)

- The `qwen3:4b-16k` model is optimized for systems with limited RAM
- Without GPU acceleration, inference will be CPU-based (slower but functional)
- Monitor Docker Desktop resource usage and adjust if needed in Docker Desktop settings

## Troubleshooting

### Model service unhealthy
```bash
docker-compose logs model
# Wait for Ollama to fully start, then:
docker-compose restart agent
```

### Agent can't connect to model
```bash
# Verify network connectivity
docker-compose exec agent ping model
docker-compose exec agent curl http://model:11434/api/tags
```

### Out of memory errors
- Reduce Docker Desktop memory allocation
- Ensure other applications aren't consuming too much RAM
- Consider using an even smaller model if needed

### Container won't start
```bash
# Check logs
docker-compose logs

# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Development

To modify the setup:

1. Edit the relevant files (`Dockerfile`, `docker-compose.yml`, etc.)
2. Rebuild: `docker-compose build`
3. Restart: `docker-compose up -d`

## License

See LICENSE file for details.
