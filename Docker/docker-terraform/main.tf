resource "random_password" "postgres" {
  length           = 24
  special          = true
  override_special = "_%@"
}

module "network" {
  source = "./modules/network"
}

module "postgres" {
  source            = "./modules/postgres"
  network_name      = module.network.name
  postgres_password = random_password.postgres.result
}

module "backend" {
  source                = "./modules/backend"
  network_name          = module.network.name
  db_host               = module.postgres.container_name
  db_password           = random_password.postgres.result
  postgres_container_id = module.postgres.container_id
}

module "frontend" {
  source               = "./modules/frontend"
  network_name         = module.network.name
  backend_container_id = module.backend.container_id
}