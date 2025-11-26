# Terraform variables for Docker resources

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}