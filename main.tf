provider "awsutils" {
  region = var.region
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

  context = module.this.context
}

resource "aws_acm_certificate" "ca" {
  private_key      = module.self_signed_cert_ca.ca_private_key_pem
  certificate_body = module.self_signed_cert_ca.certificate_pem
}

resource "aws_acm_certificate" "root" {
  private_key       = module.self_signed_cert_root.root_private_key_pem
  certificate_body  = module.self_signed_cert_root.certificate_pem
  certificate_chain = module.self_signed_cert_ca.certificate_pem
}

resource "aws_acm_certificate" "server" {
  private_key       = module.self_signed_cert_server.server_private_key_pem
  certificate_body  = module.self_signed_cert_server.certificate_pem
  certificate_chain = module.self_signed_cert_ca.certificate_pem
}

module "cloudwatch_log" {
  source = "cloudposse/cloudwatch-logs/aws"

  stream_names = var.stream_names

  context = module.this.context
}

resource "aws_ec2_client_vpn_endpoint" "default" {
  description            = module.this.id
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = var.client_cidr

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.root.arn
  }

  connection_log_options {
    enabled               = var.logging_enabled
    cloudwatch_log_group  = var.logging_enabled ? module.cloudwatch_log.log_group_name : null
    cloudwatch_log_stream = var.logging_enabled ? element(var.stream_names, 0) : null
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
  count = var.internet_access_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_route" "internet_route" {
  count = var.internet_access_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = aws_ec2_client_vpn_network_association.default.subnet_id
}

data "awsutils_ec2_client_vpn_export_client_config" "default" {
  id = aws_ec2_client_vpn_endpoint.default.id

  depends_on = [
    aws_ec2_client_vpn_endpoint.default,
    aws_ec2_client_vpn_network_association.default,
  ]
}
