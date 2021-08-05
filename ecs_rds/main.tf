resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.subnet_group
  subnet_ids = var.subnets

  tags = {
    Name = "Rds-subnet"
  }
}

resource "aws_db_instance" "terraform_mysql" {
  allocated_storage    = 10
  engine               = var.rds_engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = var.security_group
  provisioner "local-exec" {
  command = "mysql --host=${self.address} --port=${self.port} --user=${self.username} --password=${self.password} < ./ecs_rds/schema.sql"
  }
}