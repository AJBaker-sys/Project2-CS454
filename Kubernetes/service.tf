# Terraform service for Kubernetes resources

resource "kubernetes_service" "app" {
  metadata {
    name      = "demo-service"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }

  spec {
    selector = {
      app = "demo"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

