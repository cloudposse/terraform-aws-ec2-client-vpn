# Changelog

## 2.0.0

### BREAKING CHANGES

This release contains breaking changes that require action when upgrading.

#### Resource iteration changed from `count` to `for_each` (#96)

The following resources now use `for_each` instead of `count`:
- `aws_ec2_client_vpn_network_association.default` - keyed by list index (`"0"`, `"1"`, etc.)
- `aws_ec2_client_vpn_authorization_rule.default` - keyed by `name` attribute if provided, otherwise list index
- `aws_ec2_client_vpn_route.default` - keyed by `name` attribute if provided, otherwise list index

**Impact:** Terraform will see existing resources as needing replacement. To avoid recreation, migrate state before applying:

```bash
# Network associations use index-based keys
terraform state mv 'aws_ec2_client_vpn_network_association.default[0]' 'aws_ec2_client_vpn_network_association.default["0"]'
terraform state mv 'aws_ec2_client_vpn_network_association.default[1]' 'aws_ec2_client_vpn_network_association.default["1"]'

# Authorization rules use the "name" attribute as the key
terraform state mv 'aws_ec2_client_vpn_authorization_rule.default[0]' 'aws_ec2_client_vpn_authorization_rule.default["<name>"]'

# Routes use "name" if provided, otherwise index
terraform state mv 'aws_ec2_client_vpn_route.default[0]' 'aws_ec2_client_vpn_route.default["<name-or-index>"]'
```

#### New optional `name` attribute for `additional_routes`

The `additional_routes` variable now supports an optional `name` attribute. When provided, it is used as the `for_each` key for the route resource. This enables more stable resource addressing.

```hcl
additional_routes = [
  {
    name                   = "internet"  # Optional: used as for_each key
    destination_cidr_block = "0.0.0.0/0"
    description            = "Internet Route"
    target_vpc_subnet_id   = "subnet-abc123"
  }
]
```

Thanks to @jurgenweber for the contribution!
