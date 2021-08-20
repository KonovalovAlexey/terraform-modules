provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "codepipeline-us-east-1-blog"
    region = "us-east-1"
    key    = "envadmin"
  }
}
module "key" {
  source = "../keys"
}
module "vpc" {
  source = "../aws_network"
  private_subnets = ""
}
module "server" {
  source = "../aws_server"
  key_pub = module.key.aws_key_pub
  subnet_id = module.vpc.public_subnet_id_a
  vpc_id = module.vpc.vpc_id
}

output "public_ip" {
  value = module.server.public_ip
}

output "key" {
  value = module.key.aws_key_pub
}

output "sg" {
  value = module.server.sg
}

output "public_subnet_id_a" {
  value = module.vpc.public_subnet_id_a
}
output "public_subnet_id_b" {
  value = module.vpc.public_subnet_id_b
}
output "az" {
  value = module.vpc.availability_zones
}