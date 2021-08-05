provider "aws" {
  access_key = "your_id"
  secret_key = "your_secret"
  region     = "us-east-1"
}

locals {
  name        = "complete-ecs"
  environment = "dev"

  # This is the convention we use to know what belongs to each other
  ec2_resources_name = "${local.name}-${local.environment}"
}

data "aws_availability_zones" "available" {
  state = "available"
}
####################################
#security group
resource "aws_security_group" "my_ecs_security_group" {
  vpc_id       = module.vpc.vpc_id
  name         = "terraform_ecs_security_group"
  description  = "terraform_ecs_security_group"
}

resource "aws_security_group_rule" "windows_ingress" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_ecs_security_group.id
}
resource "aws_security_group_rule" "container_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_ecs_security_group.id
}

resource "aws_security_group_rule" "container_ingress_eighty_eighty" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_ecs_security_group.id
}

resource "aws_security_group_rule" "container_ingress_mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_ecs_security_group.id
}

resource "aws_security_group_rule" "egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_ecs_security_group.id
}

resource "aws_ecs_cluster" "foo" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled"
  }  

  tags = {
    Environment = local.environment
  }
}
#######################################################################
#RDS
#######################################################################

module "ecs_rds" {
  source = "./ecs_rds"
  subnets = module.vpc.public_subnets
  security_group = [aws_security_group.my_ecs_security_group.id]  
}

########################################################################
##VPC
########################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name

  cidr = "10.12.0.0/16"

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1],data.aws_availability_zones.available.names[2]]
  private_subnets = ["10.12.0.0/23", "10.12.2.0/23","10.12.4.0/23"]
  public_subnets  = ["10.12.6.0/23", "10.12.8.0/23", "10.12.10.0/23"]

  enable_nat_gateway = true # false is just faster
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Environment = local.environment
    Name        = local.name
  }
}

resource "aws_efs_file_system" "foo" {
  creation_token = "terraform-efs"
  performance_mode = "generalPurpose"
  encrypted = true

  tags = {
    Name = "terraform-efs"
  }
}
resource "aws_efs_mount_target" "zone-one" {
  file_system_id = aws_efs_file_system.foo.id
  subnet_id      = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.my_ecs_security_group.id] 
}
resource "aws_efs_mount_target" "zone-two" {
  file_system_id = aws_efs_file_system.foo.id
  subnet_id      = module.vpc.public_subnets[1]
  security_groups = [aws_security_group.my_ecs_security_group.id] 
}
resource "aws_efs_mount_target" "zone-three" {
  file_system_id = aws_efs_file_system.foo.id
  subnet_id      = module.vpc.public_subnets[2]
  security_groups = [aws_security_group.my_ecs_security_group.id] 
}

module "ecs_cluster_task_definition" {
  source = "./ecs_service_task_definition"

  cluster_id = aws_ecs_cluster.foo.id
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  security_group =[aws_security_group.my_ecs_security_group.id] 
  name = local.name
  environment = local.environment
  efs_id = aws_efs_file_system.foo.id
  #db_endpoint = aws_db_instance.terraform_mysql.address
  db_endpoint = module.ecs_rds.endpoint
  cluster_name = var.cluster_name
  service_name = var.service_name
}
