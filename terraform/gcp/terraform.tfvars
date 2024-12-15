region      = "europe-west1"
environment = "dev"
project_id  = "nathael-dev"

subscriptions = {
  "test" : {
    "topic_name" : "server_creation_responses",
    "delivery_type" : "Pull",
    "ack_deadline_seconds" : "10",
    "retention_duration" : "604800s",
    "message_ordering" : false,
    "exactly_once_delivery" : false,
    "expiration_policy" : "31536000s",
    "push_endpoint" : "https://example.com/push"
  }
}