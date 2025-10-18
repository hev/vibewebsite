# Vibe Check - Project Context

## Overview
A Halloween-themed TypeScript web application showcasing intuitive LLM evaluation syntax with email collection functionality.

## Tech Stack
- **Frontend**: React 18 + TypeScript + Vite
- **Backend**: Express.js + TypeScript (Node.js) OR Cloudflare Workers
- **Email Service**: Loops.so API
- **Styling**: Vanilla CSS with JetBrains Mono font
- **Build Tool**: Vite (client), tsc (server/worker)
- **Deployment**: GCP Cloud Run OR Cloudflare Workers + Pages

## Project Structure
```
vibesite/
├── src/
│   ├── client/              # React frontend (port 8080 in dev)
│   │   ├── components/
│   │   │   ├── Header.tsx   # Email signup form with Loops integration
│   │   │   ├── CTASection.tsx
│   │   │   ├── CodeDemo.tsx # Displays YAML syntax examples
│   │   │   └── Footer.tsx
│   │   ├── App.tsx
│   │   ├── main.tsx
│   │   └── index.css        # All styling (animations, responsive, spooky theme)
│   ├── server/              # Express API (port 3001) - for Node.js deployment
│   │   └── index.ts         # POST /api/subscribe endpoint
│   └── worker/              # Cloudflare Worker - for CF deployment
│       └── index.ts         # Worker fetch handler
├── scripts/                 # Deployment scripts
│   ├── deploy-gcp.sh        # Deploy to Google Cloud Run
│   ├── cleanup-gcp.sh       # Clean up GCP resources
│   ├── deploy-cloudflare.sh # Deploy to Cloudflare Workers + Pages
│   └── cleanup-cloudflare.sh # Clean up Cloudflare resources
├── index.html
├── package.json
├── vite.config.ts           # Proxies /api to backend
├── wrangler.toml            # Cloudflare Workers config
└── tsconfig files
```

## Key Features
1. **Email Collection**: Form in header submits to backend → Loops API
2. **Spooky Theme**: Halloween-inspired dark theme with orange/purple gradients
3. **YAML Display**: Shows LLM eval syntax with specific format:
   - Model: `emini-2.5-flash-lite-preview-09-2025`
   - Checks: `or`, `not_match`, `min_tokens`, `max_tokens`, `semantic`, `llm_judge`
4. **Responsive Design**: Mobile-friendly with breakpoints
5. **Animations**: Fade-in, glow effects, floating emojis

## Development Commands
```bash
npm install          # Install dependencies
npm run dev          # Start both client (8080) and server (3001)
npm run dev:client   # Client only
npm run dev:server   # Server only (Express)
npm run dev:worker   # Worker only (Cloudflare)
npm run build        # Build for production (client + server)
npm run build:worker # Build Cloudflare Worker
npm start            # Run production build (Node.js)
```

## Deployment Options

### Option 1: GCP Cloud Run (Docker)
```bash
# Using deployment script
./scripts/deploy-gcp.sh <PROJECT_ID> <LOOPS_API_KEY> [REGION]

# Or manually with Docker
docker build -t vibesite .
docker run -p 3001:3001 -e LOOPS_API_KEY=xxx vibesite
docker-compose up -d                     # Start with compose
docker-compose down                      # Stop with compose

# Cleanup
./scripts/cleanup-gcp.sh <PROJECT_ID> [REGION]
```

### Option 2: Cloudflare Workers + Pages
```bash
# Deploy to Cloudflare (Workers + Pages)
npm run deploy:cloudflare
# or
./scripts/deploy-cloudflare.sh

# Cleanup
npm run cleanup:cloudflare
# or
./scripts/cleanup-cloudflare.sh

# Development with Cloudflare
npm run dev:worker  # Runs wrangler dev

# Set secrets
wrangler secret put LOOPS_API_KEY
```

## Environment Variables

### For Node.js/Docker (`.env`)
- `LOOPS_API_KEY`: Your Loops.so API key
- `PORT`: Server port (default: 3001)

### For Cloudflare Workers
Set via wrangler CLI:
- `LOOPS_API_KEY`: Set with `wrangler secret put LOOPS_API_KEY`

## Important Notes
- **Security**: API key is server-side only, never exposed to client
- **Styling**: All CSS in one file, uses CSS custom animations
- **API**: Backend proxies Loops API to keep credentials secure
- **Theme**: Spooky Halloween aesthetic with green checkmarks, orange/purple accents
- **Font**: JetBrains Mono for code-like appearance

## Code Patterns
- React components use functional style with hooks
- TypeScript strict mode enabled
- Form handling with loading/success/error states
- Fetch API for backend communication
- No external UI libraries (vanilla React + CSS)

## Original File
- `vibe_check_logo.html`: Original static HTML (preserved for reference)
