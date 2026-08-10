output "aws_region" {
  description = "AWS 배포 리전"
  value       = var.aws_region
}

output "environment" {
  description = "현재 배포 환경"
  value       = var.environment
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  value = module.network.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  value = module.network.private_data_subnet_ids
}

output "spring_boot_repository_url" {
  value = module.ecr.spring_boot_repository_url
}

output "ai_repository_url" {
  value = module.ecr.ai_repository_url
}

output "rds_endpoint" {
  value = module.data.rds_endpoint
}

output "redis_primary_endpoint" {
  value = module.data.redis_primary_endpoint
}