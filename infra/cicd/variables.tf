variable "github_repository" {
  description = "GitHub repo in 'owner/name' form, used for OIDC trust policy"
  type        = string
}

variable "deploy_branch" {
  description = "Git ref that is permitted to deploy"
  type        = string
  default     = "main"
}
