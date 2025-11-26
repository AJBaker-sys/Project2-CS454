# Terraform namespace for Kubernetes resources

resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo"
  }
}
