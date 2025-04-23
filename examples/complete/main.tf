provider "aws" {
  region = var.region
}

provider "awsutils" {
  region = var.region
}

locals {
  additional_routes = [for route in var.additional_routes : {
    destination_cidr_block = route.destination_cidr_block
    description            = route.description
    target_vpc_subnet_id   = element(module.subnets.private_subnet_ids, 0)
  }]
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "2.1.0"

  ipv4_primary_cidr_block = var.target_cidr_block

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.4.1"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context = module.this.context
}

module "ec2_client_vpn" {
  source = "../../"

  ca_common_name     = var.ca_common_name
  root_common_name   = var.root_common_name
  server_common_name = var.server_common_name

  client_cidr                   = var.client_cidr_block
  organization_name             = var.organization_name
  logging_enabled               = var.logging_enabled
  logging_stream_name           = var.logging_stream_name
  retention_in_days             = var.retention_in_days
  associated_subnets            = module.subnets.private_subnet_ids
  authorization_rules           = var.authorization_rules
  additional_routes             = local.additional_routes
  associated_security_group_ids = var.associated_security_group_ids
  export_client_certificate     = var.export_client_certificate
  vpc_id                        = module.vpc.vpc_id
  dns_servers                   = var.dns_servers
  split_tunnel                  = var.split_tunnel
  disconnect_on_session_timeout = var.disconnect_on_session_timeout

  context = module.this.context
}
