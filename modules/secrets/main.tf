resource "aws_secretsmanager_secret" "backend" {
  name                    = "bp20/prod/backend"
  description             = "BP20 production backend secrets"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret" "ai" {
  name                    = "bp20/prod/ai"
  description             = "BP20 production AI service secrets"
  recovery_window_in_days = 7
}