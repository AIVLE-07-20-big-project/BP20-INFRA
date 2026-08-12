resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for public ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

resource "aws_security_group" "spring" {
  name        = "${var.name_prefix}-spring-sg"
  description = "Security group for Spring Boot ECS tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-spring-sg"
  }
}

resource "aws_security_group" "ai" {
  name        = "${var.name_prefix}-ai-sg"
  description = "Security group for FastAPI and Celery tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-ai-sg"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Security group for RDS MySQL"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-rds-sg"
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-redis-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-redis-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Temporary HTTP access before CloudFront restriction"
}

resource "aws_vpc_security_group_ingress_rule" "spring_from_alb" {
  security_group_id            = aws_security_group.spring.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

# AI 리뷰 분석 Agent가 Spring의 /api/internal/** 을 Cloud Map 주소로 역호출한다.
resource "aws_vpc_security_group_ingress_rule" "spring_from_ai" {
  security_group_id            = aws_security_group.spring.id
  referenced_security_group_id = aws_security_group.ai.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  description                  = "AI internal API callback"
}

resource "aws_vpc_security_group_ingress_rule" "fastapi_from_spring" {
  security_group_id            = aws_security_group.ai.id
  referenced_security_group_id = aws_security_group.spring.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_spring" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.spring.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_ai" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.ai.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_spring" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = aws_security_group.spring.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_ai" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = aws_security_group.ai.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_spring" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.spring.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "spring_all" {
  security_group_id = aws_security_group.spring.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "ai_all" {
  security_group_id = aws_security_group.ai.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "redis_all" {
  security_group_id = aws_security_group.redis.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}