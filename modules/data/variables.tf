variable "name_prefix" {
  type = string
}

variable "private_data_subnet_ids" {
  type = list(string)
}

variable "rds_security_group_id" {
  type = string
}

variable "redis_security_group_id" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type = string
}