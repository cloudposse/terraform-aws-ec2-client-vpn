provider "awsutils" {
  region = var.region
}

locals {
  enabled           = module.this.enabled
  mutual_enabled    = var.authentication_type == "certificate-authentication"
  federated_enabled = var.authentication_type == "federated_authentication"
}

module "self_signed_cert_ca" {
  source = "cloudposse/ssm-tls-self-signed-cert/aws"

  name = "self-signed-cert-ca"

  subject = {
    common_name  = module.this.id
    organization = var.organization_name
  }

  basic_constraints = {
    ca = true
  }

  allowed_uses = [
    "crl_signing",
    "cert_signing",
  ]

  context = module.this.context
}

module "self_signed_cert_root" {
  source = "cloudposse/ssm-tls-self-signed-cert/aws"

  name = "self-signed-cert-root"

  subject = {
    common_name  = module.this.id
    organization = var.organization_name
  }

  basic_constraints = {
    ca = false
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]

  context = module.this.context
}

module "self_signed_cert_server" {
  source = "cloudposse/ssm-tls-self-signed-cert/aws"

  name = "self-signed-cert-server"

  subject = {
    common_name  = module.this.id
    organization = var.organization_name
  }

  basic_constraints = {
    ca = false
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]

  context = module.this.context
}

resource "aws_acm_certificate" "ca" {
  private_key      = module.self_signed_cert_ca.certificate_key_path
  certificate_body = module.self_signed_cert_ca.certificate_pem
}

resource "aws_acm_certificate" "root" {
  private_key       = module.self_signed_cert_root.certificate_key_path
  certificate_body  = module.self_signed_cert_root.certificate_pem
  certificate_chain = module.self_signed_cert_ca.certificate_pem
}

resource "aws_acm_certificate" "server" {
  private_key       = module.self_signed_cert_server.certificate_key_path
  certificate_body  = module.self_signed_cert_server.certificate_pem
  certificate_chain = module.self_signed_cert_ca.certificate_pem
}

module "cloudwatch_log" {
  source = "cloudposse/cloudwatch-logs/aws"

  stream_names = [var.logging_stream_name]

  context = module.this.context
}

resource "aws_ec2_client_vpn_endpoint" "default" {
  description            = module.this.id
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = var.client_cidr

  authentication_options = local.mutual_enabled ? {
    type                       = var.authentication_type
    root_certificate_chain_arn = aws_acm_certificate.root.arn
    } : {
    type              = var.authentication_type
    saml_provider_arn = try(aws_iam_saml_provider.this[0].arn, var.saml_provider_arn)
  }

  connection_log_options {
    enabled               = var.logging_enabled
    cloudwatch_log_group  = var.logging_enabled ? module.cloudwatch_log.log_group_name : null
    cloudwatch_log_stream = var.logging_enabled ? var.logging_stream_name : null
  }

  tags = module.this.tags
}

resource "aws_ec2_client_vpn_network_association" "default" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  subnet_id              = var.aws_subnet_id
}

resource "aws_ec2_client_vpn_authorization_rule" "internal" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  target_network_cidr    = var.aws_authorization_rule_target_cidr
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_authorization_rule" "internet_rule" {
  count = local.enabled && var.internet_access_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_route" "internet_route" {
  count = local.enabled && var.internet_access_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = aws_ec2_client_vpn_network_association.default.subnet_id
}

module "vpn_security_group" {
  source = "cloudposse/security-group"

  attributes = ["simple"]
  rules = [
    {
      key         = "vpn-self"
      type        = "ingress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow self access only by default"
      self        = true
    },
  ]

  vpc_id = module.vpc.vpc_id

  context = module.this.context
}

resource "aws_ec2_client_vpn_network_association" "this" {
  for_each = toset(var.associated_subnets) #avoid ordering errors by using a for_each instead of count

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.key

  security_groups = concat(
    [aws_security_group.this.id],
    var.additional_security_groups
  )
}

resource "aws_ec2_client_vpn_authorization_rule" "rules" {
  count = length(var.authorization_rules)

  access_group_id        = var.authorization_rules[count.index].access_group_id
  authorize_all_groups   = var.authorization_rules[count.index].authorize_all_groups
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  description            = var.authorization_rules[count.index].description
  target_network_cidr    = var.authorization_rules[count.index].target_network_cidr

}

resource "aws_ec2_client_vpn_route" "additional" {
  count = length(var.additional_routes)

  description            = try(var.additional_routes[count.index].description, null)
  destination_cidr_block = var.additional_routes[count.index].destination_cidr_block
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_vpc_subnet_id   = var.additional_routes[count.index].target_vpc_subnet_id
}

data "awsutils_ec2_client_vpn_export_client_config" "default" {
  id = aws_ec2_client_vpn_endpoint.default.id

  depends_on = [
    aws_ec2_client_vpn_endpoint.default,
    aws_ec2_client_vpn_network_association.default,
  ]
}
