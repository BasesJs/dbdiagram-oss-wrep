.PHONY: help build up down logs clean dev prod restart

# Default target
help:
	@echo "Available commands:"
	@echo "  make build     - Build production Docker image"
	@echo "  make up        - Start production container"
	@echo "  make prod      - Build and start production container"
	@echo "  make dev       - Start development container with hot-reload"
	@echo "  make down      - Stop all containers"
	@echo "  make logs      - View container logs"
	@echo "  make restart   - Restart production container"
	@echo "  make clean     - Stop containers and remove volumes"

# Build production image
build:
	docker compose build web

# Start production container
up:
	docker compose up -d web

# Build and start production
prod: build up
	@echo "Production server started at http://localhost:8880"

# Start development container
dev:
	docker compose --profile dev up web-dev

# Stop all containers
down:
	docker compose down

# View logs
logs:
	docker compose logs -f

# Restart production
restart:
	docker compose restart web

# Clean everything
clean:
	docker compose down -v
	docker system prune -f
