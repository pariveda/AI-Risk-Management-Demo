# WAF — AWS Managed Common, SQLi, Known Bad Inputs, rate limit, plus an optional
# IP allowlist (ef4 pattern). When var.allowed_cidr_blocks is non-empty, a
# priority-0 rule blocks any request whose source IP is not in the set; empty
# list = public (no allowlist rule).

resource "aws_wafv2_ip_set" "allowed" {
  count              = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  provider           = aws.us_east_1
  name               = "airisk-allowed-ips"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.allowed_cidr_blocks
}

resource "aws_wafv2_web_acl" "site" {
  provider = aws.us_east_1
  name     = "airisk-cf-waf"
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Rule 0: block anything not in the allowlist (only when an allowlist is set).
  dynamic "rule" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      name     = "IPAllowlist"
      priority = 0

      action {
        block {}
      }

      statement {
        not_statement {
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.allowed[0].arn
            }
          }
        }
      }

      visibility_config {
        sampled_requests_enabled   = true
        cloudwatch_metrics_enabled = true
        metric_name                = "airisk-cf-ip-block"
      }
    }
  }

  rule {
    name     = "AWSManagedCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "airisk-cf-common-rules"
    }
  }

  rule {
    name     = "AWSManagedSQLiRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "airisk-cf-sqli-rules"
    }
  }

  rule {
    name     = "AWSManagedKnownBadInputs"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "airisk-cf-bad-inputs"
    }
  }

  # Rate limit — 2000 requests per 5 minutes per source IP.
  rule {
    name     = "RateLimit"
    priority = 4

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "airisk-cf-rate-limit"
    }
  }

  visibility_config {
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
    metric_name                = "airisk-cf-waf"
  }
}

resource "aws_cloudwatch_log_group" "waf" {
  count             = var.enable_access_logging ? 1 : 0
  provider          = aws.us_east_1
  name              = "aws-waf-logs-airisk-site"
  retention_in_days = 90
}

resource "aws_wafv2_web_acl_logging_configuration" "site" {
  count                   = var.enable_access_logging ? 1 : 0
  provider                = aws.us_east_1
  log_destination_configs = [aws_cloudwatch_log_group.waf[0].arn]
  resource_arn            = aws_wafv2_web_acl.site.arn
}
