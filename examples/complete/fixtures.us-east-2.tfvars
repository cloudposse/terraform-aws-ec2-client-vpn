region = "us-east-2"

namespace = "eg"

ca_common_name     = "vpn.internal.cloudposse.com"
root_common_name   = "vpn-client.internal.cloudposse.com"
server_common_name = "vpn-server.internal.cloudposse.com"

additional_routes = [
]

client_cidr_block = "10.1.0.0/22"

target_cidr_block = "10.0.0.0/16"

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
]

export_client_certificate = true
