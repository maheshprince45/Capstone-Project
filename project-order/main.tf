
module "vpc" {
  source          = "s3::https://s3.amazonaws.com/my-terraform-modules-bucket-dish/vpc"
  project         = var.name
  vpc_cidr        = var.vpc_cidr
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


module "ec2" {
  source        = "s3::https://s3.amazonaws.com/my-terraform-modules-bucket-dish/ec2"
  project       = "${var.name}-web"
  ami           = "ami-0261755bbcb8c4a84"
  instance_type = var.instance_type
  subnet_id     = module.vpc.subnet_id
  sg_id         = module.sg.sg_id
  ssh_key_name  = var.key_name
  tags          = { Project = var.name, Owner = "devops" }
}
