variable "project_id" {
  description = "The GCP project ID where the Cloud Run service will be deployed"
  type        = string
}

variable "region" {
  description = "The GCP region where the Cloud Run service will be deployed"
  type        = string
}

variable "environment" {
  description = "The environment in which the service is deployed"
  type        = string
}

variable "vpc_id" {
  description = "The VPC network where the Cloud Run service will be deployed"
  type        = string
}