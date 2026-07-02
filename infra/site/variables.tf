variable "parent_domain" {
  description = "Existing parent hosted zone (e.g., thekiln.cloud)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain to serve the site from (joined with parent_domain)"
  type        = string
}

variable "enable_access_logging" {
  description = "Whether to provision WAF logging to CloudWatch Logs"
  type        = bool
  default     = true
}
