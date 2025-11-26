output "container_id" {
    value = docker_container.postgres.id
}
output "container_name" {
    value = docker_container.postgres.name
}