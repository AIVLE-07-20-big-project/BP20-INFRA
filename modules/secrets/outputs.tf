output "backend_secret_arn" {
  value = aws_secretsmanager_secret.backend.arn
}

output "ai_secret_arn" {
  value = aws_secretsmanager_secret.ai.arn
}