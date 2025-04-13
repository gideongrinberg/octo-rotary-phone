#! /usr/bin/env bash
set -e

if [ ! -d "./src/vendor/" ]; then
  echo "Downloading dependencies..."
  uv export --no-hashes --no-dev > ./src/requirements.txt
  pip wheel -r ./src/requirements.txt -w function/vendor/
else
  echo "Dependencies are already installed. Continuing..."
fi

echo > ./src/requirements.txt
echo "Creating requirements.txt..."
for whl in ./src/vendor/*.whl; do
  filename=$(basename "$whl")
  if [[ "$filename" == *function_framework* || "$filename" == *functions-framework* ]]; then
    continue
  fi

  echo "vendor/$(basename "$whl")" >> ./src/requirements.txt
done

echo "functions-framework" >> ./src/requirements.txt
echo "Deploying cloud function..."

gcloud functions deploy process_tess_target \
  --runtime=python312 \
  --region=us-east4 \
  --source=./src \
  --entry-point=handle_request \
  --set-build-env-vars GOOGLE_VENDOR_PIP_DEPENDENCIES=vendor \
  --trigger-http \
  --memory=4Gi \
  --cpu=4

rm ./src/requirements.txt