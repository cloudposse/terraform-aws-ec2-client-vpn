variable "client_cidr" {
  type        = string
  description = "Network CIDR to use for clients"
}

variable "logging_enabled" {
  type        = bool
  default     = false
  description = "Enables or disables Client VPN Cloudwatch logging."
}

variable "authentication_type" {
  type        = string
  default     = "certificate-authentication"
  description = <<-EOT
    One of `certificate-authentication` or `federated-authentication`
  EOT
  validation {
    condition     = contains(["certificate-authentication", "federated-authentication"], var.authentication_type)
    error_message = "VPN client authentication type must one be one of: certificate-authentication, federated-authentication."
  }
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = <<-EOT
    A list of IPv4 CIDRs to allow access to the security group created by this module.
    The length of this list must be known at "plan" time.
    EOT
}

variable "allowed_ipv6_cidr_blocks" {
  type        = list(string)
  default     = []
  description = <<-EOT
    A list of IPv6 CIDRs to allow access to the security group created by this module.
    The length of this list must be known at "plan" time.
    EOT
}

variable "allowed_ipv6_prefix_list_ids" {
  type        = list(string)
  default     = []
  description = <<-EOT
    A list of IPv6 Prefix Lists IDs to allow access to the security group created by this module.
    The length of this list must be known at "plan" time.
    EOT
}

variable "organization_name" {
  type        = string
  description = "Name of organization to use in private certificate"
}

variable "retention_in_days" {
  type        = number
  description = "Number of days you want to retain log events in the log group"
  default     = "30"
}

variable "logging_stream_name" {
  type        = string
  description = "Names of stream used for logging"
}

variable "saml_metadata_document" {
  default     = null
  description = "Optional SAML metadata document. Must include this or `saml_provider_arn`"
  type        = string
}

variable "saml_provider_arn" {
  default     = null
  description = "Optional SAML provider ARN. Must include this or `saml_metadata_document`"
  type        = string

  validation {
    error_message = "Invalid SAML provider ARN."

    condition = (
      var.saml_provider_arn == null ||
      try(length(regexall(
        "^arn:[^:]+:iam::(?P<account_id>\\d{12}):saml-provider\\/(?P<provider_name>[\\w+=,\\.@-]+)$",
        var.saml_provider_arn
        )) > 0,
        false
    ))
  }
}

variable "additional_routes" {
  default     = []
  description = "A list of additional routes that should be attached to the Client VPN endpoint"

  type = list(object({
    destination_cidr_block = string
    description            = string
    target_vpc_subnet_id   = string
  }))
}

variable "associated_subnets" {
  type        = list(string)
  description = "List of subnets to associate with the VPN endpoint"
}

variable "authorization_rules" {
  type = list(object({
    name                 = string
    access_group_id      = string
    authorize_all_groups = bool
    description          = string
    target_network_cidr  = string
  }))
  description = "List of objects describing the authorization rules for the client vpn"
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC to attach VPN to"
}

variable "ca_common_name" {
  default     = null
  type        = string
  description = "Unique Common Name for CA self-signed certificate"
}

variable "root_common_name" {
  default     = null
  type        = string
  description = "Unique Common Name for Root self-signed certificate"
}

variable "server_common_name" {
  default     = null
  type        = string
  description = "Unique Common Name for Server self-signed certificate"
}

variable "export_client_certificate" {
  default     = false
  sensitive   = true
  type        = bool
  description = "Flag to determine whether to export the client certificate with the VPN configuration"
}

variable "client_conf_tmpl_path" {
  default     = null
  type        = string
  description = "Path to template file of vpn client exported configuration. Path is relative to $${path.module}"
}

variable "dns_servers" {
  default = []
  type    = list(string)
  validation {
    condition = can(
      [
        for server_ip in var.dns_servers : regex(
          "^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",
          server_ip
        )
      ]
    )
    error_message = "IPv4 addresses must match the appropriate format xxx.xxx.xxx.xxx."
  }
  description = "Information about the DNS servers to be used for DNS resolution. A Client VPN endpoint can have up to two DNS servers. If no DNS server is specified, the DNS address of the VPC that is to be associated with Client VPN endpoint is used as the DNS server."
}

variable "split_tunnel" {
  default     = false
  type        = bool
  description = "Indicates whether split-tunnel is enabled on VPN endpoint. Default value is false."
}
