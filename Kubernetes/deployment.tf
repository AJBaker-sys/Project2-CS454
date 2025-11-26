resource "kubernetes_deployment" "app" {
  metadata {
    name      = "demo-app"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "demo"
        }
      }

      spec {
        container {
          name  = "demo"
          image = "nginx:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}
