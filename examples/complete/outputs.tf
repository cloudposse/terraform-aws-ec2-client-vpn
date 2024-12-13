output "vpn_endpoint_arn" {
  value       = module.ec2_client_vpn.vpn_endpoint_arn
  description = "The ARN of the Client VPN Endpoint Connection."
}

output "vpn_endpoint_id" {
  value       = module.ec2_client_vpn.vpn_endpoint_id
  description = "The ID of the Client VPN Endpoint Connection."
}

output "vpn_endpoint_dns_name" {
  value       = module.ec2_client_vpn.vpn_endpoint_dns_name
  description = "The DNS Name of the Client VPN Endpoint Connection."
}

output "client_configuration" {
  sensitive   = true
  value       = module.ec2_client_vpn.full_client_configuration
  description = "VPN Client Configuration data."
}
