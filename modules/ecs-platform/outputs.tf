output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "execution_role_arn" {
  value = data.aws_iam_role.execution.arn
}

output "ai_task_role_arn" {
  value = data.aws_iam_role.ai_task.arn
}

output "be_task_role_arn" {
  value = data.aws_iam_role.be_task.arn
}

output "namespace_id" {
  value = aws_service_discovery_private_dns_namespace.this.id
}

output "log_group_names" {
  value = {
    spring        = aws_cloudwatch_log_group.spring.name
    fastapi       = aws_cloudwatch_log_group.fastapi.name
    celery_worker = aws_cloudwatch_log_group.celery_worker.name
    celery_beat   = aws_cloudwatch_log_group.celery_beat.name
  }
}
