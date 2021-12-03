variable "additional_security_groups" {
  type        = list(string)
  default     = []
  description = <<-EOT
  DEPRECATED: Use `associated_security_group_ids` instead.
  List of security groups to attach to the client vpn network associations
  EOT
}
