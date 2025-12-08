# Changelog

## 2.0.0

### BREAKING CHANGES

This release contains breaking changes that require action when upgrading.

#### Resource iteration changed from `count` to `for_each` (#96)

The following resources now use `for_each` instead of `count`:
- `aws_ec2_client_vpn_network_association.default`
- `aws_ec2_client_vpn_authorization_rule.default`
- `aws_ec2_client_vpn_route.default`

**Impact:** Terraform will see existing resources as needing replacement. To avoid recreation, migrate state before applying:

```bash
# Example state migration (keys are list indices as strings: "0", "1", etc.)
terraform state mv 'aws_ec2_client_vpn_network_association.default[0]' 'aws_ec2_client_vpn_network_association.default["0"]'
terraform state mv 'aws_ec2_client_vpn_network_association.default[1]' 'aws_ec2_client_vpn_network_association.default["1"]'
terraform state mv 'aws_ec2_client_vpn_authorization_rule.default[0]' 'aws_ec2_client_vpn_authorization_rule.default["0"]'
terraform state mv 'aws_ec2_client_vpn_route.default[0]' 'aws_ec2_client_vpn_route.default["0"]'
```

Thanks to @jurgenweber for the contribution!
