output "vpn_endpoint_arn" {
  description = "The Amazon Resource Name (ARN) of the Client VPN endpoint"
  value = module.ec2_client_vpn.vpn_endpoint_arn
}

output "vpn_endpoint_id" {
  description = "The ID of the Client VPN endpoint"
  value = module.ec2_client_vpn.vpn_endpoint_id
}

output "vpn_endpoint_dns_name" {
  description = "The DNS name to be used by clients when establishing their VPN session"
  value = module.ec2_client_vpn.vpn_endpoint_dns_name
}

output "client_configuration" {
  description = "The full client configuration file content for the VPN endpoint"
  sensitive = true
  value     = module.ec2_client_vpn.full_client_configuration
}
