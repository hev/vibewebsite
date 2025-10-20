# vibe check

Intuitive and fast LLM evals - Halloween Edition 🎃👻

A TypeScript application showcasing LLM evaluation syntax with email collection via Loops.

## Features

- 🎨 Modern React + TypeScript frontend with Vite
- 🚀 Express backend API
- 📧 Email collection integrated with Loops.so
- 🎃 Halloween-themed spooky design
- ⚡ Fast development with hot-reload

## Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn
- Loops API key (get one at https://loops.so)

### Installation

1. Clone the repository and install dependencies:

```bash
npm install
```

2. Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

3. Create a `.env` file in the root directory with your API keys:

```
# Email Service (Required)
LOOPS_API_KEY=your_loops_api_key_here

# PostHog Analytics (Optional)
VITE_POSTHOG_KEY=your_posthog_key_here
VITE_POSTHOG_HOST=https://us.i.posthog.com

# Environment Configuration
VITE_PRODUCTION=false

# Server Configuration
PORT=8081

# Client Configuration (Vite)
VITE_CLIENT_PORT=8080
```

**Environment Variables:**
- `LOOPS_API_KEY` (required): Your Loops API key for email subscriptions
- `VITE_POSTHOG_KEY` (optional): PostHog project API key for analytics
- `VITE_POSTHOG_HOST` (optional): PostHog host URL (default: https://us.i.posthog.com)
- `VITE_PRODUCTION` (optional): Set to "true" for production deployments, adds production property to PostHog events (default: false)
- `PORT` (optional): Server port (default: 8081)
- `VITE_CLIENT_PORT` (optional): Client development port (default: 8080)

### Development

Run both the client and server in development mode:

```bash
npm run dev
```

This will start:
- Vite dev server on `http://localhost:8080`
- Express API server on `http://localhost:3001`

### Production Build

Build the application:

```bash
npm run build
```

Start the production server:

```bash
npm start
```

## Deployment

This application supports two deployment options:

### Option 1: GCP Cloud Run (Docker)

Deploy to Google Cloud Platform using the automated script:

```bash
# Deploy to GCP Cloud Run
./scripts/deploy-gcp.sh <PROJECT_ID> <LOOPS_API_KEY> [REGION]

# Example
./scripts/deploy-gcp.sh my-project-123 your_api_key us-central1

# Cleanup resources
./scripts/cleanup-gcp.sh <PROJECT_ID> [REGION]
```

Or use npm scripts:

```bash
npm run deploy:gcp
npm run cleanup:gcp
```

**Manual Docker Deployment:**

```bash
# Build the Docker image
docker build -t vibesite .

# Run the container
docker run -p 3001:3001 \
  -e LOOPS_API_KEY=your_loops_api_key_here \
  vibesite

# Or use Docker Compose
docker-compose up -d
docker-compose logs -f
docker-compose down
```

### Option 2: Cloudflare Workers + Pages

Deploy to Cloudflare's edge network:

```bash
# Install dependencies first
npm install

# Deploy to Cloudflare
./scripts/deploy-cloudflare.sh

# Or use npm script
npm run deploy:cloudflare

# Set your LOOPS_API_KEY secret (if not done during deployment)
wrangler secret put LOOPS_API_KEY

# Cleanup resources
./scripts/cleanup-cloudflare.sh
# Or
npm run cleanup:cloudflare
```

**Development with Cloudflare:**

```bash
# Test worker locally
npm run dev:worker

# Build worker
npm run build:worker
```

### Environment Variables

**For Node.js/Docker (`.env` file):**
- `LOOPS_API_KEY`: Your Loops.so API key (required)
- `PORT`: Server port (default: 3001)
- `NODE_ENV`: Environment (default: production in Docker)

**For Cloudflare Workers:**
- Set secrets via: `wrangler secret put LOOPS_API_KEY`
- Configure in `wrangler.toml` for other variables

## Project Structure

```
vibesite/
├── src/
│   ├── client/          # React frontend
│   │   ├── components/  # React components
│   │   ├── App.tsx     # Main app component
│   │   ├── main.tsx    # Entry point
│   │   └── index.css   # Global styles
│   ├── server/          # Express backend (for Node.js deployment)
│   │   └── index.ts    # API server
│   └── worker/          # Cloudflare Worker (for CF deployment)
│       └── index.ts    # Worker fetch handler
├── scripts/            # Deployment scripts
│   ├── deploy-gcp.sh   # Deploy to GCP Cloud Run
│   ├── cleanup-gcp.sh  # Cleanup GCP resources
│   ├── deploy-cloudflare.sh  # Deploy to Cloudflare
│   └── cleanup-cloudflare.sh # Cleanup Cloudflare resources
├── index.html          # HTML template
├── package.json        # Dependencies
├── tsconfig.json       # TypeScript config (client)
├── tsconfig.server.json # TypeScript config (server)
├── tsconfig.worker.json # TypeScript config (worker)
├── wrangler.toml       # Cloudflare Workers config
└── vite.config.ts      # Vite configuration
```

## API Endpoints

### POST /api/subscribe

Subscribe an email to the Loops mailing list.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Successfully subscribed!"
}
```

## Technologies

- **Frontend:** React, TypeScript, Vite
- **Backend:** Express, Node.js
- **Email Service:** Loops.so
- **Styling:** Vanilla CSS with JetBrains Mono font

## License

MIT
