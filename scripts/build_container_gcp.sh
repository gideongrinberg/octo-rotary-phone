#!/usr/bin/env bash
set -e

# Check if a project ID was provided
if [ $# -eq 0 ]; then
    echo "Error: Project ID is required"
    echo "Usage: $0 <project-id>"
    exit 1
fi

PROJECT_ID=$1
IMAGE_NAME="gcr.io/${PROJECT_ID}/tess-pipeline:latest"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$( cd "${SCRIPT_DIR}/.." && pwd )"

# Configure Docker to use Google Cloud credentials
echo "Configuring Docker authentication..."
gcloud auth configure-docker gcr.io --quiet

# Build the Docker image
echo "Building Docker image: ${IMAGE_NAME}"
docker build -t "${IMAGE_NAME}" "${ROOT_DIR}"

# Push the image to Google Container Registry
echo "Pushing image to Google Container Registry..."
docker push "${IMAGE_NAME}"

echo "Container build and push completed successfully!"