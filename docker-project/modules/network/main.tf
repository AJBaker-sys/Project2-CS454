resource "docker_network" "private" {
  name = var.network_name
  driver = "bridge"
}