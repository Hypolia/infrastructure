output "database_name" {
  value = google_sql_database_instance.postgres_instance.name
}

output "database_host" {
  value = google_sql_database_instance.postgres_instance.private_ip_address
}