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
}
