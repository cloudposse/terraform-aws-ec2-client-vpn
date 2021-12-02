output "vpn_endpoint_arn" {
  value = module.ec2_client_vpn.vpn_endpoint_arn
}

output "vpn_endpoint_id" {
  value = module.ec2_client_vpn.vpn_endpoint_id
}

output "vpn_endpoint_dns_name" {
  value = module.ec2_client_vpn.vpn_endpoint_dns_name
}

output "client_configuration" {
  sensitive = true
  value     = module.ec2_client_vpn.full_client_configuration
}
