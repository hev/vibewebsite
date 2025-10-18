#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SERVICE_NAME="vibesite"
REGION="${REGION:-us-central1}"
REPO_NAME="vibesite"
SECRET_NAME="loops-api-key"

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

# Check if required arguments are provided
if [ $# -lt 1 ]; then
    log_error "Usage: ./cleanup.sh <PROJECT_ID> [REGION]"
    log_error "Example: ./cleanup.sh my-gcp-project us-central1"
    exit 1
fi

PROJECT_ID=$1
if [ $# -ge 2 ]; then
    REGION=$2
fi

log_warn "=================================="
log_warn "WARNING: This will delete all vibesite resources from GCP!"
log_warn "=================================="
log_warn "Project ID: ${PROJECT_ID}"
log_warn "Region: ${REGION}"
log_warn "This will delete:"
log_warn "  - Cloud Run service: ${SERVICE_NAME}"
log_warn "  - Artifact Registry repository: ${REPO_NAME}"
log_warn "  - Secret Manager secret: ${SECRET_NAME}"
log_warn ""
read -p "Are you sure you want to continue? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    log_info "Cleanup cancelled"
    exit 0
fi

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    log_error "gcloud CLI is not installed"
    exit 1
fi

# Set the project
log_info "Setting GCP project to ${PROJECT_ID}..."
gcloud config set project ${PROJECT_ID}

# Delete Cloud Run service
log_info "Deleting Cloud Run service..."
if gcloud run services describe ${SERVICE_NAME} --region=${REGION} --project=${PROJECT_ID} &> /dev/null; then
    gcloud run services delete ${SERVICE_NAME} \
        --region=${REGION} \
        --platform=managed \
        --quiet \
        --project=${PROJECT_ID}
    log_info "Cloud Run service deleted"
else
    log_warn "Cloud Run service '${SERVICE_NAME}' not found, skipping"
fi

# Delete Artifact Registry repository
log_info "Deleting Artifact Registry repository..."
if gcloud artifacts repositories describe ${REPO_NAME} --location=${REGION} --project=${PROJECT_ID} &> /dev/null; then
    gcloud artifacts repositories delete ${REPO_NAME} \
        --location=${REGION} \
        --quiet \
        --project=${PROJECT_ID}
    log_info "Artifact Registry repository deleted"
else
    log_warn "Artifact Registry repository '${REPO_NAME}' not found, skipping"
fi

# Delete Secret Manager secret
log_info "Deleting Secret Manager secret..."
if gcloud secrets describe ${SECRET_NAME} --project=${PROJECT_ID} &> /dev/null; then
    gcloud secrets delete ${SECRET_NAME} \
        --quiet \
        --project=${PROJECT_ID}
    log_info "Secret Manager secret deleted"
else
    log_warn "Secret '${SECRET_NAME}' not found, skipping"
fi

log_info "=================================="
log_info "Cleanup completed successfully!"
log_info "=================================="
log_info "All vibesite resources have been removed from GCP project: ${PROJECT_ID}"
log_info ""
log_info "Note: The following APIs remain enabled (you can disable manually if needed):"
log_info "  - Cloud Run API"
log_info "  - Artifact Registry API"
log_info "  - Secret Manager API"
log_info "  - Cloud Build API"
