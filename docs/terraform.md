<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |
| <a name="requirement_awsutils"></a> [awsutils](#requirement\_awsutils) | >= 0.7.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.2 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |
| <a name="provider_awsutils"></a> [awsutils](#provider\_awsutils) | >= 0.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch_log"></a> [cloudwatch\_log](#module\_cloudwatch\_log) | cloudposse/cloudwatch-logs/aws | n/a |
| <a name="module_self_signed_cert_ca"></a> [self\_signed\_cert\_ca](#module\_self\_signed\_cert\_ca) | cloudposse/ssm-tls-self-signed-cert/aws | n/a |
| <a name="module_self_signed_cert_root"></a> [self\_signed\_cert\_root](#module\_self\_signed\_cert\_root) | cloudposse/ssm-tls-self-signed-cert/aws | n/a |
| <a name="module_self_signed_cert_server"></a> [self\_signed\_cert\_server](#module\_self\_signed\_cert\_server) | cloudposse/ssm-tls-self-signed-cert/aws | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |
| <a name="module_vpn_security_group"></a> [vpn\_security\_group](#module\_vpn\_security\_group) | cloudposse/security-group/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_client_vpn_authorization_rule.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_endpoint.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint) | resource |
| [aws_ec2_client_vpn_network_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_network_association) | resource |
| [aws_ec2_client_vpn_route.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_route) | resource |
| [aws_iam_saml_provider.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider) | resource |
| [awsutils_ec2_client_vpn_export_client_config.default](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/data-sources/ec2_client_vpn_export_client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_routes"></a> [additional\_routes](#input\_additional\_routes) | A list of additional routes that should be attached to the Client VPN endpoint | <pre>list(object({<br>    destination_cidr_block = string<br>    description            = string<br>    target_vpc_subnet_id   = string<br>  }))</pre> | `[]` | no |
| <a name="input_additional_security_groups"></a> [additional\_security\_groups](#input\_additional\_security\_groups) | List of security groups to attach to the client vpn network associations | `list(string)` | `[]` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_associated_subnets"></a> [associated\_subnets](#input\_associated\_subnets) | List of subnets to associate with the VPN endpoint | `list(string)` | n/a | yes |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | One of `certificate-authentication` or `federated-authentication` | `string` | `"certificate-authentication"` | no |
| <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules) | List of objects describing the authorization rules for the client vpn | <pre>list(object({<br>    name                 = string<br>    access_group_id      = string<br>    authorize_all_groups = bool<br>    description          = string<br>    target_network_cidr  = string<br>  }))</pre> | n/a | yes |
| <a name="input_basic_constraints"></a> [basic\_constraints](#input\_basic\_constraints) | The [basic constraints](https://datatracker.ietf.org/doc/html/rfc5280#section-4.2.1.9) of the issued certificate.<br>Currently, only the `CA` constraint (which identifies whether the subject of the certificate is a CA) can be set.<br>Defaults to this certificate not being a CA. | <pre>object({<br>    ca = bool<br>  })</pre> | <pre>{<br>  "ca": false<br>}</pre> | no |
| <a name="input_ca_common_name"></a> [ca\_common\_name](#input\_ca\_common\_name) | Unique Common Name for CA self-signed certificate | `string` | `null` | no |
| <a name="input_client_cidr"></a> [client\_cidr](#input\_client\_cidr) | Network CIDR to use for clients | `any` | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_logging_enabled"></a> [logging\_enabled](#input\_logging\_enabled) | Enables or disables Client VPN Cloudwatch logging. | `bool` | `false` | no |
| <a name="input_logging_stream_name"></a> [logging\_stream\_name](#input\_logging\_stream\_name) | Names of stream used for logging | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Name of organization to use in private certificate | `string` | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | VPN Endpoints are region-specific. This identifies the region. AWS Region | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Number of days you want to retain log events in the log group | `string` | `"30"` | no |
| <a name="input_root_common_name"></a> [root\_common\_name](#input\_root\_common\_name) | Unique Common Name for Root self-signed certificate | `string` | `null` | no |
| <a name="input_saml_metadata_document"></a> [saml\_metadata\_document](#input\_saml\_metadata\_document) | Optional SAML metadata document. Must include this or `saml_provider_arn` | `string` | `null` | no |
| <a name="input_saml_provider_arn"></a> [saml\_provider\_arn](#input\_saml\_provider\_arn) | Optional SAML provider ARN. Must include this or `saml_metadata_document` | `string` | `""` | no |
| <a name="input_server_common_name"></a> [server\_common\_name](#input\_server\_common\_name) | Unique Common Name for Server self-signed certificate | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_validity"></a> [validity](#input\_validity) | Validity settings for the issued certificate:<br>`duration_hours`: The number of hours from issuing the certificate until it becomes invalid.<br>`early_renewal_hours`: If set, the resource will consider the certificate to have expired the given number of hours before its actual expiry time (see: [self\_signed\_cert.early\_renewal\_hours](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert#early_renewal_hours)).<br>Defaults to 10 years and no early renewal hours. | <pre>object({<br>    duration_hours      = number<br>    early_renewal_hours = number<br>  })</pre> | <pre>{<br>  "duration_hours": 87600,<br>  "early_renewal_hours": null<br>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC to attach VPN to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_configuration"></a> [client\_configuration](#output\_client\_configuration) | VPN Client Configuration data. |
| <a name="output_vpn_endpoint_arn"></a> [vpn\_endpoint\_arn](#output\_vpn\_endpoint\_arn) | The ARN of the Client VPN Endpoint Connection. |
| <a name="output_vpn_endpoint_dns_name"></a> [vpn\_endpoint\_dns\_name](#output\_vpn\_endpoint\_dns\_name) | The DNS Name of the Client VPN Endpoint Connection. |
| <a name="output_vpn_endpoint_id"></a> [vpn\_endpoint\_id](#output\_vpn\_endpoint\_id) | The ID of the Client VPN Endpoint Connection. |
<!-- markdownlint-restore -->
