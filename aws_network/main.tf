#----------------------------------------------------------
#
# Provision:
#  - VPC
#  - Internet Gateway
#  - XX Public Subnets
#  - XX Private Subnets
#  - XX NAT Gateways in Public Subnets to give Internet access from Private Subnets
#

#----------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "project-terraform-remote"
    key = "dev/network/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-vpc"
  }

}

#Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  vpc_id   = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}


#Create route table in us-east-1
resource "aws_route_table" "internet_route" {
  vpc_id   = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "${var.env}-public-RT"
  }
}

#Overwrite default route table of VPC with our route table entries
resource "aws_route_table_association" "public_routes" {
  count = length(var.public_subnets)
  route_table_id = aws_route_table.internet_route.id
  subnet_id = element(aws_subnet.public_subnets[*].id, count.index )
}
#Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  state    = "available"
}

#Create subnets
resource "aws_subnet" "public_subnets" {
  vpc_id            = aws_vpc.main.id
  count = length(var.public_subnets)
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = element(var.public_subnets, count.index )
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-${count.index + 1}"
  }
}

# -------------------NAT----------------

resource "aws_eip" "nat" {
  count = length(var.private_subnets)
  vpc = true
  tags = {
    Name = "${var.env}-nat-ip-${count.index} +1"
  }
}

resource "aws_nat_gateway" "nat" {
  count = length(var.private_subnets)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = element(aws_subnet.private_subnets[*].id, count.index)
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}

#-----------Private subnets-------------

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets)
  cidr_block = element(var.private_subnets, count.index)
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  tags = {
    Name = "${var.env}-private-${count.index + 1}"
  }
}

resource "aws_route_table" "private_subnets" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.env}-private-RT"
  }
}

resource "aws_route_table_association" "private_routes" {
  count = length(aws_subnet.private_subnets[*].id)
  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id = element(aws_subnet.private_subnets[*].id, count.index)
}