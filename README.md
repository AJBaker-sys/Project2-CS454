# Project2-CS454: Docker & Kubernetes Infrastructure

## Overview
This repository demonstrates containerization and orchestration using Docker and Kubernetes. It includes a backend application, infrastructure-as-code for Docker resources (via Terraform), and Kubernetes manifests for deploying services using k3d.

---

## Structure
- `Docker/`
  - `backend-app/`: Python backend app with Dockerfile and requirements.
  - `configs/`: Nginx Dockerfile and config.
  - `docker-terraform/`: Terraform scripts for Docker resources (backend, frontend, network, postgres).
- `Kubernetes/`
  - Terraform manifests for Kubernetes resources (namespace, deployment, service, configmap).

---

## Running the Docker Project

### 1. Build and Run Backend App
```bash
cd Docker/backend-app
# Build Docker image
docker build -t backend-app .
# Run container
docker run -d -p 5000:5000 backend-app
```

### 2. Nginx Reverse Proxy
```bash
cd Docker/configs
# Build Nginx image
docker build -t custom-nginx -f Dockerfile.nginx .
# Run Nginx container
docker run -d -p 80:80 custom-nginx
```

### 3. Terraform Docker Infrastructure
```bash
cd Docker/docker-terraform
terraform init
terraform apply
```

---

## Running the Kubernetes Project (with k3d)

### 1. Create k3d Cluster
```bash
k3d cluster create mycluster
```

### 2. Apply Terraform Manifests
```bash
cd Kubernetes
terraform init
terraform apply
```

### 3. Access Services
- Use `kubectl get svc -n <namespace>` to find service endpoints.
- Port-forward or expose as needed.

---

## Enhancements
### Docker Enhancement
- **Implemented:** Added Nginx reverse proxy for backend app to improve scalability and security.

### Kubernetes Enhancement
- **To Add:** *(Leave a note here for your enhancement, e.g., implement Horizontal Pod Autoscaler, add persistent storage, or integrate monitoring with Prometheus.)*

---

## Recommendations for Screenshots
- Docker containers running (`docker ps`)
- Backend app responding to requests
- Nginx proxy working
- Terraform apply output (Docker & Kubernetes)
- k3d cluster status (`k3d cluster list`)
- Kubernetes dashboard or `kubectl get all` output

---

## Reflection
See `Reflection.md` for a summary of lessons learned and future directions.
