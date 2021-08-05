resource "aws_cloudwatch_log_group" "hello_world" {
  name              = "hello_world"
  retention_in_days = 1
}

resource "aws_lb" "alb" {
  name               = "terraform-ecs-lb"     # tf-alb
  internal           = false # false
  load_balancer_type = "application"
  security_groups    = var.security_group
  subnets            = var.subnets
}

resource "aws_lb_target_group" "target-group-one" {
  name = "TG1"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
    matcher = "302"
  }
  target_type = "ip"
  port     = "8080"
  protocol = "HTTP"
  vpc_id   = var.vpc_id    
}

resource "aws_lb_target_group" "target-group-two" {
  name = "TG2"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
    matcher = "302"
  }
  target_type = "ip"
  port     = "8080"
  protocol = "HTTP"
  vpc_id   = var.vpc_id    
}

resource "aws_alb_listener" "alb_listener" {
#count             = "1"
load_balancer_arn = aws_lb.alb.arn
port              = "80"
protocol          = "HTTP"
default_action {
target_group_arn = aws_lb_target_group.target-group-one.arn
type = "forward"
}
}

#######################################################################
#execution task role
#######################################################################

module "ecs_execution_role" {
  source = "../ecs_execution_role"   
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "Terraform_task_definition"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]  
  execution_role_arn = module.ecs_execution_role.role_arn
  cpu = 512
  memory = 1024
  container_definitions = templatefile("${path.module}/task-definition-template.tpl", { ENDPOINT = var.db_endpoint})
  volume {
    name = "terraform-efs"

    efs_volume_configuration {
      file_system_id          = var.efs_id
      root_directory          = "/"
      transit_encryption      = "ENABLED"            
    }
  }
}

resource "aws_ecs_service" "fargate_service" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  launch_type = "FARGATE"
  desired_count = 3

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  load_balancer {
    target_group_arn = aws_lb_target_group.target-group-one.arn
    container_name   = "fargate-app"
    container_port   = 8080
  }    
  network_configuration{
    subnets = [var.subnets[0]]
    security_groups = var.security_group
    assign_public_ip = true
  }
  deployment_controller {
      type = "CODE_DEPLOY"
  }
}


#######################################
#Code deploy role
#######################################
module "ecs_codedeploy_role" {
  source = "../ecs_codedeploy_role"   
}

#######################################
#Code deploy
#######################################
 
module "ecs_codedeploy" {
  source = "../ecs_codedeploy"  
  codedeploy_role_arn = module.ecs_codedeploy_role.codedeploy_role_arn
  cluster_name = var.cluster_name
  service_name = var.service_name
  load_balancer_arn = aws_alb_listener.alb_listener.arn
  target_group_one_arn = aws_lb_target_group.target-group-one.name
  target_group_two_arn = aws_lb_target_group.target-group-two.name
}