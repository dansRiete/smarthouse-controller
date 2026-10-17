#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

IMAGE_REPO="localhost:5000/smarthouse-controller"
TAG="$(git rev-parse --short HEAD)-$(date +%Y%m%d%H%M%S)"

echo "=== 1. Building & testing inside Docker (${IMAGE_REPO}:${TAG}) ==="
docker build --progress=plain -t "${IMAGE_REPO}:${TAG}" -t "${IMAGE_REPO}:latest" .

echo "=== 2. Pushing image to local registry (${IMAGE_REPO}) ==="
docker push "${IMAGE_REPO}:${TAG}"
docker push "${IMAGE_REPO}:latest"

echo "=== 3. Rolling out deployment in Kubernetes (namespace: smarthouse) ==="
kubectl set image deployment/smarthouse-controller "smarthouse-controller=${IMAGE_REPO}:${TAG}" -n smarthouse
kubectl rollout status deployment/smarthouse-controller -n smarthouse --timeout=300s

echo "=== Redeploy complete: ${IMAGE_REPO}:${TAG} ==="
