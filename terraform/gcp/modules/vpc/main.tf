resource "google_compute_network" "vpc_network" {
  name = var.network_name
}

resource "google_compute_subnetwork" "subnets" {
  for_each                 = { for subnet in var.subnets : subnet.name => subnet }
  name                     = each.value.name
  ip_cidr_range            = each.value.ip_cidr_range
  region                   = var.region
  network                  = google_compute_network.vpc_network.self_link
  private_ip_google_access = "true"
}

resource "google_vpc_access_connector" "serverless_connector" {
  name           = "serverless-connector-dev"
  region         = var.region
  network        = google_compute_network.vpc_network.self_link
  ip_cidr_range  = "10.8.0.0/28"
  min_throughput = 200 # Minimum throughput (2 instances équivalentes)
  max_throughput = 300
}
