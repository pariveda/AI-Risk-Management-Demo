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

  # Office + VPN allowlist, mirroring osprey's canonical list (the source of
  # truth for Pariveda office/VPN CIDRs; two public IPs per office).
  allowed_cidr_blocks = [
    # Atlanta
    "67.72.9.98/32", "107.130.214.1/32",
    # Chicago
    "4.16.32.138/32", "73.120.203.212/32",
    # Dallas
    "4.7.207.222/32", "45.23.106.81/32",
    # Houston
    "4.17.89.174/32", "96.65.252.13/32",
    # Los Angeles
    "4.36.231.226/32", "162.239.87.121/32",
    # New York
    "24.39.119.130/32", "64.152.175.88/32",
    # Philadelphia
    "108.52.125.9/32", "63.214.23.214/32",
    # San Francisco
    "4.19.249.226/32", "70.229.8.217/32",
    # Seattle
    "65.57.79.182/32", "38.140.26.50/32",
    # Washington DC
    "209.244.200.78/32", "96.86.1.45/32",
    # VPN
    "50.114.87.100/32", "45.84.120.22/32",
    # Bogota VPN
    "149.88.111.169/32", "149.88.111.166/32",
  ]
}
