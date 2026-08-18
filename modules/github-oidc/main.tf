locals {
  oidc_url = "token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://${local.oidc_url}"
  client_id_list = ["sts.amazonaws.com"]
}

# Repository별 prod Environment 로만 제한하는 Trust Policy 생성 헬퍼
data "aws_iam_policy_document" "assume" {
  for_each = toset(["BP20-FE", "BP20-BE", "BP20-AI"])

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    # GitHub 조직에 "불변 식별자(immutable identifier)"가 켜져 있으면 sub 에 조직·저장소의
    # 숫자 ID가 붙어 repo:ORG@123/REPO@456:environment:prod 형태가 된다. 두 형식을 모두
    # 허용하려고 StringLike 를 쓴다(와일드카드가 없는 값은 정확히 일치할 때만 통과한다).
    # 조직명·저장소명·Environment 는 그대로 고정되므로 다른 저장소는 여전히 거부된다.
    condition {
      test     = "StringLike"
      variable = "${local.oidc_url}:sub"
      values = [
        "repo:${var.github_org}/${each.key}:environment:prod",
        "repo:${var.github_org}@*/${each.key}@*:environment:prod",
      ]
    }
  }
}

# ---------- Frontend 배포 Role ----------

resource "aws_iam_role" "frontend_deploy" {
  name               = "${var.name_prefix}-gha-frontend-deploy"
  assume_role_policy = data.aws_iam_policy_document.assume["BP20-FE"].json
}

data "aws_iam_policy_document" "frontend_deploy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [var.frontend_bucket_arn]
  }

  statement {
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${var.frontend_bucket_arn}/*"]
  }

  statement {
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [var.cloudfront_distribution_arn]
  }
}

resource "aws_iam_role_policy" "frontend_deploy" {
  name   = "${var.name_prefix}-gha-frontend-deploy"
  role   = aws_iam_role.frontend_deploy.id
  policy = data.aws_iam_policy_document.frontend_deploy.json
}

# ---------- Backend / AI 공통 배포 정책 ----------

data "aws_iam_policy_document" "ecs_deploy" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = var.ecr_repository_arns
  }

  statement {
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]
    resources = ["*"]

    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = [var.ecs_cluster_arn]
    }
  }

  statement {
    actions   = ["iam:PassRole"]
    resources = var.task_role_arns
  }
}

resource "aws_iam_role" "backend_deploy" {
  name               = "${var.name_prefix}-gha-backend-deploy"
  assume_role_policy = data.aws_iam_policy_document.assume["BP20-BE"].json
}

resource "aws_iam_role_policy" "backend_deploy" {
  name   = "${var.name_prefix}-gha-backend-deploy"
  role   = aws_iam_role.backend_deploy.id
  policy = data.aws_iam_policy_document.ecs_deploy.json
}

resource "aws_iam_role" "ai_deploy" {
  name               = "${var.name_prefix}-gha-ai-deploy"
  assume_role_policy = data.aws_iam_policy_document.assume["BP20-AI"].json
}

resource "aws_iam_role_policy" "ai_deploy" {
  name   = "${var.name_prefix}-gha-ai-deploy"
  role   = aws_iam_role.ai_deploy.id
  policy = data.aws_iam_policy_document.ecs_deploy.json
}