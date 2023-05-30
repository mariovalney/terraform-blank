output "database_endpoint" {
  value = aws_rds_cluster.database_cluster.endpoint
}

output "database_reader_endpoint" {
  value = aws_rds_cluster.database_cluster.reader_endpoint
}

output "database_cluster_id" {
  value = aws_rds_cluster.database_cluster.id
}

output "database_master_password" {
  value = random_string.database_master_password.result
}

output "database_name" {
  value = aws_rds_cluster.database_cluster.database_name
}

output "database_username" {
  value = aws_rds_cluster.database_cluster.master_username
}
