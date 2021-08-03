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

variable "efs_id" {
  description = "Efs id"
  type = string
}
