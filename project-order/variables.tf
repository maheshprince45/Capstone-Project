variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}
variable "aws_profile" {
  description = "AWS CLI profile"
  default     = "default"
}
variable "name" {
  description = "Project name"
  default     = "dish"
}
variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.10.0.0/16"
}
variable "public_subnets" {
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}
variable "azs" {
  default = ["us-east-1a", "us-east-1b"]
}
variable "instance_type" {
  default = "t3.micro"
}
variable "key_name" {
  default = null
}
