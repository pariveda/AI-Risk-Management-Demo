include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../"
}

# Extra provider for WAF/ACM (CLOUDFRONT scope requires us-east-1).
generate "provider_us_east_1" {
  path      = "provider_us_east_1.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      alias  = "us_east_1"
      region = "us-east-1"

      default_tags {
        tags = {
          Project     = "airisk"
          Environment = "prod"
          ManagedBy   = "terragrunt"
        }
      }
    }
  EOF
}

inputs = {
  parent_domain         = "thekiln.cloud"
  subdomain             = "airisk"
  enable_access_logging = true

  # VPN-only to start (same VPN CIDRs as the other platform apps, e.g. osprey).
  # Office CIDRs intentionally omitted for now; add them here to widen access.
  allowed_cidr_blocks = [
    # US VPN
    "50.114.87.100/32",
    # IT VPN
    "45.84.120.22/32",
    # Bogota VPN
    "149.88.111.169/32", "149.88.111.166/32",
  ]
}
