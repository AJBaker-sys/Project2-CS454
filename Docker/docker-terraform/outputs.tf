# Terraform outputs for Docker resources

output "frontend_url" {
  value = "http://localhost:8080"
}

output "postgres_password" {
  value     = random_password.postgres.result
  sensitive = true
}

output "visit_the_app" {
  value = "Open http://localhost:8080 → you will see visit counter increasing"
}