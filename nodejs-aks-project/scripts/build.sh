#!/bin/bash

set -e

# Define variables
IMAGE_NAME="your-docker-username/your-app-name"
IMAGE_TAG=$(git rev-parse --short HEAD)  # Use git commit hash as tag

# Build the Docker image
echo "Building Docker image..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest

# Push the Docker image to the registry
echo "Pushing Docker image to registry..."
docker push ${IMAGE_NAME}:${IMAGE_TAG}
docker push ${IMAGE_NAME}:latest

echo "Build completed successfully."
