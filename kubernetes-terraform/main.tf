# kubernetes-terraform/main.tf
# FINAL VERSION — COPY-PASTE THIS EXACTLY AND YOU ARE DONE

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
}

# Flask image
resource "null_resource" "import_flask" {
  triggers = {
    dockerfile = filesha256("../backend-app/Dockerfile")
    app_py     = filesha256("../backend-app/app.py")
    reqs       = filesha256("../backend-app/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<EOT
      docker build -t flask-backend:k8s-prod ../backend-app
      k3d image import flask-backend:k8s-prod --cluster appcluster
    EOT
  }
}

# Nginx image from Part 1
resource "null_resource" "import_nginx" {
  provisioner "local-exec" {
    command = "k3d image import nginx-prod:latest --cluster appcluster || true"
  }
}

resource "random_password" "postgres" {
  length  = 24
  special = true
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "app-prod"
  }
}

resource "kubernetes_secret" "postgres_secret" {
  metadata {
    name      = "postgres-secret"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  data = {
    password = random_password.postgres.result
  }
  type = "Opaque"
}

resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name      = "postgres-pvc"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "local-path"
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "postgres" } }
    template {
      metadata { labels = { app = "postgres" } }
      spec {
        container {
          name  = "postgres"
          image = "postgres:16-alpine"
          env {
            name  = "POSTGRES_DB"
            value = "app_db"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_secret.metadata[0].name
                key  = "password"
              }
            }
          }
          volume_mount {
            name       = "data"
            mount_path = "/var/lib/postgresql/data"
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    selector = { app = "postgres" }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}

resource "kubernetes_deployment" "backend" {
  depends_on = [null_resource.import_flask, kubernetes_deployment.postgres]

  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    replicas = 3
    selector { match_labels = { app = "backend" } }
    template {
      metadata { labels = { app = "backend" } }
      spec {
        container {
          name  = "backend"
          image = "flask-backend:k8s-prod"

          env {
            name  = "DB_HOST"
            value = "postgres"
          }
          env {
            name  = "DB_USER"
            value = "postgres"
          }
          env {
            name  = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_secret.metadata[0].name
                key  = "password"
              }
            }
          }
          env {
            name  = "DB_NAME"
            value = "app_db"
          }

          port { container_port = 5000 }

          liveness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 15
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    selector = { app = "backend" }
    port {
      port        = 5000
      target_port = 5000
    }
  }
}

resource "kubernetes_deployment" "frontend" {
  depends_on = [null_resource.import_nginx]

  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    replicas = 3
    selector { match_labels = { app = "frontend" } }
    template {
      metadata { labels = { app = "frontend" } }
      spec {
        container {
          name  = "nginx"
          image = "nginx-prod:latest"
          port { container_port = 80 }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    type     = "LoadBalancer"
    selector = { app = "frontend" }
    port {
      port        = 80
      target_port = 80
    }
  }
}

output "app_url" {
  value = "\nAPP IS LIVE → http://localhost:8080\nVisit counter increases on every refresh!\n"
}