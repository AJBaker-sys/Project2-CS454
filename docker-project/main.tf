terraform {
  required_version = ">= 1.5.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

module "app_network" {
  source = "./modules/network"
}

module "postgres" {
  source = "./modules/database"

  network_name = module.app_network.network_name
  db_password  = var.db_password
}

module "backend" {
  source = "./modules/backend"

  network_name   = module.app_network.network_name
  db_host        = module.postgres.container_name
  db_password    = var.db_password
  depends_on     = [module.postgres]
}

module "frontend" {
  source = "./modules/frontend"

  network_name    = module.app_network.network_name
  backend_host    = module.backend.container_name
  depends_on      = [module.backend]
}

# Enhancement: Auto-add localhost entry + health-check based port exposure
resource "null_resource" "hosts_entry" {
  provisioner "local-exec" {
    command = "echo '127.0.0.1    localdemo.dev' | sudo tee -a /etc/hosts"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "sudo sed -i '' '/localdemo.dev/d' /etc/hosts"
  }
}

# Wait for frontend to be healthy before exposing
resource "null_resource" "wait_for_frontend" {
  depends_on = [module.frontend]

  provisioner "local-exec" {
    command = <<EOT
      until curl -s http://localhost:8080/health | grep -q "OK"; do
        echo "Waiting for frontend to be healthy..."
        sleep 2
      done
      echo "Frontend is healthy!"
    EOT
  }
}