terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
    awsutils = {
      source  = "cloudposse/awsutils"
      version = ">= 0.8.0"
    }
  }
}