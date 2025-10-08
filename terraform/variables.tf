variable "project"                { default = "financeme" }
variable "region"                 { default = "us-east-1" }
variable "vpc_cidr"               { default = "10.0.0.0/16" }
variable "public_subnet_cidr"     { default = "10.0.1.0/24" }
variable "instance_type"          { default = "t3.medium" }
variable "allowed_ssh_cidr"       { default = "0.0.0.0/0" } # tighten to YOUR_IP/32 in real use
variable "ssh_key_name"           { default = "Capstone" }





