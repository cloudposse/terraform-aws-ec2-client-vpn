variable "region" {
  description = "There are a number of region dependent resources. This makes sure everything is in the same region."
  type        = string
}

variable "availability_zones" {
  description = "VPC availability zones"
  type        = list(string)
}

variable "target_cidr_block" {
  description = "cidr for the target VPC that is created"
  type        = string
}

variable "client_cidr_block" {
  description = "Network CIDR to use for clients"
  type        = string
}

variable "logging_stream_name" {
  description = "Names of stream used for logging"
  type        = string
}

variable "logging_enabled" {
  description = "Enables or disables Client VPN Cloudwatch logging."
  type        = bool
}

variable "retention_in_days" {
  description = "Number of days you want to retain log events in the log group"
  type        = number
}

variable "organization_name" {
  type        = string
  description = "Name of organization to use in private certificate"
}

variable "associated_security_group_ids" {
  description = "List of security groups to attach to the client vpn network associations"
  type        = list(string)
}

variable "authorization_rules" {
  description = "List of objects describing the authorization rules for the client vpn"
  type = list(object({
    name                 = string
    access_group_id      = string
    authorize_all_groups = bool
    description          = string
    target_network_cidr  = string
  }))
}

variable "additional_routes" {
  default     = []
  description = "A list of additional routes that should be attached to the Client VPN endpoint"

  type = list(object({
    destination_cidr_block = string
    description            = string
  }))
}

variable "ca_common_name" {
  type        = string
  description = "Unique Common Name for CA self-signed certificate"
}

variable "root_common_name" {
  type        = string
  description = "Unique Common Name for Root self-signed certificate"
}

variable "server_common_name" {
  type        = string
  description = "Unique Common Name for Server self-signed certificate"
}

variable "export_client_certificate" {
  default     = false
  sensitive   = true
  type        = bool
  description = "Flag to determine whether to export the client certificate with the VPN configuration"
}

variable "dns_servers" {
  default     = []
  type        = list(string)
  description = "(Optional) Information about the DNS servers to be used for DNS resolution. A Client VPN endpoint can have up to two DNS servers. If no DNS server is specified, the DNS address of the connecting device is used."
}

variable "split_tunnel" {
  default     = false
  type        = bool
  description = "(Optional) Indicates whether split-tunnel is enabled on VPN endpoint. Default value is false."
}
