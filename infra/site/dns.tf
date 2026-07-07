resource "aws_route53_zone" "site" {
  name    = local.site_fqdn
  comment = "Delegated subdomain for airisk. NS records must be added in the parent zone."
}

resource "aws_route53_record" "site_a" {
  zone_id = aws_route53_zone.site.zone_id
  name    = local.site_fqdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site_aaaa" {
  zone_id = aws_route53_zone.site.zone_id
  name    = local.site_fqdn
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
