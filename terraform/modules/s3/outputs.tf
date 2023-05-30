output "s3_public_buckets" {
  value = aws_s3_bucket.public_buckets
}

output "s3_private_buckets" {
  value = aws_s3_bucket.private_buckets
}
