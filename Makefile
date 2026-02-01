.PHONY: help up down restart logs build clean status shell shell-model

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

up: ## Start all services
	docker-compose up -d

down: ## Stop all services
	docker-compose down

restart: ## Restart all services
	docker-compose restart

logs: ## Show logs from all services
	docker-compose logs -f

build: ## Build/rebuild the agent container
	docker-compose build

clean: ## Stop services and remove volumes (clean slate)
	docker-compose down -v

status: ## Show status of all services
	docker-compose ps

shell: ## Open a shell in the agent container
	docker-compose exec agent bash

shell-model: ## Open a shell in the model container
	docker-compose exec model bash

pull-model: ## Manually pull the qwen3:4b-16k model
	docker-compose exec model ollama pull qwen3:4b-16k

test-ollama: ## Test Ollama connection from host
	curl http://localhost:11434/api/tags
