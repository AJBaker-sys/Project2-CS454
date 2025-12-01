# Terraform service for Kubernetes resources

# ClusterIP service exposing the project app internally
resource "kubernetes_service" "project2_service" {
  metadata {
    name      = "project2-service"
    namespace = kubernetes_namespace.project2_app.metadata[0].name
  }

  spec {
    selector = {
      app = "project2-app"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

