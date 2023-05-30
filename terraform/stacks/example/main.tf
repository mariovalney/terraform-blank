########################
#
# Main file
# https://medium.com/hackernoon/stop-manually-provisioning-aws-for-laravel-use-terraform-instead-11b8b360617c
#
########################

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  backend "local" {
    workspace_dir = "backend"
  }
}

// VPC
module "vpc" {
  source     = "./modules/vpc"
  stack_name = var.stack_name
}

// S3
module "s3" {
  source            = "./modules/s3"
  stack_name        = var.stack_name
  public_buckets    = ["public"]
  private_buckets   = ["private"]
}

// SES
# module "ses" {
#   source     = "./modules/ses"
#   stack_name = var.stack_name
#   domain     = var.stack_domain
# }

// DATABASE
# module "database" {
#   source            = "./modules/database"
#   stack_name        = var.stack_name
#   database_name     = var.stack_name
#   database_type     = "postgresql"
#   database_instance = "db.t2.micro"
#   database_size     = 20
#   database_multi_az = false
# }
