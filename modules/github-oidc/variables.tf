variable "name_prefix" {
  type = string
}

variable "github_org" {
  description = "GitHub Organization 이름"
  type        = string
  default     = "AIVLE-07-20-big-project"
}

variable "frontend_bucket_arn" {
  type = string
}

variable "cloudfront_distribution_arn" {
  type = string
}

variable "ecr_repository_arns" {
  description = "spring-boot, ai Repository ARN 목록"
  type        = list(string)
}

variable "ecs_cluster_arn" {
  type = string
}

variable "task_role_arns" {
  description = "RegisterTaskDefinition 시 PassRole이 필요한 Role ARN 목록"
  type        = list(string)
}