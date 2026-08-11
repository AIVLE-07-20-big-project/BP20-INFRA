locals {
  spring_environment = [
    { name = "SPRING_PROFILES_ACTIVE", value = "prod" },
    { name = "SPRING_DATASOURCE_URL", value = "jdbc:mysql://${var.rds_endpoint}:${var.rds_port}/${var.database_name}?useSSL=true&serverTimezone=Asia/Seoul" },
    { name = "SPRING_DATA_REDIS_HOST", value = var.redis_endpoint },
    { name = "SPRING_DATA_REDIS_PORT", value = "6379" },
    { name = "SPRING_DATA_REDIS_SSL_ENABLED", value = "true" },
    { name = "FASTAPI_BASE_URL", value = "http://fastapi.bp20.local:8000" },
    { name = "AWS_REGION", value = var.aws_region },
    { name = "S3_BUCKET_NAME", value = var.ai_model_bucket_name },
    { name = "UPLOAD_S3_PREFIX", value = "uploads/v1" },
    { name = "STORAGE_S3_REGION", value = var.aws_region },
    { name = "STORAGE_S3_BUCKET", value = var.product_image_bucket_name },
    { name = "JPA_DDL_AUTO", value = var.jpa_ddl_auto },
    { name = "JWT_EXPIRATION_SECONDS", value = "7200" },
    { name = "JWT_ADMIN_EXPIRATION_SECONDS", value = "900" },
    { name = "REFRESH_TOKEN_STORE", value = "redis" },
    { name = "REFRESH_TOKEN_EXPIRATION_SECONDS", value = "604800" },
    { name = "REFRESH_TOKEN_REMEMBER_ME_EXPIRATION_SECONDS", value = "2592000" },
    { name = "REFRESH_TOKEN_COOKIE_NAME", value = "bp20_refresh_token" },
    { name = "REFRESH_TOKEN_COOKIE_SECURE", value = "true" },
    { name = "REFRESH_TOKEN_COOKIE_SAME_SITE", value = "Lax" },
    { name = "INVITATION_EXPIRATION_HOURS", value = "24" },
    { name = "PASSWORD_MAX_AGE_DAYS", value = "90" },
    { name = "MAX_FAILED_LOGIN_ATTEMPTS", value = "5" },
    { name = "ACCOUNT_LOCK_MINUTES", value = "15" },
    { name = "CAPTCHA_ENABLED", value = tostring(var.captcha_enabled) },
    { name = "CAPTCHA_VERIFY_URL", value = "https://www.google.com/recaptcha/api/siteverify" },
    { name = "CAPTCHA_MIN_SCORE", value = "0.5" },
    { name = "CAPTCHA_EXPECTED_ACTION", value = "login" },
    { name = "CAPTCHA_ALLOWED_HOSTNAMES", value = var.captcha_allowed_hostnames },
    { name = "CORS_ALLOWED_ORIGINS", value = var.cors_allowed_origins }
  ]

  spring_secrets = [
    { name = "SPRING_DATASOURCE_USERNAME", valueFrom = "${var.rds_master_secret_arn}:username::" },
    { name = "SPRING_DATASOURCE_PASSWORD", valueFrom = "${var.rds_master_secret_arn}:password::" },
    { name = "JWT_SECRET", valueFrom = "${var.backend_secret_arn}:JWT_SECRET::" },
    { name = "PERSONAL_DATA_ENCRYPTION_KEY", valueFrom = "${var.backend_secret_arn}:PERSONAL_DATA_ENCRYPTION_KEY::" },
    { name = "KAKAO_REST_API_KEY", valueFrom = "${var.backend_secret_arn}:KAKAO_REST_API_KEY::" },
    { name = "KMA_SERVICE_KEY", valueFrom = "${var.backend_secret_arn}:KMA_SERVICE_KEY::" },
    { name = "CAPTCHA_SECRET_KEY", valueFrom = "${var.backend_secret_arn}:CAPTCHA_SECRET_KEY::" },
    { name = "INTERNAL_API_KEY", valueFrom = "${var.backend_secret_arn}:INTERNAL_API_KEY::" }
  ]

  ai_environment = [
    { name = "AI_DB_HOST", value = var.rds_endpoint },
    { name = "AI_DB_PORT", value = tostring(var.rds_port) },
    { name = "AI_DB_NAME", value = var.database_name },
    { name = "CELERY_BROKER_URL", value = "rediss://${var.redis_endpoint}:6379/0?ssl_cert_reqs=required" },
    { name = "CELERY_RESULT_BACKEND", value = "rediss://${var.redis_endpoint}:6379/1?ssl_cert_reqs=required" },
    { name = "AWS_REGION", value = var.aws_region },
    { name = "S3_BUCKET_NAME", value = var.ai_model_bucket_name },
    { name = "MODEL_S3_PREFIX", value = "models/v1" },
    { name = "RAG_S3_PREFIX", value = "rag/v1" },
    { name = "DATA_S3_PREFIX", value = "data" },
    { name = "FEEDBACK_S3_PREFIX", value = "feedback/v1" },
    { name = "BANDIT_S3_PREFIX", value = "bandit/v1" },
    { name = "UPLOAD_S3_PREFIX", value = "uploads/v1" },
    { name = "CAMPAIGN_LOGS_S3_PREFIX", value = "logs" },
    { name = "HF_AUTO_DOWNLOAD_ASSETS", value = "false" },
    { name = "ABSA_ENABLED", value = "true" },
    { name = "ROBERTA_MODEL_PATH", value = "/opt/models/roberta-absa" }
  ]

  ai_secrets = [
    { name = "AI_DB_USERNAME", valueFrom = "${var.rds_master_secret_arn}:username::" },
    { name = "AI_DB_PASSWORD", valueFrom = "${var.rds_master_secret_arn}:password::" },
    { name = "OPENAI_API_KEY", valueFrom = "${var.ai_secret_arn}:OPENAI_API_KEY::" },
    { name = "LANGSMITH_API_KEY", valueFrom = "${var.ai_secret_arn}:LANGSMITH_API_KEY::" }
  ]
}

resource "aws_ecs_task_definition" "spring" {
  family                   = "${var.name_prefix}-spring"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.be_task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([{
    name         = "spring-boot"
    image        = "${var.spring_repository_url}:${var.image_tag}"
    essential    = true
    portMappings = [{ containerPort = 8080, protocol = "tcp" }]
    environment  = local.spring_environment
    secrets      = local.spring_secrets
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.log_group_names.spring
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "fastapi" {
  family                   = "${var.name_prefix}-fastapi"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.ai_task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([{
    name         = "fastapi"
    image        = "${var.ai_repository_url}:${var.image_tag}"
    essential    = true
    command      = ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
    portMappings = [{ containerPort = 8000, protocol = "tcp" }]
    environment  = concat(local.ai_environment, [{ name = "CONTAINER_ROLE", value = "api" }])
    secrets      = local.ai_secrets
    healthCheck = {
      command     = ["CMD-SHELL", "python -m scripts.docker_healthcheck || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 300
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.log_group_names.fastapi
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "celery_worker" {
  family                   = "${var.name_prefix}-celery-worker"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.ai_task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([{
    name        = "celery-worker"
    image       = "${var.ai_repository_url}:${var.image_tag}"
    essential   = true
    command     = ["celery", "-A", "app.celery_app", "worker", "--loglevel=info", "--concurrency=2"]
    environment = concat(local.ai_environment, [{ name = "CONTAINER_ROLE", value = "worker" }])
    secrets     = local.ai_secrets
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.log_group_names.celery_worker
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "celery_beat" {
  family                   = "${var.name_prefix}-celery-beat"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.ai_task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([{
    name        = "celery-beat"
    image       = "${var.ai_repository_url}:${var.image_tag}"
    essential   = true
    command     = ["celery", "-A", "app.celery_app", "beat", "--loglevel=info"]
    environment = concat(local.ai_environment, [{ name = "CONTAINER_ROLE", value = "beat" }])
    secrets     = local.ai_secrets
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.log_group_names.celery_beat
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_service_discovery_service" "fastapi" {
  name = "fastapi"

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {}
}

resource "aws_ecs_service" "spring" {
  name                               = "${var.name_prefix}-spring"
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.spring.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  enable_execute_command             = true
  platform_version                   = "1.4.0"
  health_check_grace_period_seconds  = 300
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.spring_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.spring_target_group_arn
    container_name   = "spring-boot"
    container_port   = 8080
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_service" "fastapi" {
  name                               = "${var.name_prefix}-fastapi"
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.fastapi.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.ai_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.fastapi.arn
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_service" "celery_worker" {
  name                               = "${var.name_prefix}-celery-worker"
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.celery_worker.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.ai_security_group_id]
    assign_public_ip = false
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_ecs_service" "celery_beat" {
  name                               = "${var.name_prefix}-celery-beat"
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.celery_beat.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.ai_security_group_id]
    assign_public_ip = false
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
