provider "aws" {
  region = "us-west-2"
}
#####Create an VPC Resource############3
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "name" = "${var.env_prefix}-vpc"
  }
}

resource "aws_s3_bucket" "mys3" {
    bucket                      = "vimaltemptesting"
}

module "myapp-subnet" {
  source = "./module/subnet"
  subnet_cidr = var.subnet_cidr
  availability_zone = var.availability_zone
  env_prefix = var.env_prefix
  vpc_cidr = var.vpc_cidr
  route_cidr = var.route_cidr
  vpc_id = aws_vpc.myvpc.id
}

module "myapp-server" {
  source = "./module/webapp"
  vpc_id = aws_vpc.myvpc.id
  env_prefix = var.env_prefix
  instance_type = var.instance_type
  subnet_id = module.myapp-subnet.subnet.id
  availability_zone = var.availability_zone
  ssh = var.ssh
  vpc_cidr = var.vpc_cidr
}

