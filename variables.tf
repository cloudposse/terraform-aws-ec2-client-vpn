variable "region" {
  type        = string
  description = "VPN Endpoints are region-specific. This identifies the region. AWS Region"
}

variable "client_cidr" {
  description = "Network CIDR to use for clients"
}

variable "aws_subnet_id" {
  type        = string
  description = "The Subnet ID to associate with the Client VPN Endpoint."
}

variable "aws_authorization_rule_target_cidr" {
  type        = string
  description = "The target CIDR address within your VPC that you would like to provider authorization for."
}

variable "logging_enabled" {
  type        = bool
  default     = false
  description = "Enables or disables Client VPN Cloudwatch logging."
}

variable "internet_access_enabled" {
  type        = bool
  default     = true
  description = <<-EOT
    Enables an authorization rule and route for the VPN to access the internet.
    Please note, you must allow ingress/egress to the internet (0.0.0.0/0) via the Subnet's security group.
  EOT
}

variable "organization_name" {
  type        = string
  description = "Name of organization to use in private certificate"
}

variable "retention_in_days" {
  description = "Number of days you want to retain log events in the log group"
  default     = "30"
}

variable "stream_names" {
  type        = list(string)
  description = "Names of streams"
  default     = []
}

variable "basic_constraints" {
  description = <<-EOT
    The [basic constraints](https://datatracker.ietf.org/doc/html/rfc5280#section-4.2.1.9) of the issued certificate.
    Currently, only the `CA` constraint (which identifies whether the subject of the certificate is a CA) can be set.
    Defaults to this certificate not being a CA.
  EOT
  type = object({
    ca = bool
  })
  default = {
    ca = false
  }
}