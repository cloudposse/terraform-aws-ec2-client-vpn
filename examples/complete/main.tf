provider "aws" {
  region = var.region
}

module "vpc_target" {
  source  = "cloudposse/vpc/aws"
  version = "0.21.1"

  cidr_block = "172.16.0.0/16"

  context = module.this.context
}

module "vpc_client" {
  source  = "cloudposse/vpc/aws"
  version = "0.21.1"

  cidr_block = "172.31.0.0/16"

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "0.39.3"

  availability_zones              = var.availability_zones
  vpc_id                          = module.vpc_target.vpc_id
  igw_id                          = module.vpc_target.igw_id
  cidr_block                      = module.vpc_target.vpc_cidr_block
  nat_gateway_enabled             = true
  nat_instance_enabled            = false
  context = module.this.context
}


module "example" {
  source = "../../"

  region = var.region

  client_cidr = module.vpc_client.vpc_cidr_block

  aws_subnet_id = element(module.subnets.private_subnet_ids, 0)

  organization_name = var.organization_name

  aws_authorization_rule_target_cidr = module.vpc_target.vpc_cidr_block

  logging_enabled = var.logging_enabled

  retention_in_days = var.retention_in_days

  internet_access_enabled = var.internet_access_enabled
}
