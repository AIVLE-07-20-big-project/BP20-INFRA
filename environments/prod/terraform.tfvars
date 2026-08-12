aws_region   = "ap-northeast-2"
environment  = "prod"
project_name = "bp20"

availability_zones = [
  "ap-northeast-2a",
  "ap-northeast-2c"
]

vpc_cidr = "10.20.0.0/16"

public_subnet_cidrs = [
  "10.20.0.0/24",
  "10.20.1.0/24"
]

private_app_subnet_cidrs = [
  "10.20.10.0/24",
  "10.20.11.0/24"
]

private_data_subnet_cidrs = [
  "10.20.20.0/24",
  "10.20.21.0/24"
]

enable_nat_gateway = true

ecs_execution_role_name   = "bp20-ecsTaskExecutionRole"
ai_task_role_name         = "bp20-aiTaskRole"
be_task_role_name         = "bp20-beTaskRole"
ai_model_bucket_name      = "aivlebp20-prod-assets"
product_image_bucket_name = "aivlebp20-product-images-prod"

application_image_tag     = "release-20260812-01"
jpa_ddl_auto              = "validate"
cors_allowed_origins      = "https://dt555m45x3ua9.cloudfront.net"
captcha_enabled           = true
captcha_allowed_hostnames = "dt555m45x3ua9.cloudfront.net"