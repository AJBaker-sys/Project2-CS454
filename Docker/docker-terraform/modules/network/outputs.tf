# Terraform outputs for network Docker module

output "name" {
  value = docker_network.app_network.name
}