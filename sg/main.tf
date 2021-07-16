

resource "aws_security_group" "sg" {
  name        = "${var.env}-Security Group"
  description = "${var.env} SecurityGroup"
  vpc_id = var.vpc_id
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