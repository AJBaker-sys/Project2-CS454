# Terraform main configuration for network Docker module

# create a shared Docker bridge network so containers can talk to each other
resource "docker_network" "app_network" {
  name     = "app_network"
  driver   = "bridge"
  internal = false
  attachable = true
}