resource "docker_image" "flask" {
  name = "flask-backend-prod:latest"
  
  build {
    context = abspath("${path.root}/../backend-app")
    dockerfile = "Dockerfile"
    platform = "linux/amd64"
  }
}

resource "docker_container" "backend" {
  name  = "backend"
  image = docker_image.flask.image_id

  env = [
    "DB_HOST=${var.db_host}",
    "DB_USER=postgres",
    "DB_PASSWORD=${var.db_password}",
    "DB_NAME=app_db"
  ]

  networks_advanced {
    name = var.network_name
  }

  healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost:5000/health"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }
}