# Terraform main configuration for postgres Docker module

resource "docker_volume" "postgres_data" {
  name = "postgres_data_prod"
}

resource "docker_container" "postgres" {
  name  = "postgres"
  image = "postgres:16-alpine"
  
  env = [
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=app_db",
    "PGDATA=/var/lib/postgresql/data/pgdata"
  ]

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = var.network_name
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U postgres -d app_db"]
    interval = "10s"
    timeout  = "5s"
    retries  = 10
  }
}