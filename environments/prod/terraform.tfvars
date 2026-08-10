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

enable_nat_gateway = false