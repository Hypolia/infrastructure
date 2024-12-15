output "vpc_self_link" {
  value = google_compute_network.vpc_network.self_link
}

output "vpc_name" {
  value = google_compute_network.vpc_network.name
}

output "vpc_id" {
  value = google_compute_network.vpc_network.id
}

output "subnets" {
  value = google_compute_subnetwork.subnets
}

output "serverless_connector_id" {
  value = google_vpc_access_connector.serverless_connector.id
}