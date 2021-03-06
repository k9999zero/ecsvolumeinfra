variable "cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}
variable "vpc_id" {
  description = "The vpc ID"
  type = string
}
variable "subnets" {
  description = "Subnets id"
  type = list(string)
}
variable "security_group" {
  description = "Security group id"
  type = list(string)
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "db_endpoint"{
  description = "rds url"
  type = string
}

variable "efs_id" {
  description = "Efs id"
  type = string
}

variable "cluster_name" {
  description = "Cluster name"
  type = string
}

variable "service_name" {
  description = "Service name"
  type = string  
}