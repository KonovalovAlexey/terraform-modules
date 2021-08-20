data "aws_ami" "latest_pyapp" {
  owners      = ["219949372010"]
  most_recent = true
  filter {
    name   = "name"
    values = ["PyApp-Ami-*"]
  }
  depends_on = [aws_imagebuilder_image_pipeline.example]
}

resource "aws_autoscaling_group" "dev_asg" {
  name               = "Python-ASG-Terraform"
//  availability_zones = [data.terraform_remote_state.admin.outputs.az[0], data.terraform_remote_state.admin.outputs.az[1]]
  vpc_zone_identifier = [data.terraform_remote_state.admin.outputs.public_subnet_id_a, data.terraform_remote_state.admin.outputs.public_subnet_id_b]
  desired_capacity   = 2
  max_size           = 2
  min_size           = 0
  launch_template {
    id      = aws_launch_template.example.id
    version = aws_launch_template.example.latest_version
  }

  tag {
    key                 = "Name"
    value               = "PyApp-Ami"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
  depends_on = [aws_launch_template.example]
}

resource "aws_launch_template" "example" {
  name                   = "PyApp-Ami"
  image_id               = data.aws_ami.latest_pyapp.id
  instance_type          = "t2.micro"
  key_name               = data.terraform_remote_state.admin.outputs.key
  vpc_security_group_ids = [data.terraform_remote_state.admin.outputs.sg]
  tags = {
    Name = "PyApp-Ami"
  }
  depends_on = [aws_imagebuilder_image_pipeline.example]
}

