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

variable "subnet_ids" {
  type = list
}

variable "vpc_id" {}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

locals {
  databases = {
    mysql      = {
      engine  = "aurora-mysql"
      version = "5.7.12"
      port    = "3306"
    }
    postgresql = {
      engine  = "aurora-postgresql"
      version = "11.9"
      port    = "5432"
    }
  }
}

########################
#
# Creating AURORA DATABASE
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
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

# Subnet and security group to this database
resource "aws_db_subnet_group" "database_subnet_group" {
  name       = "database_subnet_group_${var.database_name}_${terraform.workspace}"
  subnet_ids = var.subnet_ids
  tags     = {
    Name        = var.stack_name
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "db_security_group" {
  vpc_id = data.aws_vpc.vpc.id
  tags     = {
    Name        = var.stack_name
    Environment = terraform.workspace
  }

  ingress {
    from_port   = local.databases[var.database_type].port
    to_port     = local.databases[var.database_type].port
    protocol    = "TCP"
    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block
    ]
  }
}

# Finally the cluster
resource "aws_rds_cluster" "database_cluster" {
  engine                       = local.databases[var.database_type].engine
  engine_version               = local.databases[var.database_type].version
  database_name                = "${var.database_name}_${terraform.workspace}"
  master_username              = var.database_type
  master_password              = random_string.database_master_password.result
  backup_retention_period      = 14
  preferred_backup_window      = "02:00-03:00"
  preferred_maintenance_window = "wed:03:00-wed:04:00"
  db_subnet_group_name         = aws_db_subnet_group.database_subnet_group.name
  final_snapshot_identifier    = "l${random_string.final_snapshot_id.result}l"
  vpc_security_group_ids       = [
    aws_security_group.db_security_group.id,
  ]
  tags                         = {
    Name        = var.stack_name
    Environment = terraform.workspace
    Engine      = var.database_type
    Database    = var.database_name
  }
}

resource "aws_rds_cluster_instance" "database_cluster_instance" {
  count                = 1
  instance_class       = var.database_instance
  cluster_identifier   = aws_rds_cluster.database_cluster.id
  db_subnet_group_name = aws_db_subnet_group.database_subnet_group.name
  publicly_accessible  = false
  engine               = local.databases[var.database_type].engine
  engine_version       = local.databases[var.database_type].version
  tags                 = {
    Name        = var.stack_name
    Environment = terraform.workspace
    Engine      = var.database_type
    Database    = var.database_name
  }
}
