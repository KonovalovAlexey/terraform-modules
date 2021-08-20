data "aws_imagebuilder_image" "example" {
  arn = "arn:aws:imagebuilder:us-east-1:aws:image/ubuntu-server-18-lts-x86/x.x.x"
}

resource "aws_imagebuilder_image_recipe" "py_recipe" {
//  block_device_mapping {
//    device_name = "/dev/sda/"
//
//    ebs {
//      delete_on_termination = true
//      volume_size           = 8
//      volume_type           = "gp2"
//    }
//  }

  component {
    component_arn = data.aws_imagebuilder_component.cloudwatch.arn
  }

  component {
    component_arn = aws_imagebuilder_component.user_data.arn
  }

  name         = "PyApp-Recipe"
  parent_image = "arn:aws:imagebuilder:us-east-1:aws:image/ubuntu-server-18-lts-x86/x.x.x"
  version      = "1.0.0"
}