variable "name_prefix" {
  description = "리소스 이름에 사용할 접두사"
  type        = string
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
