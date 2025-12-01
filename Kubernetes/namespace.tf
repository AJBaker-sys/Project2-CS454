# Terraform namespace for Kubernetes resources

# namespace used for the project application
resource "kubernetes_namespace" "project2_app" {
  metadata {
    name = "project2-app"
  }
}
