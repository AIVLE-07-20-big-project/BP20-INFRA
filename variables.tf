variable "aws_region" {
  description = "AWS 리소스를 생성할 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "배포 환경"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
  default     = "bp20"
}

variable "availability_zones" {
  description = "인프라를 배치할 가용 영역 목록"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public Subnet CIDR 목록"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "Private App Subnet CIDR 목록"
  type        = list(string)
}

variable "private_data_subnet_cidrs" {
  description = "Private Data Subnet CIDR 목록"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "NAT Gateway 생성 여부"
  type        = bool
  default     = false
}

variable "database_name" {
  description = "애플리케이션 데이터베이스 이름"
  type        = string
  default     = "bp20"
}

variable "database_username" {
  description = "RDS 관리자 사용자명"
  type        = string
  default     = "bp20_admin"
}

variable "ecs_execution_role_name" {
  description = "기존 ECS Task Execution Role 이름"
  type        = string
  default     = "bp20-ecsTaskExecutionRole"
}

variable "ai_task_role_name" {
  description = "FastAPI와 Celery가 사용할 기존 ECS Task Role 이름"
  type        = string
  default     = "bp20-aiTaskRole"
}

variable "be_task_role_name" {
  description = "Spring Boot가 사용할 기존 ECS Task Role 이름"
  type        = string
  default     = "bp20-beTaskRole"
}

variable "ai_model_bucket_name" {
  description = "기존 AI 모델 및 RAG 자산 S3 Bucket 이름"
  type        = string
  default     = "aivlebp20-prod-assets"
}

variable "product_image_bucket_name" {
  description = "기존 상품 및 AI 생성 이미지 S3 Bucket 이름"
  type        = string
  default     = "aivlebp20-product-images-prod"
}

variable "application_image_tag" {
  description = "최초 수동 배포 또는 CI/CD가 사용할 공통 이미지 태그"
  type        = string
  default     = "bootstrap"
}

variable "jpa_ddl_auto" {
  description = "Flyway 미사용 상태에서 Spring Boot가 적용할 Hibernate DDL 정책"
  type        = string
  default     = "update"
}

variable "cors_allowed_origins" {
  description = "허용할 프론트엔드 Origin 목록. CloudFront 생성 후 HTTPS Origin으로 갱신"
  type        = string
  default     = ""
}

variable "captcha_enabled" {
  description = "CloudFront 도메인과 reCAPTCHA 키 연결 후 true로 변경"
  type        = bool
  default     = false
}

variable "captcha_allowed_hostnames" {
  description = "쉼표로 구분한 reCAPTCHA 허용 호스트명"
  type        = string
  default     = ""
}
