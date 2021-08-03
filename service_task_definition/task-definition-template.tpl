[  
 {
    "name": "fargate-app",
    "image": "nginx",  
    "cpu": 512,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "memory": 1000,
    "essential": true,
    "mountPoints": [
                {
                    "sourceVolume": "terraform-efs",
                    "containerPath": "/efs"
                }
            ]
  }
  ]