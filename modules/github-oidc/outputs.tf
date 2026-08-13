output "frontend_deploy_role_arn" {
  value = aws_iam_role.frontend_deploy.arn
}

output "backend_deploy_role_arn" {
  value = aws_iam_role.backend_deploy.arn
}

output "ai_deploy_role_arn" {
  value = aws_iam_role.ai_deploy.arn
}