#! /usr/bin/env bash
set -e

if [ ! -d "./function/vendor/" ]; then
  echo "Downloading dependencies..."
  uv export --no-hashes --no-dev > ./function/requirements.txt
  pip wheel -r ./function/requirements.txt -w function/vendor/
else
  echo "Dependencies are already installed. Continuing..."
fi

echo > ./function/requirements.txt
echo "Creating requirements.txt..."
for whl in ./function/vendor/*.whl; do
  filename=$(basename "$whl")
  if [[ "$filename" == *function_framework* || "$filename" == *functions-framework* ]]; then
    continue
  fi

  echo "vendor/$(basename "$whl")" >> function/requirements.txt
done

echo "functions-framework" >> function/requirements.txt
echo "Deploying cloud function..."

gcloud functions deploy process_tess_target \
  --runtime=python312 \
  --region=us-east4 \
  --source=./function \
  --entry-point=handle_request \
  --set-build-env-vars GOOGLE_VENDOR_PIP_DEPENDENCIES=vendor \
  --trigger-http \
  --memory=4Gi \
  --cpu=4

rm ./function/requirements.txt