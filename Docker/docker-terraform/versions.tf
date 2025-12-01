# Terraform version constraints for Docker resources

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2" # pin exact version
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}