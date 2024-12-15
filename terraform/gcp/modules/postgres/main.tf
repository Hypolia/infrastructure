terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.12.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

resource "random_password" "postgres_password" {
  length  = 16
  special = true
}

resource "google_compute_global_address" "private_ip_address" {
  provider      = google
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  deletion_policy         = "ABANDON"
}

resource "google_sql_database_instance" "postgres_instance" {
  database_version = "POSTGRES_16"
  region           = var.region
  name             = "postgres-instance"
  root_password    = random_password.postgres_password.result

  settings {
    tier              = "db-custom-1-3840"
    availability_type = "ZONAL"
    edition           = "ENTERPRISE"

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = var.vpc_id
    }
  }

  deletion_protection = false
  depends_on          = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "postgres_db" {
  name     = "api"
  instance = google_sql_database_instance.postgres_instance.name
}

module "secret" {
  source = "../secrets"
  environment = var.environment
  project_id = var.project_id
  region = var.region
  value = random_password.postgres_password.result
  secret_name = "POSTGRES_PASSWORD"
}