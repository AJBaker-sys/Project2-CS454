# Terraform variables for backend Docker module

variable "network_name" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "postgres_container_id" {
  type = string
}