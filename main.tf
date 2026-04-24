module "ec2" {
  source                = "./modules/ec2"
  vpc_id                = var.vpc_id
  private_subnet_ids    = var.private_subnet_ids
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  alb_security_group_id = module.alb.alb_security_group_id
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = var.vpc_id
  public_subnet_ids = var.public_subnet_ids
  instance_ids      = module.ec2.instance_ids
}