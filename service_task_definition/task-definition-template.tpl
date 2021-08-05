[  
 {
    "name": "fargate-app",
    "image": "your_image",  
    "cpu": 512,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "environment": [
                {
                    "name": "KIWI_DB_USER",
                    "value": "admin"
                },
                {
                    "name": "KIWI_DB_PASSWORD",
                    "value": "Admin.123"
                },
                {
                    "name": "KIWI_DB_NAME",
                    "value": "kiwidatabase"
                },
                {
                    "name": "KIWI_DB_HOST",
                    "value": "${ENDPOINT}"
                },
                {
                    "name": "KIWI_DB_PORT",
                    "value": "3306"
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
