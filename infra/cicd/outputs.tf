output "deploy_role_arn" {
  description = "IAM role ARN assumed by GitHub Actions for site deploys"
  value       = aws_iam_role.deploy.arn
}

output "tf_plan_role_arn" {
  description = "IAM role ARN assumed by GitHub Actions to run terragrunt plan on PRs"
  value       = aws_iam_role.tf_plan.arn
}

output "tf_apply_role_arn" {
  description = "IAM role ARN assumed by GitHub Actions to run terragrunt apply on push:main"
  value       = aws_iam_role.tf_apply.arn
}

output "oidc_provider_arn" {
  description = "GitHub OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}
