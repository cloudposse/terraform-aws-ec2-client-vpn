output "client_configuration" {
  sensitive   = true
  value       = module.ec2_client_vpn.client_configuration
  description = "VPN Client Configuration data."
}

output "full_client_configuration" {
  sensitive   = true
  value       = module.ec2_client_vpn.full_client_configuration
  description = "Client configuration including client certificate and private key"
}

output "log_group_arn" {
  value       = module.ec2_client_vpn.log_group_arn
  description = "The ARN of the CloudWatch Log Group used for Client VPN connection logging."
}

output "log_group_name" {
  value       = module.ec2_client_vpn.log_group_name
  description = "The name of the CloudWatch Log Group used for Client VPN connection logging."
}

output "security_group_arn" {
  value       = module.ec2_client_vpn.security_group_arn
  description = "The ARN of the security group associated with the Client VPN endpoint."
}

output "security_group_id" {
  value       = module.ec2_client_vpn.security_group_id
  description = "The ID of the security group associated with the Client VPN endpoint."
}

output "security_group_name" {
  value       = module.ec2_client_vpn.security_group_name
  description = "The name of the security group associated with the Client VPN endpoint."
}

output "vpn_endpoint_arn" {
  value       = module.ec2_client_vpn.vpn_endpoint_arn
  description = "The ARN of the Client VPN Endpoint Connection."
}

output "vpn_endpoint_dns_name" {
  value       = module.ec2_client_vpn.vpn_endpoint_dns_name
  description = "The DNS Name of the Client VPN Endpoint Connection."
}

output "vpn_endpoint_id" {
  value       = module.ec2_client_vpn.vpn_endpoint_id
  description = "The ID of the Client VPN Endpoint Connection."
}
