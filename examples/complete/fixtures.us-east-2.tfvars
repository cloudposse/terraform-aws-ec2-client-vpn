region = "us-east-2"

namespace = "eg"

environment = "ue2"

stage = "test"

name = "example"

logging_enabled = false

retention_in_days = 0

organization_name = "Dewey, Cheatum, and Howe Penny Stocks"

availability_zones = ["us-east-2a", "us-east-2b"]

additional_security_groups = []

authorization_rules = [
  {
    name                 = "Internet Rule"
    authorize_all_groups = true
    description          = "Allows routing to the internet"
    target_network_cidr  = "0.0.0.0/0"
  },
  
]
