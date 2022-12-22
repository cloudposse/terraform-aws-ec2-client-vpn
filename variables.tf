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
  # type = list(object({
  #   name                 = string
  #   access_group_id      = string
  #   authorize_all_groups = bool
  #   description          = string
  #   target_network_cidr  = string
  # }))
  type        = list(map(any))
  description = "List of objects describing the authorization rules for the client vpn"
  default     = []
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
  description = "Information about the DNS servers to be used for DNS resolution. A Client VPN endpoint can have up to two DNS servers. If no DNS server is specified, the DNS address of the connecting device is used."
}

variable "split_tunnel" {
  default     = false
  type        = bool
  description = "Indicates whether split-tunnel is enabled on VPN endpoint. Default value is false."
}

variable "secret_path_format" {
  description = <<-EOT
  The path format to use when writing secrets to the certificate backend.
  The certificate secret path will be computed as `format(var.secret_path_format, var.name, var.secret_extensions.certificate)`
  and the private key path as `format(var.secret_path_format, var.name, var.secret_extensions.private_key)`.
  Thus by default, if `var.name`=`example-self-signed-cert`, then the resulting secret paths for the self-signed certificate's
  PEM file and private key will be `/example-self-signed-cert.pem` and `/example-self-signed-cert.key`, respectively.
  This variable can be overridden in order to create more specific certificate backend paths.
  EOT
  type        = string
  default     = "/%s.%s"

  validation {
    condition     = can(substr(var.secret_path_format, 0, 1) == "/")
    error_message = "The secret path format must contain a leading slash."
  }
}

variable "self_service_portal_enabled" {
  description = "Specify whether to enable the self-service portal for the Client VPN endpoint"
  type        = bool
  default     = false
}

variable "self_service_saml_provider_arn" {
  description = "The ARN of the IAM SAML identity provider for the self service portal if type is federated-authentication."
  type        = string
  default     = null
}

variable "session_timeout_hours" {
  description = "The maximum session duration is a trigger by which end-users are required to re-authenticate prior to establishing a VPN session. Default value is 24. Valid values: 8 | 10 | 12 | 24"
  type        = string
  default     = "24"

  validation {
    condition     = contains(["8", "10", "12", "24"], var.session_timeout_hours)
    error_message = "The maximum session duration must one be one of: 8, 10, 12, 24."
  }
}

variable "connection_authorization_lambda_arn" {
  description = "The Amazon Resource Name (ARN) of the Lambda function used for connection authorization."
  type        = string
  default     = null
}