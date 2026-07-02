output "site_fqdn" {
  description = "Public hostname for the site"
  value       = local.site_fqdn
}

output "s3_bucket_name" {
  description = "S3 bucket that holds the built site"
  value       = aws_s3_bucket.site.bucket
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.site.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (used for invalidations)"
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.site.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront default domain"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "route53_zone_nameservers" {
  description = "NS records to add to the parent zone to delegate the subdomain"
  value       = aws_route53_zone.site.name_servers
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF web ACL attached to CloudFront"
  value       = aws_wafv2_web_acl.site.arn
}
