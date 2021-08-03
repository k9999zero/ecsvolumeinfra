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
  }
  target_type = "ip"
  port     = "80"
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
  }
  target_type = "ip"
  port     = "80"
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

resource "aws_ecs_task_definition" "hello_world" {
  family = "hello_world"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]  
  execution_role_arn = "arn:aws:iam::111476791942:role/ecsTaskExecutionRole"
  cpu = 512
  memory = 1024
  container_definitions = templatefile("${path.module}/task-definition-template.tpl", { EFSID = var.efs_id})
  volume {
    name = "terraform-efs"

    efs_volume_configuration {
      file_system_id          = var.efs_id
      root_directory          = "/"
      transit_encryption      = "ENABLED"            
    }
  }
}

resource "aws_ecs_service" "one_service" {
  name            = "one"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.hello_world.arn
  launch_type = "FARGATE"
  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  load_balancer {
    target_group_arn = aws_lb_target_group.target-group-one.arn
    container_name   = "fargate-app"
    container_port   = 80
  }    
  network_configuration{
    subnets = [var.subnets[0]]
    security_groups = var.security_group
    assign_public_ip = true

  }
}

resource "aws_ecs_service" "two_service" {
  name            = "two"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.hello_world.arn
  launch_type = "FARGATE"
  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  load_balancer {
    target_group_arn = aws_lb_target_group.target-group-one.arn
    container_name   = "fargate-app"
    container_port   = 80
  }    
  network_configuration{
    subnets = [var.subnets[1]]
    security_groups = var.security_group
    assign_public_ip = true

  }
}

resource "aws_ecs_service" "three_service" {
  name            = "three"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.hello_world.arn
  launch_type = "FARGATE"
  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  load_balancer {
    target_group_arn = aws_lb_target_group.target-group-one.arn
    container_name   = "fargate-app"
    container_port   = 80
  }    
  network_configuration{
    subnets = [var.subnets[2]]
    security_groups = var.security_group
    assign_public_ip = true

  }
}