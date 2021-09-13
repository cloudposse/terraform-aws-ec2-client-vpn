region = "us-east-2"

namespace = "eg"

client_cidr_block = "172.16.0.0/16"

target_cidr_block = "172.31.0.0/16"

logging_stream_name = "client_vpn"

environment = "ue2"

stage = "test"

name = "example"

logging_enabled = false

retention_in_days = 0

organization_name = "Cloud Posse"

availability_zones = ["us-east-2a", "us-east-2b"]

additional_security_groups = []

authorization_rules = [
  {
    name                 = "Internet Rule"
    access_group_id      = null
    authorize_all_groups = true
    description          = "Allows routing to the internet"
    target_network_cidr  = "0.0.0.0/0"
  },
]

