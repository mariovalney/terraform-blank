output "database_endpoint" {
  value = aws_db_instance.database_instance.endpoint
}

output "database_instance_id" {
  value = aws_db_instance.database_instance.id
}

output "database_name" {
  value = aws_db_instance.database_instance.name
}

output "database_username" {
  value = aws_db_instance.database_instance.username
}

output "database_password" {
  value = random_string.database_master_password.result
}
