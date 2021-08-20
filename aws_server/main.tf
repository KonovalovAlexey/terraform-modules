# Provision Simple Web Server in specific Subnet

#----------------------------------------------------------
//provider "aws" {
//  region = "us-east-1"
//}

//terraform {
//  backend "s3" {
//    bucket = "project-terraform-remote"
//    key = "dev/webserver/terraform.tfstate"
//    region = "eu-central-1"
//  }
//}
//data "terraform_remote_state" "network" {
//  backend = "s3"
//  config {
//    bucket = "project-terraform-remote"
//    key = "dev/network/terraform.tfstate"
//    region = "eu-central-1"
//  }
//}
//data "aws_ami" "latest_amazon_linux" {
//  owners      = ["amazon"]
//  most_recent = true
//  filter {
//    name   = "name"
//    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
//  }
//}
data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}
//resource "aws_key_pair" "master_key" {
//  key_name = var.key_pub
//  public_key = file("~/.ssh/id_rsa.pub")
//}


data "aws_subnet" "web" {
  id = var.subnet_id
}

resource "aws_security_group" "web" {
  name        = "${var.env}-Security Group"
  description = "${var.env} SecurityGroup"
  vpc_id = data.aws_subnet.web.vpc_id
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = [var.external_ip]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-SecurityGroup"

  }
}

resource "aws_instance" "web_server" {
  count = var.count_web
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              =  var.subnet_id
  associate_public_ip_address = true
  key_name = var.key_pub
  user_data              = file("user_data.sh")
  tags = {
    Name  = "${var.env}-WebServer-${count.index}"
    Stage = var.stage

  }
}
//resource "aws_iam_role_policy" "s3_policy" {
//  name = "s3_policy"
//  role = aws_iam_role.s3_role.id
//
//  # Terraform's "jsonencode" function converts a
//  # Terraform expression result to valid JSON syntax.
//  policy = jsonencode({
//    "Version": "2012-10-17",
//    "Statement": [
//        {
//            Effect: "Allow",
//            Action: "s3:*",
//            Resource: "*"
//        }
//    ]
//  })
//}
//
//resource "aws_iam_instance_profile" "web_profile" {
//  name = "web_profile"
//  role = "${aws_iam_role.s3_role.name}"
//}
//
//resource "aws_iam_role" "s3_role" {
//  name = "s3_role"
//
//  assume_role_policy = jsonencode({
//    Version = "2012-10-17"
//    Statement = [
//      {
//        Action = "sts:AssumeRole"
//        Effect = "Allow"
//        Sid    = ""
//        Principal = {
//          Service = "ec2.amazonaws.com"
//        }
//      },
//    ]
//  })
//}