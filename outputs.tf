output "vpn_endpoint_id" {
  value       = aws_ec2_client_vpn_endpoint.default.id
  description = "The ID of the Client VPN Endpoint Connection."
}

output "client_configuration" {
  value       = awsutils_ec2_client_vpn_export_client_config.default.client_configuration
  description = "VPN Client Configuration data."
}