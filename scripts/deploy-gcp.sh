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

# Check if project exists
log_info "Checking if project ${PROJECT_ID} exists..."
if ! gcloud projects describe ${PROJECT_ID} &> /dev/null; then
    log_warn "Project '${PROJECT_ID}' does not exist or you don't have permission to access it."
    echo ""
    echo "You have two options:"
    echo "  1. Create a new project with ID '${PROJECT_ID}'"
    echo "  2. Exit and use an existing project ID"
    echo ""
    read -p "Would you like to create the project '${PROJECT_ID}'? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Creating project ${PROJECT_ID}..."
        if gcloud projects create ${PROJECT_ID} --set-as-default; then
            log_info "Project created successfully!"
            # Wait a moment for the project to be fully initialized
            sleep 5
        else
            log_error "Failed to create project. You may need to:"
            log_error "  1. Choose a different project ID (it must be globally unique)"
            log_error "  2. Enable billing for your account"
            log_error "  3. Verify you have the resourcemanager.projects.create permission"
            echo ""
            echo "To create a project manually:"
            echo "  gcloud projects create ${PROJECT_ID}"
            echo ""
            echo "Or visit: https://console.cloud.google.com/projectcreate"
            exit 1
        fi
    else
        log_error "Deployment cancelled. Please provide an existing project ID."
        echo ""
        echo "To list your existing projects, run:"
        echo "  gcloud projects list"
        exit 1
    fi
else
    log_info "Project ${PROJECT_ID} found."
fi

# Set the project
log_info "Setting GCP project to ${PROJECT_ID}..."
gcloud config set project ${PROJECT_ID}

# Check if billing is enabled
log_info "Checking if billing is enabled..."
BILLING_ENABLED=$(gcloud billing projects describe ${PROJECT_ID} --format='value(billingEnabled)' 2>/dev/null || echo "false")

if [ "$BILLING_ENABLED" != "True" ]; then
    log_error "Billing is not enabled for project '${PROJECT_ID}'."
    echo ""
    echo "Cloud Run and other services require billing to be enabled."
    echo ""
    echo "To enable billing for this project:"
    echo "  1. Visit: https://console.cloud.google.com/billing/linkedaccount?project=${PROJECT_ID}"
    echo "  2. Select or create a billing account"
    echo "  3. Link it to your project"
    echo ""
    echo "Or use the gcloud command:"
    echo "  gcloud billing projects link ${PROJECT_ID} --billing-account=BILLING_ACCOUNT_ID"
    echo ""
    echo "To list your billing accounts, run:"
    echo "  gcloud billing accounts list"
    exit 1
fi

log_info "Billing is enabled."

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
