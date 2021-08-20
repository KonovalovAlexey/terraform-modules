resource "aws_imagebuilder_distribution_configuration" "dist_config" {
  name = "Python-dist-config"

  distribution {
    ami_distribution_configuration {
      ami_tags = {
        Name = "PyApp-Ami"
      }

      name = "PyApp-Ami-{{ imagebuilder:buildDate }}"

      //      launch_permission {
      //        user_ids = [
      //          "123456789012"]
      //      }
    }

    region = "us-east-1"
  }
}