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

module "vpc_target" {
  source  = "cloudposse/vpc/aws"
  version = "0.21.1"

  cidr_block = var.target_cidr_block

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "0.39.3"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc_target.vpc_id
  igw_id               = module.vpc_target.igw_id
  cidr_block           = module.vpc_target.vpc_cidr_block
  nat_gateway_enabled  = true
  nat_instance_enabled = false
  context              = module.this.context
}

module "example" {
  source = "../../"

  region = var.region

  ca_common_name     = var.ca_common_name
  root_common_name   = var.root_common_name
  server_common_name = var.server_common_name

  client_cidr = var.client_cidr_block

  organization_name = var.organization_name

  logging_enabled = var.logging_enabled

  logging_stream_name = var.logging_stream_name

  retention_in_days = var.retention_in_days

  associated_subnets = module.subnets.private_subnet_ids

  authorization_rules = var.authorization_rules

  additional_routes = local.additional_routes

  additional_security_groups = var.additional_security_groups

  export_client_certificate = var.export_client_certificate

  vpc_id = module.vpc_target.vpc_id

  dns_servers = var.dns_servers

  split_tunnel = var.split_tunnel
}
