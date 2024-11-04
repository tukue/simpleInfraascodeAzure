#!/bin/bash

set -e

# Define variables
IMAGE_NAME="your-docker-username/your-app-name"
IMAGE_TAG=$(git rev-parse --short HEAD)  # Use git commit hash as tag
NAMESPACE="your-namespace"
DEPLOYMENT_NAME="your-app-deployment"
SERVICE_NAME="your-app-service"

# Check if namespace exists, if not create it
if ! kubectl get namespace ${NAMESPACE} &> /dev/null; then
    kubectl create namespace ${NAMESPACE}
fi

# Apply Kubernetes manifests
echo "Applying Kubernetes manifests..."

# Create or update the deployment
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${DEPLOYMENT_NAME}
  namespace: ${NAMESPACE}
spec:
  replicas: 3
  selector:
    matchLabels:
      app: your-app
  template:
    metadata:
      labels:
        app: your-app
    spec:
      containers:
      - name: your-app
        image: ${IMAGE_NAME}:${IMAGE_TAG}
        ports:
        - containerPort: 3000
EOF

# Create or update the service
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}
  namespace: ${NAMESPACE}
spec:
  selector:
    app: your-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 4000
  type: LoadBalancer
EOF

echo "Waiting for deployment to roll out..."
kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE}

echo "Deployment completed successfully."
