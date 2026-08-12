variable "name_prefix" {
  type = string
}

variable "account_id" {
  type = string
}

variable "alb_dns_name" {
  type = string
}

variable "product_image_bucket_name" {
  description = "외부에서 관리하는 상품·AI 생성 이미지 Bucket 이름"
  type        = string
}