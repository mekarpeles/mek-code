#!/bin/bash
set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   mek-code Installer - One-Step OpenCode + Ollama Setup        ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker Desktop first.${NC}"
    echo "   Visit: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

# Check if git is installed
if ! command -v git >/dev/null 2>&1; then
    echo -e "${RED}❌ Git is not installed. Please install git first.${NC}"
    exit 1
fi

# Determine installation directory
INSTALL_DIR="${MEK_CODE_DIR:-$HOME/mek-code}"

# Check if directory already exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️  Directory $INSTALL_DIR already exists.${NC}"
    read -p "Do you want to remove it and reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing existing directory..."
        rm -rf "$INSTALL_DIR"
    else
        echo "Installation cancelled."
        exit 0
    fi
fi

# Clone the repository
echo -e "${GREEN}📥 Cloning mek-code repository...${NC}"
git clone https://github.com/mekarpeles/mek-code.git "$INSTALL_DIR"
echo -e "${GREEN}✅ Repository cloned successfully${NC}"
echo ""

# Change to installation directory
cd "$INSTALL_DIR"

# Run the setup script
echo -e "${GREEN}🚀 Running setup script...${NC}"
echo ""
./setup.sh

# Final success message
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   ✅ Installation Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📍 Installation location: $INSTALL_DIR${NC}"
echo ""
echo -e "${BLUE}Quick Start Commands:${NC}"
echo -e "  ${YELLOW}cd $INSTALL_DIR${NC}"
echo -e "  ${YELLOW}docker compose exec assistant bash${NC}    # Access assistant container"
echo -e "  ${YELLOW}docker compose exec assistant opencode${NC} # Run OpenCode"
echo ""
echo -e "${BLUE}Management Commands:${NC}"
echo -e "  ${YELLOW}docker compose down${NC}                   # Stop services"
echo -e "  ${YELLOW}docker compose up -d${NC}                  # Start services"
echo -e "  ${YELLOW}docker compose logs -f${NC}                # View logs"
echo ""
echo -e "${GREEN}🎉 Happy coding!${NC}"
