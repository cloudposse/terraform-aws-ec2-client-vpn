output "vpn_endpoint_arn" {
  value = module.example.vpn_endpoint_arn
}

output "vpn_endpoint_id" {
  value = module.example.vpn_endpoint_id
}

output "vpn_endpoint_dns_name" {
  value = module.example.vpn_endpoint_dns_name
}

output "client_configuration" {
  sensitive = true
  value     = module.example.full_client_configuration
}
