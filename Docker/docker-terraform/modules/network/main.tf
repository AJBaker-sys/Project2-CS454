# Terraform main configuration for network Docker module

resource "docker_network" "app_network" {
  name     = "app_network"
  driver   = "bridge"
  internal = false
  attachable = true
}