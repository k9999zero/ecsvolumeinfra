[  
 {
    "name": "fargate-app",
    "image": "your-image-uri",  
    "cpu": 512,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 8080,
        "hostPort": 8080
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