# security group for the database
resource "aws_security_group" "db-sg" {
  name        = "db-sg"
  description = "mysql access on port 3306"
  vpc_id      = var.vpc_id 

  ingress {
    description      = "mysql access granted"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "database_security_group"
  }
}

resource "aws_db_subnet_group" "quint-subnet-group" {
  name       = "quint-subnet-group"
  subnet_ids = ["subnet-0a49b00d085bc815a","subnet-06d0a75333f768026"]

  tags   = {
    Name = "quint-subnet-group"
  }

}
 
# creating the rds instance
resource "aws_db_instance" "mydb" {
  engine                  = "mysql"
  engine_version          = "8.0.31"
  multi_az                = true
  identifier              = "mydb"
  username                = "quint1234"
  password                = "quint1234"
  instance_class          = "db.t2.micro"
  allocated_storage       = 200
  db_subnet_group_name    = aws_db_subnet_group.quint-subnet-group.id
  db_name                 = "mydb"
  skip_final_snapshot     = true
  vpc_security_group_ids  = ["sg-0a59b87d59ed727b1"]
}