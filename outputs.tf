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