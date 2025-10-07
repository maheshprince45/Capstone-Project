module "vpc" {
  source          = "../aws-modules/vpc"
  name            = var.name
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
}

module "ec2" {
  source         = "../aws-modules/ec2"
  name           = "${var.name}-web"
  subnet_id      = module.vpc.public_subnet_ids[0]
  vpc_id         = module.vpc.vpc_id
  instance_type  = var.instance_type
  key_name       = var.key_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "instance_public_ip" {
  value = module.ec2.public_ip
}
