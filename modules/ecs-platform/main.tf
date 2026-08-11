resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

data "aws_iam_role" "execution" {
  name = var.execution_role_name
}

resource "aws_iam_role_policy_attachment" "execution_managed" {
  role       = data.aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "execution_secrets" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      var.backend_secret_arn,
      var.ai_secret_arn,
      var.rds_master_secret_arn
    ]
  }
}

resource "aws_iam_role_policy" "execution_secrets" {
  name   = "${var.name_prefix}-read-secrets"
  role   = data.aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.execution_secrets.json
}

data "aws_iam_role" "ai_task" {
  name = var.ai_task_role_name
}

data "aws_iam_role" "be_task" {
  name = var.be_task_role_name
}

data "aws_iam_policy_document" "ai_task_assets" {
  statement {
    actions = ["s3:ListBucket"]

    resources = [var.ai_model_bucket_arn]
  }

  statement {
    actions = ["s3:GetObject"]

    resources = [
      "${var.ai_model_bucket_arn}/models/v1/*",
      "${var.ai_model_bucket_arn}/rag/v1/*",
      "${var.ai_model_bucket_arn}/data/*"
    ]
  }

  statement {
    actions = ["s3:GetObject", "s3:PutObject"]

    resources = [
      "${var.ai_model_bucket_arn}/feedback/v1/*",
      "${var.ai_model_bucket_arn}/bandit/v1/*",
      "${var.ai_model_bucket_arn}/logs/*"
    ]
  }

  statement {
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]

    resources = ["${var.ai_model_bucket_arn}/uploads/v1/*"]
  }
}

resource "aws_iam_role_policy" "ai_task_assets" {
  name   = "${var.name_prefix}-ai-assets"
  role   = data.aws_iam_role.ai_task.id
  policy = data.aws_iam_policy_document.ai_task_assets.json
}

data "aws_iam_policy_document" "task_application" {
  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = ["${var.ai_model_bucket_arn}/uploads/v1/*"]
  }

  statement {
    actions = ["s3:GetObject", "s3:PutObject"]

    resources = ["${var.product_image_bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "be_task_application" {
  name   = "${var.name_prefix}-application-access"
  role   = data.aws_iam_role.be_task.id
  policy = data.aws_iam_policy_document.task_application.json
}

resource "aws_cloudwatch_log_group" "spring" {
  name              = "/ecs/${var.name_prefix}/spring-boot"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "fastapi" {
  name              = "/ecs/${var.name_prefix}/fastapi"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "celery_worker" {
  name              = "/ecs/${var.name_prefix}/celery-worker"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "celery_beat" {
  name              = "/ecs/${var.name_prefix}/celery-beat"
  retention_in_days = 14
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name = "bp20.local"
  vpc  = var.vpc_id
}
