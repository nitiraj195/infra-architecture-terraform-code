module "ec2-instance" {
  source        = "./modules/ec2"
  region        = "us-east-1"
  instance_type = var.instance_type
  vpc_cidr      = var.vpc_cidr[0]
}

### For Multi Region ###
/*
module "ec2-instance-1" {
  source        = "./modules/ec2"
  region        = "ap-south-1"
  instance_type = var.instance_type
  vpc_cidr      = var.vpc_cidr[1]
}
*/
