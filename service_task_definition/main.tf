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

resource "aws_iam_role_policy" "ecs-execute-task-policy" {
  name = "ecs_execution_policy"
  role = aws_iam_role.role.id  
  policy = jsonencode(
  {
    Version = "2012-10-17",
    Statement = [
        {
            Effect = "Allow",
            Action = [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            Resource = "*"
        }
    ]
  }
  )
}

resource "aws_iam_role" "role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_ecs_task_definition" "hello_world" {
  family = "hello_world"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]  
  execution_role_arn = aws_iam_role.role.arn
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

resource "aws_ecs_service" "fargate_service" {
  name            = "three"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.hello_world.arn
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
#Code deploy
#######################################

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.ecs_codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

resource "aws_iam_role" "ecs_codedeploy_role" {
  name = "ecs-codedeploy-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_codedeploy_app" "example" {
  compute_platform = "ECS"
  name             = "comple-ecs-codedeploy"
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name               = aws_codedeploy_app.example.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "comple-ecs-codedeploy-group"
  service_role_arn       = aws_iam_role.ecs_codedeploy_role.arn  

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = "white-hart"
    service_name = "three"
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_alb_listener.alb_listener.arn]
      }

      target_group {
        name = aws_lb_target_group.target-group-one.name
      }

      target_group {
        name = aws_lb_target_group.target-group-two.name
      }
    }
  }
}