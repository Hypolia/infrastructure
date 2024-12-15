terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.12.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "6.12.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

resource "google_service_account" "service_account" {
  account_id   = "${var.service_name}-sa"
  display_name = "${var.service_display_name} Account"
  project      = var.project_id
}

resource "google_project_iam_member" "service_account_secret_access" {
  member  = "serviceAccount:${google_service_account.service_account.email}"
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
}

resource "google_project_iam_member" "dynamic_roles" {
  for_each = toset(var.service_account_roles)

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

// run only if var.generate_app_key is true
resource "random_string" "app_key" {
  length  = 20
  special = false
  count   = var.generate_app_key ? 1 : 0
}

module "app_key_secret" {
  source      = "../secrets"
  environment = var.environment
  project_id  = var.project_id
  region      = var.region
  secret_name = "${upper(var.service_name)}-APP-KEY"
  value       = random_string.app_key[0].result

  count = var.generate_app_key ? 1 : 0
}

// run only if var.migrations_job is true
resource "google_cloud_run_v2_job" "migrations-job" {
  location            = var.region
  name                = "${var.service_name}-migrations-job"
  project             = var.project_id
  count               = var.migrations_job ? 1 : 0
  deletion_protection = false

  labels = {
    environment = var.environment
  }

  template {
    template {
      service_account = google_service_account.service_account.email

      vpc_access {
        connector = var.vpc_connector
        egress    = "PRIVATE_RANGES_ONLY"
      }
      containers {
        image = var.image_uri

        ports {
          container_port = var.container_port
        }

        command = var.job_commands

        dynamic "env" {
          for_each = var.environment_variables

          content {
            name  = env.key
            value = env.value
          }
        }

        dynamic "env" {
          for_each = var.secrets

          content {
            name = env.key


            value_source {
              secret_key_ref {
                secret  = env.value
                version = "latest"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    google_service_account.service_account,
    google_project_iam_member.service_account_secret_access,
    module.app_key_secret,
  ]
}

resource "null_resource" "run_migrations" {
  count = var.migrations_job ? 1 : 0
  triggers = {
    image_uri = var.image_uri
  }

  provisioner "local-exec" {
    command = <<EOT
      gcloud run jobs execute ${google_cloud_run_v2_job.migrations-job[0].name} \
        --region ${var.region} \
        --project ${var.project_id} --wait
    EOT
  }

  depends_on = [
    google_cloud_run_v2_job.migrations-job
  ]
}

resource "google_cloud_run_service" "cloud_run" {
  location = var.region
  name     = var.service_name


  template {
    spec {
      service_account_name = google_service_account.service_account.email
      containers {
        image = var.image_uri
        ports {
          container_port = var.container_port
        }

        dynamic "env" {
          for_each = var.environment_variables

          content {
            name  = env.key
            value = env.value
          }
        }

        dynamic "env" {
          for_each = var.secrets

          content {
            name = env.key

            value_from {
              secret_key_ref {
                name = env.value
                key  = "latest"
              }
            }
          }
        }
      }
    }

    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = var.vpc_connector
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true


  depends_on = [
    google_service_account.service_account,
    google_project_iam_member.service_account_secret_access,
    module.app_key_secret,
    null_resource.run_migrations
  ]
}

resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.cloud_run.name
  location = google_cloud_run_service.cloud_run.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

module "cloud_run_url_secret" {
  source      = "../secrets"
  environment = var.environment
  project_id  = var.project_id
  region      = var.region
  secret_name = "${upper(var.service_name)}-URL-${upper(var.environment)}"
  value       = google_cloud_run_service.cloud_run.status[0].url
}

/*resource "google_cloudbuild_trigger" "deploy_cloud_run" {
  name = "${var.service_name}-deploy-trigger-${var.environment}"
  project = var.project_id
  description = "Trigger to deploy ${var.service_name} on Cloud Run"

  trigger_template {
    project_id = var.project_id
    repo_name = "hypolia"
    tag_name = ".*"
  }
}*/
