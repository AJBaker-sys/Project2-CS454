variable "network_name" {
  type = string
}

variable "postgres_password" {
  type      = string
  sensitive = true
}