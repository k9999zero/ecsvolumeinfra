variable "subnet_group" {
  description = "RDS subnet group"
  type        = string
  default     = "subnet_group"
}
variable "rds_engine" {
  description = "RDS engine"
  type = string
  default     = "mysql"
}
variable "engine_version" {
  description = "RDS engine version"
  type = string
  default     = "5.7"
}
variable "instance_class" {
  description = "RDS instance type"
  type = string
  default     = "db.t2.micro"
}
variable "db_username" {
  description = "RDS username"
  type = string
  default     = "admin"
}
variable "db_password" {
  description = "RDS password"
  type = string
  default     = "Admin.123"
}
variable "db_name" {
  description = "RDS db name"
  type = string
  default     = "kiwidb"
}
variable "subnets" {
  description = "Subnets id"
  type = list(string)
}
variable "security_group" {
  description = "Security group id"
  type = list(string)
}