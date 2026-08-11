output "service_names" {
  value = {
    spring        = aws_ecs_service.spring.name
    fastapi       = aws_ecs_service.fastapi.name
    celery_worker = aws_ecs_service.celery_worker.name
    celery_beat   = aws_ecs_service.celery_beat.name
  }
}

output "task_definition_arns" {
  value = {
    spring        = aws_ecs_task_definition.spring.arn
    fastapi       = aws_ecs_task_definition.fastapi.arn
    celery_worker = aws_ecs_task_definition.celery_worker.arn
    celery_beat   = aws_ecs_task_definition.celery_beat.arn
  }
}
