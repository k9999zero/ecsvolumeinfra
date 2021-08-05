variable "cluster_name" {
  description = "Cluster name"
  type = string
  default = "Terraform_cluster"
}

variable "service_name" {
  description = "Service name"
  type = string
  default = "Terraform_fargate_service"
}