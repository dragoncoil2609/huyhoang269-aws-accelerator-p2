resource "aws_security_group" "rds" {
  name        = "k8s-aws-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL traffic from K8s Node"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "k8s-aws-rds-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  tags = {
    Name = "k8s-aws-rds-subnet-group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier           = "k8s-aws-mysql"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "mylabdb"
  username             = "admin"
  password             = "root12345"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false

  tags = {
    Name = "k8s-aws-rds-mysql"
  }
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.mysql.endpoint
}
