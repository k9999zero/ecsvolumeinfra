variable "codedeploy_role_arn" {
  description = "Codedeploy role arn"
  type        = string  
}

variable "cluster_name" {
  description = "Cluster name"
  type = string
}

variable "service_name" {
  description = "Service name"
  type = string  
}

variable "load_balancer_arn" {
  description = "Load balancer arn"
  type = string  
}
variable "target_group_one_arn" {
  description = "Target group one"
  type = string  
}
variable "target_group_two_arn" {
  description = "Target group two"
  type = string  
}
