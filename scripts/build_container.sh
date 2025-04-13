#! /usr/bin/env bash
set -e

aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin 116453493772.dkr.ecr.us-east-1.amazonaws.com
sudo docker build -t gideongrinberg/pipeline .
sudo docker tag gideongrinberg/pipeline:latest 116453493772.dkr.ecr.us-east-1.amazonaws.com/gideongrinberg/pipeline:latest
sudo docker push 116453493772.dkr.ecr.us-east-1.amazonaws.com/gideongrinberg/pipeline:latest