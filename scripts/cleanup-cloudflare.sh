#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

log_warn "=================================="
log_warn "WARNING: This will delete all Cloudflare resources for ${PROJECT_NAME}!"
log_warn "=================================="
log_warn "This will delete:"
log_warn "  - Cloudflare Worker: ${PROJECT_NAME}"
log_warn "  - Cloudflare Pages project: ${PAGES_PROJECT_NAME}"
log_warn "  - All associated secrets and configurations"
log_warn ""
read -p "Are you sure you want to continue? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    log_info "Cleanup cancelled"
    exit 0
fi

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    log_error "wrangler CLI is not installed"
    exit 1
fi

# Check if user is logged in to Cloudflare
log_info "Checking Cloudflare authentication..."
if ! wrangler whoami &> /dev/null; then
    log_error "Not logged in to Cloudflare. Please run: wrangler login"
    exit 1
fi

# Delete the Worker
log_info "Deleting Cloudflare Worker..."
if wrangler deployments list --name="${PROJECT_NAME}" &> /dev/null; then
    wrangler delete --name="${PROJECT_NAME}" --force || log_warn "Failed to delete worker, it may not exist"
    log_info "Cloudflare Worker deleted"
else
    log_warn "Worker '${PROJECT_NAME}' not found, skipping"
fi

# Delete the Pages project
log_info "Deleting Cloudflare Pages project..."
if wrangler pages project list 2>&1 | grep -q "${PAGES_PROJECT_NAME}"; then
    wrangler pages project delete "${PAGES_PROJECT_NAME}" --yes || log_warn "Failed to delete Pages project"
    log_info "Cloudflare Pages project deleted"
else
    log_warn "Pages project '${PAGES_PROJECT_NAME}' not found, skipping"
fi

# Note about secrets
log_warn "Note: Secrets are automatically removed when the worker is deleted"

log_info "=================================="
log_info "Cleanup completed successfully!"
log_info "=================================="
log_info "All ${PROJECT_NAME} resources have been removed from Cloudflare"
echo ""
log_info "You may need to manually remove any custom domains or DNS records"
log_info "configured in the Cloudflare dashboard."
