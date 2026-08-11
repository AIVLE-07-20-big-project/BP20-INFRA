module "network" {
  source = "./modules/network"

  name_prefix               = local.name_prefix
  vpc_cidr                  = var.vpc_cidr
  availability_zones        = var.availability_zones
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_data_subnet_cidrs = var.private_data_subnet_cidrs
  enable_nat_gateway        = var.enable_nat_gateway
}

module "security" {
  source = "./modules/security"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id
}

module "ecr" {
  source = "./modules/ecr"

  name_prefix = local.name_prefix
}

module "secrets" {
  source = "./modules/secrets"

  name_prefix = local.name_prefix
}

module "data" {
  source = "./modules/data"

  name_prefix             = local.name_prefix
  private_data_subnet_ids = module.network.private_data_subnet_ids
  rds_security_group_id   = module.security.rds_security_group_id
  redis_security_group_id = module.security.redis_security_group_id
  database_name           = var.database_name
  database_username       = var.database_username
}

module "ecs_platform" {
  source = "./modules/ecs-platform"

  name_prefix              = local.name_prefix
  vpc_id                   = module.network.vpc_id
  backend_secret_arn       = module.secrets.backend_secret_arn
  ai_secret_arn            = module.secrets.ai_secret_arn
  rds_master_secret_arn    = module.data.rds_master_secret_arn
  execution_role_name      = var.ecs_execution_role_name
  ai_task_role_name        = var.ai_task_role_name
  be_task_role_name        = var.be_task_role_name
  ai_model_bucket_arn      = "arn:aws:s3:::${var.ai_model_bucket_name}"
  product_image_bucket_arn = "arn:aws:s3:::${var.product_image_bucket_name}"
}
