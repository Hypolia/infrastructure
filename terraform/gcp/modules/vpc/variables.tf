variable "network_name" {}
variable "subnets" {
  type = list(object({
    name          = string
    ip_cidr_range = string
  }))
}
variable "region" {}