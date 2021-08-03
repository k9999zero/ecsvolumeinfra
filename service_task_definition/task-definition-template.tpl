[  
 {
    "name": "fargate-app",
    "image": "111476791942.dkr.ecr.us-east-1.amazonaws.com/kiwitcms/kiwi:latest",  
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