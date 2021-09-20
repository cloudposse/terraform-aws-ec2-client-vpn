variable "region" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "target_cidr_block" {
  type = string
}

variable "client_cidr_block" {
  type = string
}

variable "logging_stream_name" {
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

variable "ca_common_name" {
  type = string
}

variable "root_common_name" {
  type = string
}

variable "server_common_name" {
  type = string
}
