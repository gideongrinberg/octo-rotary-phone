# TESS Pipeline - Google Cloud Platform

This project processes TESS (Transiting Exoplanet Survey Satellite) data using Google Cloud Platform services.

## Migration from AWS Lambda to GCP Cloud Functions

This codebase has been migrated from AWS Lambda to Google Cloud Functions. Key changes include:

1. Replaced AWS S3 with Google Cloud Storage
2. Renamed pipeline.py to main.py with Cloud Functions HTTP handler
3. Updated the Dockerfile for GCP compatibility
4. Created new deployment scripts for GCP

## Setup Instructions

### Prerequisites

1. [Install Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
2. [Install Docker](https://docs.docker.com/get-docker/)
3. Authenticate with Google Cloud:
   ```
   gcloud auth login
   ```

### Setting Up GCP Resources

1. Set up GCS buckets:
   ```
   bash scripts/setup_gcs.sh --project-id YOUR_PROJECT_ID
   ```

2. Deploy the Cloud Function (includes building and pushing the container):
   ```
   bash scripts/deploy_gcp.sh --project-id YOUR_PROJECT_ID
   ```

   Optional parameters:
   - `--region REGION` - Google Cloud region (default: us-central1)
   - `--bucket BUCKET_NAME` - Custom bucket name for results (default: tess-pipeline-results)

## Using the Pipeline

The Cloud Function accepts HTTP POST requests with the following JSON structure:

```json
{
   "ID": 33398702,
   "ra": 344.420449437894,
   "dec": -8.06747255937119,
   "sector": 42,
   "camera": 1,
   "ccd": 1
}
```

Results are stored in Google Cloud Storage in the `tess-pipeline-results` bucket (or a custom bucket if specified during deployment).