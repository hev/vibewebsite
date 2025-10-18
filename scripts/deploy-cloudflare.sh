#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="vibesite"
PAGES_PROJECT_NAME="vibesite"

# Function to print colored messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    log_error "wrangler CLI is not installed. Installing via npm..."
    npm install -g wrangler
fi

log_info "Starting deployment to Cloudflare..."
log_info "Project: ${PROJECT_NAME}"

# Check if user is logged in to Cloudflare
log_step "Checking Cloudflare authentication..."
if ! wrangler whoami &> /dev/null; then
    log_warn "Not logged in to Cloudflare. Please authenticate..."
    wrangler login
fi

log_info "Authenticated successfully!"

# Build the project
log_step "Building the application..."
npm run build

# Build the worker
log_step "Building the Cloudflare Worker..."
npm run build:worker

# Deploy to Cloudflare Pages (for static assets)
log_step "Deploying static assets to Cloudflare Pages..."
log_info "Creating/updating Pages project: ${PAGES_PROJECT_NAME}"

# Check if Pages project exists
if wrangler pages project list 2>&1 | grep -q "${PAGES_PROJECT_NAME}"; then
    log_info "Pages project '${PAGES_PROJECT_NAME}' exists, deploying update..."
else
    log_info "Creating new Pages project '${PAGES_PROJECT_NAME}'..."
fi

# Deploy to Pages
wrangler pages deploy dist/client \
    --project-name="${PAGES_PROJECT_NAME}" \
    --branch=main

# Get the Pages URL
PAGES_URL=$(wrangler pages project list --json 2>/dev/null | grep -o "https://${PAGES_PROJECT_NAME}[^\"]*" | head -1 || echo "")

# Set up the LOOPS_API_KEY secret
log_step "Setting up secrets..."
log_warn "You need to set the LOOPS_API_KEY secret for your worker."
echo ""
read -p "Do you want to set the LOOPS_API_KEY now? (y/n): " -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Please enter your Loops API key:"
    wrangler secret put LOOPS_API_KEY
    log_info "Secret set successfully!"
else
    log_warn "Skipping secret setup. Remember to run: wrangler secret put LOOPS_API_KEY"
fi

# Deploy the Worker
log_step "Deploying Cloudflare Worker..."
wrangler deploy

# Get the Worker URL
WORKER_URL=$(wrangler deployments list --name="${PROJECT_NAME}" 2>/dev/null | grep -o "https://[^ ]*workers.dev" | head -1 || echo "")

log_info "=================================="
log_info "Deployment completed successfully!"
log_info "=================================="

if [ -n "$PAGES_URL" ]; then
    log_info "Cloudflare Pages URL: ${PAGES_URL}"
fi

if [ -n "$WORKER_URL" ]; then
    log_info "Cloudflare Worker URL: ${WORKER_URL}"
fi

echo ""
log_info "Your vibesite is now live on Cloudflare!"
echo ""
log_info "Next steps:"
echo "  1. Configure your custom domain in the Cloudflare dashboard (if needed)"
echo "  2. Set up your LOOPS_API_KEY secret if you haven't already:"
echo "     wrangler secret put LOOPS_API_KEY"
echo ""
log_info "To view logs, run:"
echo "  wrangler tail"
echo ""
log_info "To update the deployment, run this script again."
