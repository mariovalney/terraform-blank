variable "stack_name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_type" {
  type = string
}

variable "database_instance" {
  type = string
}

variable "database_size" {
  type = number
}

variable "database_multi_az" {
  type    = bool
}

locals {
  databases = {
    postgresql = {
      engine  = "postgresql"
      version = "11.9"
      port    = "5432"
    }
  }
}

########################
#
# Creating CLASSIC DATABASE
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
#
# Use database_name to set DB name reusing this module.
# Use database_type to set the type. Check local.databases
#
########################

# Master Password
resource "random_string" "database_master_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Final DB snapshot when this DB cluster is deleted.
resource "random_string" "final_snapshot_id" {
  length  = 24
  special = false
}

# DATABASE
resource "aws_db_instance" "database_instance" {
  engine                    = local.databases[var.database_type].engine
  engine_version            = local.databases[var.database_type].version
  port                      = local.databases[var.database_type].port
  allocated_storage         = var.database_size
  instance_class            = var.database_instance
  name                      = "${var.database_name}_${terraform.workspace}"
  username                  = var.database_type
  password                  = random_string.database_master_password.result
  multi_az                  = var.database_multi_az
  final_snapshot_identifier = "l${random_string.final_snapshot_id.result}l"
  apply_immediately         = true
  storage_encrypted         = false
  backup_window             = "02:00-03:00"
  maintenance_window        = "wed:03:00-wed:04:00"
  deletion_protection       = (terraform.workspace == "production")
  tags                      = {
    Name        = var.stack_name
    Environment = terraform.workspace
    Engine      = var.database_type
    Database    = var.database_name
  }
}
