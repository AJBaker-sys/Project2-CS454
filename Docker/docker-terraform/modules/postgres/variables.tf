# Terraform variables for postgres Docker module

variable "network_name" {
  type = string
}

variable "postgres_password" {
  type      = string
  sensitive = true
}