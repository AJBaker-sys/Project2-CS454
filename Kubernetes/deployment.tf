# Terraform deployment for Kubernetes resources

# deploy a simple nginx pod for the project app
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "project2-app"
    namespace = kubernetes_namespace.project2_app.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "project2-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "project2-app"
        }
      }

      spec {
        container {
          name  = "project2-app"
          image = "nginx:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}
