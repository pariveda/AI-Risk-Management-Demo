data "aws_caller_identity" "current" {}

locals {
  site_fqdn = "${var.subdomain}.${var.parent_domain}"
}
