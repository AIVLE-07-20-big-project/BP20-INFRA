output "spring_boot_repository_url" {
  value = aws_ecr_repository.this["spring_boot"].repository_url
}

output "ai_repository_url" {
  value = aws_ecr_repository.this["ai"].repository_url
}