# Terraform main configuration for frontend Docker module

resource "docker_image" "frontend" {
  name = "nginx-prod:latest"

  build {
    context    = abspath("${path.root}/../configs")
    dockerfile = "Dockerfile.nginx"
    platform   = "linux/amd64"
  }
}

resource "docker_container" "frontend" {
  name  = "frontend"
  image = docker_image.frontend.image_id

  ports {
    internal = 80
    external = 8080
    protocol = "tcp"
  }

  networks_advanced {
    name = var.network_name
  }

  restart = "always"
}