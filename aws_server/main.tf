# Provision Simple Web Server in specific Subnet

#----------------------------------------------------------

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "null_resource" "key" {
  count = var.key_pub
}
resource "aws_key_pair" "master_key" {
  key_name = var.key_pub
  public_key = file("~/.ssh/id_rsa.pub")
  depends_on = [null_resource.key]
}
data "aws_subnet" "web" {
  id = var.subnet_id
}
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = var.subnet_id
  associate_public_ip_address = true
  key_name = aws_key_pair.master_key.key_name
  user_data              = <<EOF
#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>WebServer with IP: $myip </h2><br>" > /var/www/html/index.html
sudo service httpd start
chkconfig httpd on
EOF
  tags = {
    Name  = "${var.env}-WebServer"

  }
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