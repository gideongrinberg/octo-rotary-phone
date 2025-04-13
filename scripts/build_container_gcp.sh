#!/usr/bin/env bash
set -e

gcloud auth configure-docker \
    us-east4-docker.pkg.dev
gcloud auth print-access-token | sudo docker login -u oauth2accesstoken --password-stdin us-east4-docker.pkg.dev

sudo docker build -t pipeline .
sudo docker tag pipeline us-east4-docker.pkg.dev/tess-pipeline/tess-pipeline/image:latest
sudo docker push us-east4-docker.pkg.dev/tess-pipeline/tess-pipeline/image:latest