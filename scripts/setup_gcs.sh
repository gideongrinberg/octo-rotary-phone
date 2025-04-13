#!/usr/bin/env bash
set -e

# Default values
REGION="us-central1"
DATA_BUCKET="tess-public-data"
RESULTS_BUCKET="tess-pipeline-results"

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
    --data-bucket)
      DATA_BUCKET="$2"
      shift 2
      ;;
    --results-bucket)
      RESULTS_BUCKET="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 --project-id PROJECT_ID [--region REGION] [--data-bucket DATA_BUCKET] [--results-bucket RESULTS_BUCKET]"
      exit 1
      ;;
  esac
done

# Check if project ID is provided
if [ -z "$PROJECT_ID" ]; then
  echo "Error: --project-id is required"
  echo "Usage: $0 --project-id PROJECT_ID [--region REGION] [--data-bucket DATA_BUCKET] [--results-bucket RESULTS_BUCKET]"
  exit 1
fi

# Create data bucket if it doesn't exist
echo "Ensuring data bucket ${DATA_BUCKET} exists..."
if ! gsutil ls gs://${DATA_BUCKET} &>/dev/null; then
  echo "Creating data bucket ${DATA_BUCKET}..."
  gsutil mb -p ${PROJECT_ID} -l ${REGION} gs://${DATA_BUCKET}
fi

# Create results bucket if it doesn't exist
echo "Ensuring results bucket ${RESULTS_BUCKET} exists..."
if ! gsutil ls gs://${RESULTS_BUCKET} &>/dev/null; then
  echo "Creating results bucket ${RESULTS_BUCKET}..."
  gsutil mb -p ${PROJECT_ID} -l ${REGION} gs://${RESULTS_BUCKET}
fi

echo "GCS buckets setup completed successfully!"

# Provide instructions for data migration
echo
echo "To migrate your TESS data from S3 to GCS, you can use the following command:"
echo "gsutil -m cp -r s3://stpubdata/tess/public/mast/ gs://${DATA_BUCKET}/"