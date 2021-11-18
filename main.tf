locals {
  enabled                    = module.this.enabled
  certificate_backends       = ["ACM", "SSM"]
  mutual_enabled             = var.authentication_type == "certificate-authentication"
  federated_enabled          = var.authentication_type == "federated-authentication"
  saml_provider_arn          = local.federated_enabled ? try(aws_iam_saml_provider.default[0].arn, var.saml_provider_arn) : null
  root_certificate_chain_arn = local.mutual_enabled ? module.self_signed_cert_root.certificate_arn : null
  cloudwatch_log_group       = var.logging_enabled ? module.cloudwatch_log.log_group_name : null
  cloudwatch_log_stream      = var.logging_enabled ? var.logging_stream_name : null
  ca_common_name             = var.ca_common_name != null ? var.ca_common_name : "${module.this.id}.vpn.ca"
  root_common_name           = var.root_common_name != null ? var.root_common_name : "${module.this.id}.vpn.client"
  server_common_name         = var.server_common_name != null ? var.server_common_name : "${module.this.id}.vpn.server"
  client_conf_tmpl_path      = var.client_conf_tmpl_path == null ? "${path.module}/templates/client-config.ovpn.tpl" : var.client_conf_tmpl_path
}

module "self_signed_cert_ca" {
  source  = "cloudposse/ssm-tls-self-signed-cert/aws"
  version = "0.4.0"

  name = "self-signed-cert-ca"

  enabled = local.enabled

  subject = {
    common_name  = local.ca_common_name
    organization = var.organization_name
  }

  basic_constraints = {
    ca = true
  }

  allowed_uses = [
    "crl_signing",
    "cert_signing",
  ]

  certificate_backends = ["SSM"]

  context = module.this.context
}

data "aws_ssm_parameter" "ca_key" {
  count = local.enabled ? 1 : 0
  name  = module.self_signed_cert_ca.certificate_key_path

  depends_on = [
    module.self_signed_cert_ca
  ]
}

module "self_signed_cert_root" {
  source  = "cloudposse/ssm-tls-self-signed-cert/aws"
  version = "0.4.0"

  name = "self-signed-cert-root"

  enabled = local.mutual_enabled

  subject = {
    common_name  = local.root_common_name
    organization = var.organization_name
  }

  basic_constraints = {
    ca = false
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]

  certificate_backends = local.certificate_backends

  use_locally_signed = true

  certificate_chain = {
    cert_pem        = module.self_signed_cert_ca.certificate_pem,
    private_key_pem = join("", data.aws_ssm_parameter.ca_key.*.value)
  }

  context = module.this.context
}

module "self_signed_cert_server" {
  source  = "cloudposse/ssm-tls-self-signed-cert/aws"
  version = "0.4.0"

  name = "self-signed-cert-server"

  enabled = local.enabled

  subject = {
    common_name  = local.server_common_name
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

  certificate_backends = local.certificate_backends

  use_locally_signed = true

  certificate_chain = {
    cert_pem        = module.self_signed_cert_ca.certificate_pem,
    private_key_pem = join("", data.aws_ssm_parameter.ca_key.*.value)
  }

  context = module.this.context
}

module "cloudwatch_log" {
  source  = "cloudposse/cloudwatch-logs/aws"
  version = "0.6.1"
  enabled = var.logging_enabled

  stream_names = [var.logging_stream_name]

  context = module.this.context
}

resource "aws_iam_saml_provider" "default" {
  count = var.saml_metadata_document != null ? 1 : 0

  name                   = module.this.id
  saml_metadata_document = var.saml_metadata_document
}

resource "aws_ec2_client_vpn_endpoint" "default" {
  description            = module.this.id
  server_certificate_arn = module.self_signed_cert_server.certificate_arn
  client_cidr_block      = var.client_cidr

  authentication_options {
    type                       = var.authentication_type
    saml_provider_arn          = local.saml_provider_arn
    root_certificate_chain_arn = local.root_certificate_chain_arn
  }

  connection_log_options {
    enabled               = var.logging_enabled
    cloudwatch_log_group  = local.cloudwatch_log_group
    cloudwatch_log_stream = local.cloudwatch_log_stream
  }

  dns_servers = var.dns_servers

  split_tunnel = var.split_tunnel

  tags = module.this.tags

  depends_on = [
    module.self_signed_cert_server,
    module.self_signed_cert_root,
  ]
}

module "vpn_security_group" {
  source  = "cloudposse/security-group/aws"
  version = "0.4.2"

  rules = [
    {
      key         = "vpn-self"
      type        = "ingress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow self access only by default"
      self        = true
    },
  ]

  vpc_id = var.vpc_id

  context = module.this.context
}

resource "aws_ec2_client_vpn_network_association" "default" {
  count = local.enabled ? length(var.associated_subnets) : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  subnet_id              = var.associated_subnets[count.index]

  security_groups = concat(
    [module.vpn_security_group.id],
    var.additional_security_groups
  )
}

resource "aws_ec2_client_vpn_authorization_rule" "default" {
  count = local.enabled ? length(var.authorization_rules) : 0

  access_group_id        = var.authorization_rules[count.index].access_group_id
  authorize_all_groups   = var.authorization_rules[count.index].authorize_all_groups
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  description            = var.authorization_rules[count.index].description
  target_network_cidr    = var.authorization_rules[count.index].target_network_cidr

}

resource "aws_ec2_client_vpn_route" "default" {
  count = local.enabled ? length(var.additional_routes) : 0

  description            = try(var.additional_routes[count.index].description, null)
  destination_cidr_block = var.additional_routes[count.index].destination_cidr_block
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.default.id
  target_vpc_subnet_id   = var.additional_routes[count.index].target_vpc_subnet_id

  depends_on = [
    aws_ec2_client_vpn_network_association.default
  ]
}

data "awsutils_ec2_client_vpn_export_client_config" "default" {
  id = aws_ec2_client_vpn_endpoint.default.id

  depends_on = [
    aws_ec2_client_vpn_endpoint.default
  ]
}

data "aws_ssm_parameter" "root_key" {
  count = var.export_client_certificate ? 1 : 0
  name  = module.self_signed_cert_root.certificate_key_path

  depends_on = [
    module.self_signed_cert_root
  ]
}
