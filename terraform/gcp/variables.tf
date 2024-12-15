variable "project_id" {
  description = "The GCP project ID where the Pub/Sub topics will be created"
  type        = string
}

variable "region" {
  description = "The GCP region where the subnet will be created"
  type        = string
}

variable "environment" {
  description = "The environment in which the service is deployed"
  type        = string
}

variable "subnets" {
  default = [
    {
      name          = "subnet-1"
      ip_cidr_range = "10.10.10.0/24"
    }
  ]
}

variable "subscriptions" {
  description = "List of Pub/Sub subscriptions with their configurations."
  type = map(object({
    topic_name            = string
    delivery_type         = string
    ack_deadline_seconds  = string
    retention_duration    = string
    message_ordering      = bool
    exactly_once_delivery = bool
    expiration_policy     = string
    push_endpoint         = optional(string)
  }))
}