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
if [ $# -lt 2 ]; then
    log_error "Usage: ./deploy.sh <PROJECT_ID> <LOOPS_API_KEY> [REGION]"
    log_error "Example: ./deploy.sh my-gcp-project ef7a1a572dd3bac57d94ea0f98d0022a us-central1"
    exit 1
fi

PROJECT_ID=$1
LOOPS_API_KEY=$2
if [ $# -ge 3 ]; then
    REGION=$3
fi

IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

log_info "Starting deployment to GCP Cloud Run..."
log_info "Project ID: ${PROJECT_ID}"
log_info "Region: ${REGION}"
log_info "Service Name: ${SERVICE_NAME}"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    log_error "gcloud CLI is not installed. Please install it from https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Set the project
log_info "Setting GCP project to ${PROJECT_ID}..."
gcloud config set project ${PROJECT_ID}

# Enable required APIs
log_info "Enabling required GCP APIs..."
gcloud services enable \
    run.googleapis.com \
    artifactregistry.googleapis.com \
    secretmanager.googleapis.com \
    cloudbuild.googleapis.com \
    --project=${PROJECT_ID}

log_info "Waiting for APIs to be fully enabled..."
sleep 10

# Create Artifact Registry repository if it doesn't exist
log_info "Creating Artifact Registry repository..."
if gcloud artifacts repositories describe ${REPO_NAME} --location=${REGION} --project=${PROJECT_ID} &> /dev/null; then
    log_warn "Artifact Registry repository '${REPO_NAME}' already exists, skipping creation"
else
    gcloud artifacts repositories create ${REPO_NAME} \
        --repository-format=docker \
        --location=${REGION} \
        --description="Docker repository for vibesite" \
        --project=${PROJECT_ID}
    log_info "Artifact Registry repository created"
fi

# Configure Docker to use gcloud as credential helper
log_info "Configuring Docker authentication..."
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

# Update image name to use Artifact Registry
IMAGE_NAME="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${SERVICE_NAME}:latest"

# Create or update secret in Secret Manager
log_info "Storing LOOPS_API_KEY in Secret Manager..."
if gcloud secrets describe loops-api-key --project=${PROJECT_ID} &> /dev/null; then
    log_warn "Secret 'loops-api-key' already exists, updating version..."
    echo -n "${LOOPS_API_KEY}" | gcloud secrets versions add loops-api-key \
        --data-file=- \
        --project=${PROJECT_ID}
else
    echo -n "${LOOPS_API_KEY}" | gcloud secrets create loops-api-key \
        --data-file=- \
        --replication-policy="automatic" \
        --project=${PROJECT_ID}
    log_info "Secret created"
fi

# Build the Docker image
log_info "Building Docker image..."
docker build -t ${IMAGE_NAME} .

# Push the image to Artifact Registry
log_info "Pushing image to Artifact Registry..."
docker push ${IMAGE_NAME}

# Deploy to Cloud Run
log_info "Deploying to Cloud Run..."
gcloud run deploy ${SERVICE_NAME} \
    --image=${IMAGE_NAME} \
    --platform=managed \
    --region=${REGION} \
    --allow-unauthenticated \
    --port=8080 \
    --memory=512Mi \
    --cpu=1 \
    --min-instances=0 \
    --max-instances=10 \
    --timeout=300 \
    --set-secrets=LOOPS_API_KEY=loops-api-key:latest \
    --set-env-vars=NODE_ENV=production,PORT=8080 \
    --project=${PROJECT_ID}

# Get the service URL
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} \
    --platform=managed \
    --region=${REGION} \
    --format='value(status.url)' \
    --project=${PROJECT_ID})

log_info "=================================="
log_info "Deployment completed successfully!"
log_info "=================================="
log_info "Service URL: ${SERVICE_URL}"
log_info ""
log_info "Your vibesite is now live at:"
echo -e "${GREEN}${SERVICE_URL}${NC}"
log_info ""
log_info "To view logs, run:"
echo "  gcloud run services logs read ${SERVICE_NAME} --region=${REGION} --project=${PROJECT_ID}"
log_info ""
log_info "To update the deployment, run this script again with the same arguments."
