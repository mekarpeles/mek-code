# Contributing to mek-code

Thank you for your interest in contributing to mek-code!

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/mekarpeles/mek-code.git
   cd mek-code
   ```

2. Start the development environment:
   ```bash
   ./start.sh
   # OR
   make up
   ```

## Making Changes

### Modifying the Agent Container

1. Edit the `Dockerfile` or related files
2. Rebuild the container:
   ```bash
   make build
   docker compose up -d agent
   ```

### Modifying the Docker Compose Configuration

1. Edit `docker-compose.yml`
2. Validate the configuration:
   ```bash
   docker compose config
   ```
3. Verify the configuration builds successfully:
   ```bash
   docker compose build --no-cache
   ```
4. Apply changes:
   ```bash
   docker compose up -d
   ```

### Testing Changes

1. Check service status:
   ```bash
   make status
   ```

2. View logs:
   ```bash
   make logs
   ```

3. Access the agent shell:
   ```bash
   make shell
   ```

## Code Style

- Follow existing patterns in configuration files
- Keep Docker images minimal and efficient
- Document any new features in the README

## Submitting Changes

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request with a clear description

## Questions?

Open an issue for any questions or concerns.
