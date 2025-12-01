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

### 3. Terraform Docker Infrastructure
```bash
cd Docker/docker-terraform
terraform init
terraform apply

When done run:
terraform destroy
```

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
### Docker Terraform Project — Enhancement(s)

- **Nginx reverse-proxy frontend:** A custom Nginx image/config in `Docker/configs/` acts as the frontend and reverse-proxy to the backend. The frontend is exposed on `localhost:8080` via the `docker-terraform/modules/frontend` module (meets the "expose frontend on localhost:8080" requirement).

- **Healthchecks for containers:** Backend and Nginx images include `HEALTHCHECK` instructions and the Terraform Docker modules declare container `healthcheck` blocks (`Docker/backend-app/Dockerfile`, `Docker/configs/Dockerfile.nginx`, and `docker-terraform/modules/*`). This improves readiness detection for local orchestration.

- **Secrets & passwords handled safely:** Postgres credentials are generated with the `random_password` resource and passed to modules as variables instead of being hard-coded (`docker-terraform/main.tf` and `modules/postgres`). This satisfies the requirement to pass secrets via variables/TFVARS (you can also supply `.tfvars`).

- **Module per component & custom network:** The Docker Terraform project is modularized with `network`, `postgres`, `backend`, and `frontend` modules under `Docker/docker-terraform/modules/`, and a custom Docker network is created and used (`modules/network`).

### Kubernetes Terraform Project — Enhancement(s)

- **ConfigMap for configuration:** A `kubernetes_config_map` in `Kubernetes/configmap.tf` provides externalized configuration (MESSAGE) that can be injected into pods, improving configuration management and allowing runtime changes without rebuilding images.

- **Complete app stack (Namespace / Deployment / Service):** The project creates a Namespace, Deployment, and Service (`Kubernetes/namespace.tf`, `Kubernetes/deployment.tf`, `Kubernetes/service.tf`) for `project2-app`, meeting the required Kubernetes resources. The provider is configured to use a local kubeconfig for k3d/kind (`Kubernetes/providers.tf`).

The ConfigMap is the explicit enhancement for the Kubernetes project (beyond the baseline Namespace/Deployment/Service), making configuration flexible and separate from code.

If you'd like, I can also add short README snippets showing the exact files and commands to inspect or change each enhancement (for example: `kubectl -n project2-app get configmap project2-config -o yaml`).

---

## Reflection
See `Reflection.md` for a summary of lessons learned and future directions.


## Screenshots
![alt text](image.png)
![alt text](image-1.png)
![alt text](image-2.png)
![alt text](image-3.png)
![alt text](image-4.png)
![alt text](image-5.png)
