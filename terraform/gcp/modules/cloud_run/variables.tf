variable "project_id" {
  description = "The GCP project ID where the Cloud Run service will be deployed"
  type        = string
}

variable "service_name" {
  description = "The name of the Cloud Run service"
  type        = string
}

variable "service_display_name" {
  description = "The display name of the Cloud Run service"
  type        = string
}

variable "service_account_roles" {
  description = "List of roles to be assigned to the service account"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "The GCP region where the Cloud Run service will be deployed"
  type        = string
}

variable "image_uri" {
  description = "The URI of the container image to deploy"
  type        = string
}

variable "container_port" {
  description = "The port on which the container listens"
  type        = number
  default     = 3333
}

variable "environment" {
  description = "The environment in which the service is deployed"
  type        = string
}

variable "vpc_name" {
  description = "The VPC network where the Cloud Run service will be deployed"
  type        = string
}

variable "secrets" {
  description = "List of secrets to be injected into the container"
  type        = map(string)
  default     = {}
}

variable "environment_variables" {
  description = "Environment variables for the Cloud Run service"
  type        = map(string)
  default     = {}
}

variable "vpc_connector" {
  description = "The VPC connector to use for the Cloud Run service"
  type        = string
}

variable "migrations_job" {
  description = "The name of the Cloud Run service that runs migrations"
  type        = bool
  default     = false
}

variable "job_commands" {
  description = "The commands to run in the migrations job"
  type        = list(string)
  default     = []
}

variable "generate_app_key" {
  description = "Whether to generate an application key"
  type        = bool
  default     = false
}