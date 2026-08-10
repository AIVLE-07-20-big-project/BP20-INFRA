output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "spring_security_group_id" {
  value = aws_security_group.spring.id
}

output "ai_security_group_id" {
  value = aws_security_group.ai.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "redis_security_group_id" {
  value = aws_security_group.redis.id
}