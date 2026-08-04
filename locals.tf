locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = "BP20"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Team        = "BP20"
  }
}