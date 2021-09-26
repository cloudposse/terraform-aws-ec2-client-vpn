output "vpn_endpoint_arn" {
  value       = aws_ec2_client_vpn_endpoint.default.arn
  description = "The ARN of the Client VPN Endpoint Connection."
}

output "vpn_endpoint_id" {
  value       = aws_ec2_client_vpn_endpoint.default.id
  description = "The ID of the Client VPN Endpoint Connection."
}

output "vpn_endpoint_dns_name" {
  value       = aws_ec2_client_vpn_endpoint.default.dns_name
  description = "The DNS Name of the Client VPN Endpoint Connection."
}

output "client_configuration" {
  value       = data.awsutils_ec2_client_vpn_export_client_config.default.client_configuration
  description = "VPN Client Configuration data."
}

output "full_client_configuration" {
  value = var.export_client_certificate ? templatefile(
    "${path.module}/templates/client-config.ovpn.tpl",
    {
      cert        = module.self_signed_cert_root.certificate_pem,
      private_key = join("", data.aws_ssm_parameter.root_key.*.value)
      original_client_config = replace(
        data.awsutils_ec2_client_vpn_export_client_config.default.client_configuration,
        "remote cvpn",
        "remote ${random_pet.vpn_host.id}.cvpn"
      )
    }
  ) : ""
  description = "Client configuration including client certificate and private key"
}