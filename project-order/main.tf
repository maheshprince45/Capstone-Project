
module "vpc" {
  source          = "s3::https://s3.amazonaws.com/my-terraform-modules-bucket-dish/vpc"
  project         = var.name
  vpc_cidr        = var.vpc_cidr
   azs            = ["us-east-1a", "us-east-1b"]
  public_subnet_cidr = var.public_subnets[0]
  tags            = { Project = var.name, Owner = "devops" }
}


module "sg" {
  source           = "s3::https://s3.amazonaws.com/my-terraform-modules-bucket-dish/security-group"
  project          = var.name
  vpc_id           = module.vpc.vpc_id
  allowed_ssh_cidr = "0.0.0.0/0"
  tags             = { Project = var.name, Owner = "devops" }
}


# Get all available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Find AZs that support the selected instance type
data "aws_instance_type_offerings" "available" {
  location_type = "availability-zone"

  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
}

# Pick the first AZ that supports the instance type
locals {
  chosen_az = data.aws_instance_type_offerings.available.instance_type_offerings[0].location
}


module "ec2" {
  source        = "s3::https://s3.amazonaws.com/my-terraform-modules-bucket-dish/ec2"
  project       = "${var.name}-web"
  ami           = "ami-0fb0b230890ccd1e6"
  instance_type = var.instance_type
  subnet_id     = module.vpc.subnet_id
  sg_id         = module.sg.sg_id
  ssh_key_name  = var.key_name
  availability_zone = local.chosen_az
  tags          = { Project = var.name, Owner = "devops" }
}
