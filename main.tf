locals {
  enabled = module.this.enabled

  security_group_enabled      = local.enabled && var.create_security_group
  mutual_enabled              = local.enabled && var.authentication_type == "certificate-authentication"
  federated_enabled           = local.enabled && var.authentication_type == "federated-authentication"
  self_service_portal_enabled = local.federated_enabled && var.self_service_portal_enabled
  logging_enabled             = local.enabled && var.logging_enabled

  export_client_certificate      = local.mutual_enabled && var.export_client_certificate
  certificate_backends           = ["ACM", "SSM"]
  saml_provider_arn              = local.federated_enabled ? try(aws_iam_saml_provider.default[0].arn, var.saml_provider_arn) : null
  root_certificate_chain_arn     = local.mutual_enabled ? module.self_signed_cert_root.certificate_arn : null
  self_service_saml_provider_arn = local.self_service_portal_enabled ? var.self_service_saml_provider_arn : null
  cloudwatch_log_group           = local.logging_enabled ? module.cloudwatch_log.log_group_name : null
  cloudwatch_log_stream          = local.logging_enabled ? var.logging_stream_name : null
  ca_common_name                 = var.ca_common_name != null ? var.ca_common_name : "${module.this.id}.vpn.ca"
  root_common_name               = var.root_common_name != null ? var.root_common_name : "${module.this.id}.vpn.client"
  server_common_name             = var.server_common_name != null ? var.server_common_name : "${module.this.id}.vpn.server"
  client_conf_tmpl_path          = var.client_conf_tmpl_path == null ? "${path.module}/templates/client-config.ovpn.tpl" : var.client_conf_tmpl_path
}

module "self_signed_cert_ca" {
  source  = "cloudposse/ssm-tls-self-signed-cert/aws"
  version = "1.1.0"

  attributes = ["self", "signed", "cert", "ca"]

  secret_path_format = var.secret_path_format

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
  version = "1.0.0"

  attributes = ["self", "signed", "cert", "root"]

  secret_path_format = var.secret_path_format

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
  version = "1.0.0"

  attributes = ["self", "signed", "cert", "server"]

  secret_path_format = var.secret_path_format

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
  version = "0.6.6"
  enabled = local.logging_enabled

  stream_names = [var.logging_stream_name]

  retention_in_days = var.retention_in_days

  context = module.this.context
}

resource "aws_iam_saml_provider" "default" {
  count = local.enabled && var.saml_metadata_document != null ? 1 : 0

  name                   = module.this.id
  saml_metadata_document = var.saml_metadata_document

  tags = module.this.tags
}

resource "aws_ec2_client_vpn_endpoint" "default" {
  count = local.enabled ? 1 : 0

  description            = module.this.id
  server_certificate_arn = module.self_signed_cert_server.certificate_arn
  client_cidr_block      = var.client_cidr
  self_service_portal    = local.self_service_portal_enabled ? "enabled" : "disabled"

  authentication_options {
    type                           = var.authentication_type
    saml_provider_arn              = local.saml_provider_arn
    root_certificate_chain_arn     = local.root_certificate_chain_arn
    self_service_saml_provider_arn = local.self_service_saml_provider_arn
  }

  connection_log_options {
    enabled               = var.logging_enabled
    cloudwatch_log_group  = local.cloudwatch_log_group
    cloudwatch_log_stream = local.cloudwatch_log_stream
  }

  dynamic "client_connect_options" {
    for_each = var.connection_authorization_lambda_arn == null ? [] : [1]
    content {
      enabled             = true
      lambda_function_arn = var.connection_authorization_lambda_arn
    }
  }

  dns_servers  = var.dns_servers
  split_tunnel = var.split_tunnel

  session_timeout_hours = var.session_timeout_hours

  tags = module.this.tags

  depends_on = [
    module.self_signed_cert_server,
    module.self_signed_cert_root,
  ]

  security_group_ids = compact(concat(
    [module.vpn_security_group.id],
    local.associated_security_group_ids
  ))
  vpc_id = var.vpc_id
}

module "vpn_security_group" {
  source  = "cloudposse/security-group/aws"
  version = "1.0.1"

  enabled                       = local.security_group_enabled
  security_group_name           = var.security_group_name
  create_before_destroy         = var.security_group_create_before_destroy
  security_group_create_timeout = var.security_group_create_timeout
  security_group_delete_timeout = var.security_group_delete_timeout

  security_group_description = var.security_group_description
  allow_all_egress           = true
  rules                      = var.additional_security_group_rules
  rule_matrix = [
    {
      cidr_blocks               = var.allowed_cidr_blocks
      ipv6_cidr_blocks          = var.allowed_ipv6_cidr_blocks
      prefix_list_ids           = var.allowed_ipv6_prefix_list_ids
      source_security_group_ids = var.allowed_security_group_ids
      self                      = var.allow_self_security_group
      rules = [{
        key         = "vpn-self"
        type        = "ingress"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        description = "Allow all ingress from designated sources"
      }]
    }
  ]

  vpc_id = var.vpc_id

  context = module.this.context
}

resource "aws_ec2_client_vpn_network_association" "default" {
  count = local.enabled ? length(var.associated_subnets) : 0

  client_vpn_endpoint_id = join("", aws_ec2_client_vpn_endpoint.default.*.id)
  subnet_id              = var.associated_subnets[count.index]
}

resource "aws_ec2_client_vpn_authorization_rule" "default" {
  count = local.enabled ? length(var.authorization_rules) : 0

  access_group_id        = lookup(var.authorization_rules[count.index], "access_group_id", null)
  authorize_all_groups   = lookup(var.authorization_rules[count.index], "authorize_all_groups", null)
  client_vpn_endpoint_id = join("", aws_ec2_client_vpn_endpoint.default.*.id)
  description            = var.authorization_rules[count.index].description
  target_network_cidr    = var.authorization_rules[count.index].target_network_cidr
}

resource "aws_ec2_client_vpn_route" "default" {
  count = local.enabled ? length(var.additional_routes) : 0

  description            = try(var.additional_routes[count.index].description, null)
  destination_cidr_block = var.additional_routes[count.index].destination_cidr_block
  client_vpn_endpoint_id = join("", aws_ec2_client_vpn_endpoint.default.*.id)
  target_vpc_subnet_id   = var.additional_routes[count.index].target_vpc_subnet_id

  depends_on = [
    aws_ec2_client_vpn_network_association.default
  ]

  timeouts {
    create = "5m"
    delete = "5m"
  }
}

data "awsutils_ec2_client_vpn_export_client_config" "default" {
  count = local.enabled ? 1 : 0

  id = join("", aws_ec2_client_vpn_endpoint.default.*.id)
}

data "aws_ssm_parameter" "root_key" {
  count = local.export_client_certificate ? 1 : 0

  name = module.self_signed_cert_root.certificate_key_path

  # Necessary to retrieve the ssm parameter after the module is created
  # The implicit output in the name isn't enough.
  depends_on = [
    module.self_signed_cert_root
  ]
}
