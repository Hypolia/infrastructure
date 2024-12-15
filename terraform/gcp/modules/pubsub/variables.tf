variable "topics" {
  description = "A list of Pub/Sub topic names to create"
  type        = list(string)
}

variable "project_id" {
  description = "The GCP project ID where the Pub/Sub topics will be created"
  type        = string
}

variable "subscriptions" {
  description = "A map of Pub/Sub subscription configurations, with each key representing a subscription ID"
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
  default = {}
}


variable "labels" {
  description = "A map of labels to apply to the Pub/Sub topics"
  type        = map(string)
  default     = {}
}