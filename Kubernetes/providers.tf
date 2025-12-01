# Terraform providers for Kubernetes resources

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

provider "kubernetes" {
  # uses local kubeconfig by default; change path for CI or different contexts
  config_path = "~/.kube/config"
}
