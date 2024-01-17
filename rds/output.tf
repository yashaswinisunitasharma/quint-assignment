output "db_sg" {
    value = aws_security_group.db-sg.id
  
}

output "mydb_id" {
    value = aws_db_instance.mydb.id
}

output "mydb_endpoint" {
    value = aws_db_instance.mydb.endpoint
}

output "quint-subnet-group" {
  value = aws_db_subnet_group.quint-subnet-group.id
}