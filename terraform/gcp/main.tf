terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.12.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "vpcaccess.googleapis.com",
    "identitytoolkit.googleapis.com",
    "secretmanager.googleapis.com",
    "apikeys.googleapis.com",
    "redis.googleapis.com",
    "servicenetworking.googleapis.com",
    "run.googleapis.com"

  ])
  service            = each.key
  project            = var.project_id
  disable_on_destroy = false
}

module "vpc" {
  source       = "./modules/vpc"
  network_name = "hypolia-vpc-dev"
  subnets      = var.subnets
  region       = var.region

  depends_on = [google_project_service.services]
}

module "postgres" {
  source      = "./modules/postgres"
  environment = var.environment
  project_id  = var.project_id
  region      = var.region
  vpc_id      = module.vpc.vpc_id
}

module "pubsub" {
  source = "./modules/pubsub"
  //environment = var.environment
  project_id = var.project_id
  labels = {
    env = var.environment
  }
  //region = var.region
  topics = [
    "server_creation_responses"
  ]
  subscriptions = var.subscriptions
  //subscriptions = {}
}

module "api_cloud_run" {
  source      = "./modules/cloud_run"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment

  image_uri = "europe-west1-docker.pkg.dev/nathael-dev/hypolia/api:0.1.1-rc1"

  service_display_name = "api"
  service_name         = "api"
  container_port       = 3333

  migrations_job = true
  job_commands = [
    "sh", "-c",
    "node ace migration:run --force"
  ]

  vpc_name         = module.vpc.vpc_id
  vpc_connector    = module.vpc.serverless_connector_id
  generate_app_key = true

  service_account_roles = []
  environment_variables = {
    "HOST"                   = "0.0.0.0"
    "DB_USER"                = "postgres"
    "DB_HOST"                = module.postgres.database_host
    "DB_DATABASE"            = "api"
    "LOG_LEVEL"              = "info"
    "DB_PORT"                = "5432"
    "NODE_ENV"               = "production"
    "KEYCLOAK_URL"           = "https://auth.bonnal.cloud"
    "KEYCLOAK_REALM"         = "hypolia"
    "KEYCLOAK_CLIENT_ID"     = "hypolia"
    "KEYCLOAK_CLIENT_SECRET" = "dadadada"
  }

  secrets = {
    "DB_PASSWORD" = "POSTGRES_PASSWORD-${upper(var.environment)}"
    "APP_KEY"     = "API-APP-KEY-${upper(var.environment)}"
  }

  //depends_on = [google_cloud_run_v2_job.migrations_job]
}

