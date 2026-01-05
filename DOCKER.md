# Docker Setup for dbdiagram-oss-wrep

This guide explains how to run the dbdiagram-oss application using Docker and Docker Compose.

## Prerequisites

- Docker (version 20.10 or higher)
- Docker Compose (version 2.0 or higher)

## Quick Start

### Production Mode

Run the application in production mode with nginx:

```bash
# Build and start the production container
docker-compose up -d web

# Or build first if needed
docker-compose build web
docker-compose up -d web
```

The application will be available at: **http://localhost:8080**

### Development Mode

Run the application in development mode with hot-reload:

```bash
# Start the development container
docker-compose --profile dev up web-dev

# Or run in detached mode
docker-compose --profile dev up -d web-dev
```

The development server will be available at: **http://localhost:3210**

## Docker Compose Services

### `web` (Production)
- **Purpose**: Production-ready application with nginx
- **Dockerfile**: `web/Dockerfile.prod`
- **Port**: 8080 → 80
- **Features**: Multi-stage build, optimized size, nginx serving
- **Usage**: `docker-compose up web`

### `web-dev` (Development)
- **Purpose**: Development with hot-reload
- **Dockerfile**: `web/Dockerfile.dev`
- **Port**: 3210 → 3210
- **Features**: Live code updates, Quasar dev server
- **Usage**: `docker-compose --profile dev up web-dev`
- **Note**: Uses profile to avoid running by default

## Common Commands

```bash
# Build all services
docker-compose build

# Start production service
docker-compose up -d web

# Start development service
docker-compose --profile dev up web-dev

# View logs
docker-compose logs -f web

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Rebuild and restart
docker-compose up -d --build web

# Execute commands in running container
docker-compose exec web sh
```

## Environment Variables

Create a `.env` file in the web directory for environment-specific configuration:

```env
# Example .env file
NODE_ENV=production
VUE_APP_API_URL=http://localhost:3000
```

## Port Configuration

Default ports can be changed in `docker-compose.yml`:

- **Production**: Port 8080 (modify `ports: - "8080:80"`)
- **Development**: Port 3210 (modify `ports: - "3210:3210"`)

## Volumes

### Development Mode
- `./web:/app` - Source code mounted for hot-reload
- `/app/node_modules` - Node modules kept in container

## Networking

All services are connected via the `dbdiagram-network` bridge network, allowing inter-service communication if needed in the future (e.g., if an API service is added).

## Building Individual Dockerfiles

### Production Build
```bash
cd web
docker build -f Dockerfile.prod -t dbdiagram-oss:latest .
docker run -p 8080:80 dbdiagram-oss:latest
```

### Development Build
```bash
cd web
docker build -f Dockerfile.dev -t dbdiagram-oss:dev .
docker run -p 3210:3210 -v $(pwd):/app dbdiagram-oss:dev
```

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs web

# Check if port is already in use
netstat -tulpn | grep 8080
```

### Changes not reflecting in dev mode
```bash
# Ensure proper volume mounting
docker-compose --profile dev down
docker-compose --profile dev up web-dev
```

### Build fails
```bash
# Clean rebuild
docker-compose down
docker-compose build --no-cache web
docker-compose up web
```

### Permission issues
```bash
# Fix ownership (Linux/Mac)
sudo chown -R $USER:$USER ./web/node_modules
```

## Production Deployment

For production deployment, consider:

1. **SSL/TLS**: Add SSL certificates to nginx config
2. **Environment Variables**: Use proper `.env` files
3. **Resource Limits**: Add resource constraints in docker-compose.yml:
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '0.5'
         memory: 512M
   ```
4. **Logging**: Configure proper log drivers
5. **Health Checks**: Already included in Dockerfile.prod

## Future Enhancements

If the API service is added later, you can extend docker-compose.yml:

```yaml
services:
  api:
    build:
      context: ./api
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    networks:
      - dbdiagram-network
```

## Architecture

```
┌─────────────────────────────────────┐
│   Docker Compose                    │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  web (Production)             │ │
│  │  - Node.js Builder            │ │
│  │  - Nginx Server               │ │
│  │  - Port: 8080                 │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  web-dev (Development)        │ │
│  │  - Quasar Dev Server          │ │
│  │  - Hot Reload                 │ │
│  │  - Port: 3210                 │ │
│  │  - Profile: dev               │ │
│  └───────────────────────────────┘ │
│                                     │
│  Network: dbdiagram-network         │
└─────────────────────────────────────┘
```

## License

MIT - See LICENSE file for details
