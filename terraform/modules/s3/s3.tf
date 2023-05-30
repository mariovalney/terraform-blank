variable "stack_name" {
  type = string
}

variable "public_buckets" {
  type    = list
  default = []
}

variable "private_buckets" {
  type    = list
  default = []
}

########################
#
# Creating S3 buckets
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
#
# On main.tf add as many "public_buckets", "private_buckets" you want
#
########################

# PUBLIC

resource "aws_s3_bucket" "public_buckets" {
  for_each = toset(var.public_buckets)

  bucket   = "${var.stack_name}-${terraform.workspace}-${each.key}-bucket"
  tags     = {
    Name        = var.stack_name
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket_ownership_controls" "public_bucket_controls" {
  for_each = aws_s3_bucket.public_buckets
  bucket = each.value.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_bucket_access_blocks" {
  for_each = aws_s3_bucket.public_buckets
  bucket = each.value.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "public_bucket_acls" {
  for_each = aws_s3_bucket.public_buckets
  bucket = each.value.id

  depends_on = [
    aws_s3_bucket_ownership_controls.public_bucket_controls,
    aws_s3_bucket_public_access_block.public_bucket_access_blocks,
  ]

  acl      = "public-read"
}

# PRIVATE

resource "aws_s3_bucket" "private_buckets" {
  for_each = toset(var.private_buckets)
  bucket   = "${var.stack_name}-${terraform.workspace}-${each.key}-bucket"
  tags     = {
    Name        = var.stack_name
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket_ownership_controls" "private_bucket_controls" {
  for_each = aws_s3_bucket.private_buckets
  bucket = each.value.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "private_bucket_acls" {
  depends_on = [aws_s3_bucket_ownership_controls.private_bucket_controls]
  for_each = aws_s3_bucket.private_buckets
  bucket = each.value.id
  acl      = "private"
}