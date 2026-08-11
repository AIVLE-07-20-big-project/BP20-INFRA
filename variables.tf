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