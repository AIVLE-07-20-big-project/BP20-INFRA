variable "name_prefix" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "spring_security_group_id" {
  type = string
}

variable "ai_security_group_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "be_task_role_arn" {
  type = string
}

variable "ai_task_role_arn" {
  type = string
}

variable "spring_repository_url" {
  type = string
}

variable "ai_repository_url" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "bootstrap"
}

variable "rds_endpoint" {
  type = string
}

variable "rds_port" {
  type = number
}

variable "database_name" {
  type = string
}

variable "rds_master_secret_arn" {
  type = string
}

variable "redis_endpoint" {
  type = string
}

variable "backend_secret_arn" {
  type = string
}

variable "ai_secret_arn" {
  type = string
}

variable "ai_model_bucket_name" {
  type = string
}

variable "product_image_bucket_name" {
  type = string
}

variable "spring_target_group_arn" {
  type = string
}

variable "namespace_id" {
  type = string
}

variable "log_group_names" {
  type = object({
    spring        = string
    fastapi       = string
    celery_worker = string
    celery_beat   = string
  })
}

variable "jpa_ddl_auto" {
  description = "Flyway 미사용 상태의 최초 배포 스키마 생성 방식"
  type        = string
  default     = "update"

  validation {
    condition     = contains(["validate", "update", "create", "create-drop", "none"], var.jpa_ddl_auto)
    error_message = "jpa_ddl_auto는 validate, update, create, create-drop, none 중 하나여야 합니다."
  }
}

variable "cors_allowed_origins" {
  description = "CloudFront 생성 전에는 비워 두고, 생성 후 HTTPS Origin을 지정"
  type        = string
  default     = ""
}

variable "captcha_enabled" {
  description = "CloudFront 도메인과 reCAPTCHA 키 연결 후 활성화"
  type        = bool
  default     = false
}

variable "captcha_allowed_hostnames" {
  type    = string
  default = ""
}

variable "desired_count" {
  type    = number
  default = 1
}
