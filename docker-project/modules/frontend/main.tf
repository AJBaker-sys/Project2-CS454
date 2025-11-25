resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = true
}

resource "docker_container" "frontend" {
  name  = "frontend-nginx"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8080
  }

  volumes {
    host_path      = abspath("${path.module}/nginx.conf")
    container_path = "/etc/nginx/conf.d/default.conf"
  }

  networks_advanced {
    name = var.network_name
  }

  healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost/health"]
    interval = "10s"
    timeout  = "5s"
    retries  = 3
  }
}

resource "docker_image" "health" {
  name = "nginx:alpine"
}