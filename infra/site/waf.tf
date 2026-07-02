# WAF — public defaults: AWS Managed Common, SQLi, Known Bad Inputs, rate limit.
# (No IP allowlist by default. Apps that need one can add an aws_wafv2_ip_set
# and a higher-priority NotStatement rule, mirroring the ef4 pattern.)

resource "aws_wafv2_web_acl" "site" {
  provider = aws.us_east_1
  name     = "airisk-cf-waf"
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
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
