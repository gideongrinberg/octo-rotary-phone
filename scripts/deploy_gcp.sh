#!/usr/bin/env bash
set -e

# Default values
REGION="us-central1"
FUNCTION_NAME="process-tess-target"
RESULTS_BUCKET="tess-pipeline-results"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$( cd "${SCRIPT_DIR}/.." && pwd )"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --project-id)
      PROJECT_ID="$2"
      shift 2
      ;;
    --region)
      REGION="$2"
      shift 2
      ;;
    --bucket)
      RESULTS_BUCKET="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 --project-id PROJECT_ID [--region REGION] [--bucket BUCKET_NAME]"
      exit 1
      ;;
  esac
done

# Check if project ID is provided
if [ -z "$PROJECT_ID" ]; then
  echo "Error: --project-id is required"
  echo "Usage: $0 --project-id PROJECT_ID [--region REGION] [--bucket BUCKET_NAME]"
  exit 1
fi

# Image name for the container
IMAGE_NAME="gcr.io/${PROJECT_ID}/tess-pipeline:latest"

# Build and push the container image
echo "Building and pushing container image..."

# Configure Docker authentication
gcloud auth configure-docker gcr.io --quiet

# Build the Docker image
echo "Building Docker image: ${IMAGE_NAME}"
docker build -t "${IMAGE_NAME}" "${ROOT_DIR}"

# Push the image to Google Container Registry
echo "Pushing image to Google Container Registry..."
docker push "${IMAGE_NAME}"

# Deploy the Cloud Function
echo "Deploying Cloud Function ${FUNCTION_NAME}..."
gcloud functions deploy ${FUNCTION_NAME} \
  --gen2 \
  --region ${REGION} \
  --runtime python312 \
  --trigger-http \
  --entry-point src.main.tess_pipeline \
  --docker-repository gcr.io/${PROJECT_ID} \
  --set-env-vars RESULTS_BUCKET=${RESULTS_BUCKET} \
  --memory 4096MB \
  --timeout 600s \
  --project ${PROJECT_ID}

# Create the results bucket if it doesn't exist
echo "Ensuring results bucket ${RESULTS_BUCKET} exists..."
if ! gsutil ls gs://${RESULTS_BUCKET} &>/dev/null; then
  echo "Creating bucket ${RESULTS_BUCKET}..."
  gsutil mb -p ${PROJECT_ID} -l ${REGION} gs://${RESULTS_BUCKET}
fi

echo "Deployment completed successfully!"
echo "Function URL: $(gcloud functions describe ${FUNCTION_NAME} --region=${REGION} --project=${PROJECT_ID} --format='value(serviceConfig.uri)')"