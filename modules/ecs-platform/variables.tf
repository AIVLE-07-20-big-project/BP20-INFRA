variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "backend_secret_arn" {
  type = string
}

variable "ai_secret_arn" {
  type = string
}

variable "rds_master_secret_arn" {
  type = string
}

variable "execution_role_name" {
  description = "기존 ECS Task Execution Role 이름"
  type        = string
}

variable "ai_task_role_name" {
  description = "FastAPI 및 Celery가 사용할 기존 ECS Task Role 이름"
  type        = string
}

variable "be_task_role_name" {
  description = "Spring Boot가 사용할 기존 ECS Task Role 이름"
  type        = string
}

variable "ai_model_bucket_arn" {
  description = "AI 모델 및 RAG 자산이 저장된 기존 S3 Bucket ARN"
  type        = string
}

variable "product_image_bucket_arn" {
  description = "상품 및 AI 생성 이미지가 저장되는 기존 S3 Bucket ARN"
  type        = string
}
