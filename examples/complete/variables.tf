variable "region" {
  type = string
}

variable "logging_enabled" {
  type = bool
}

variable "retention_in_days" {
  type = number
}

variable "organization_name" {
  type = string
}

variable "additional_routes" {
  type = list(object({
    destination_cidr_block = string
    description            = string
    target_vpc_subnet_id   = string
  }))
}

variable "additional_security_groups" {
  type = list(string)
}

variable "authorization_rules" {
  type = list(object({
    name                 = string
    access_group_id      = string
    authorize_all_groups = bool
    description          = string
    target_network_cidr  = string
  }))
}
