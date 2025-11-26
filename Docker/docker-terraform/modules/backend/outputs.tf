# Terraform outputs for backend Docker module

output "container_id" {
    value = docker_container.backend.id
}