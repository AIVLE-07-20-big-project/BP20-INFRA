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

module "alb" {
  source = "./modules/alb"

  name_prefix           = local.name_prefix
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
}

module "ecs_services" {
  source = "./modules/ecs-services"

  name_prefix               = local.name_prefix
  aws_region                = var.aws_region
  cluster_id                = module.ecs_platform.cluster_id
  private_app_subnet_ids    = module.network.private_app_subnet_ids
  spring_security_group_id  = module.security.spring_security_group_id
  ai_security_group_id      = module.security.ai_security_group_id
  execution_role_arn        = module.ecs_platform.execution_role_arn
  be_task_role_arn          = module.ecs_platform.be_task_role_arn
  ai_task_role_arn          = module.ecs_platform.ai_task_role_arn
  spring_repository_url     = module.ecr.spring_boot_repository_url
  ai_repository_url         = module.ecr.ai_repository_url
  image_tag                 = var.application_image_tag
  rds_endpoint              = module.data.rds_endpoint
  rds_port                  = module.data.rds_port
  database_name             = var.database_name
  rds_master_secret_arn     = module.data.rds_master_secret_arn
  redis_endpoint            = module.data.redis_primary_endpoint
  backend_secret_arn        = module.secrets.backend_secret_arn
  ai_secret_arn             = module.secrets.ai_secret_arn
  ai_model_bucket_name      = var.ai_model_bucket_name
  product_image_bucket_name = var.product_image_bucket_name
  spring_target_group_arn   = module.alb.spring_target_group_arn
  namespace_id              = module.ecs_platform.namespace_id
  log_group_names           = module.ecs_platform.log_group_names
  jpa_ddl_auto              = var.jpa_ddl_auto
  cors_allowed_origins      = var.cors_allowed_origins
  captcha_enabled           = var.captcha_enabled
  captcha_allowed_hostnames = var.captcha_allowed_hostnames

  depends_on = [module.alb]
}
