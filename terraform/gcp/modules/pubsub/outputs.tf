output "topic_names" {
  description = "The names of the Pub/Sub topics created"
  value       = [for topic in google_pubsub_topic.pubsub_topics : topic.name]
}

output "topic_ids" {
  description = "The IDs of the Pub/Sub topics created"
  value       = [for topic in google_pubsub_topic.pubsub_topics : topic.id]
}

# output "topic_ids" {
#   description = "The IDs of the Pub/Sub topics created"
#   value = google_pubsub_topic.pubsub_topics[*].id
# }