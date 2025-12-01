# Terraform configmap for Kubernetes resources

# simple configmap used by the project app; keep values small and static here
resource "kubernetes_config_map" "project2_config" {
  metadata {
    name      = "project2-config"
    namespace = kubernetes_namespace.project2_app.metadata[0].name
  }

  data = {
    MESSAGE = "Hello how are you!
  }
}
