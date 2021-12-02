output "vpn_endpoint_arn" {
  value       = local.enabled ? join("", aws_ec2_client_vpn_endpoint.default.*.arn) : null
  description = "The ARN of the Client VPN Endpoint Connection."
}

output "vpn_endpoint_id" {
  value       = local.enabled ? join("", aws_ec2_client_vpn_endpoint.default.*.id) : null
  description = "The ID of the Client VPN Endpoint Connection."
}

output "vpn_endpoint_dns_name" {
  value       = local.enabled ? join("", aws_ec2_client_vpn_endpoint.default.*.dns_name) : null
  description = "The DNS Name of the Client VPN Endpoint Connection."
}

output "client_configuration" {
  value       = local.enabled ? join("", data.awsutils_ec2_client_vpn_export_client_config.default.*.client_configuration) : null
  description = "VPN Client Configuration data."
}

output "full_client_configuration" {
  value = local.export_client_certificate ? templatefile(
    local.client_conf_tmpl_path,
    {
      cert        = module.self_signed_cert_root.certificate_pem,
      private_key = join("", data.aws_ssm_parameter.root_key.*.value)
      original_client_config = replace(
        join("", data.awsutils_ec2_client_vpn_export_client_config.default.*.client_configuration),
        "remote cvpn",
        "remote ${module.this.id}.cvpn"
      )
    }
  ) : ""
  description = "Client configuration including client certificate and private key"
}
