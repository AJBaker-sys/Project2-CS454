resource "kubernetes_config_map" "demo_config" {
  metadata {
    name      = "demo-config"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }

  data = {
    MESSAGE = "Hello from Terraform"
  }
}
