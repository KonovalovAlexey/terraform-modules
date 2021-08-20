data "aws_imagebuilder_component" "cloudwatch" {
  arn = "arn:aws:imagebuilder:us-east-1:aws:component/amazon-cloudwatch-agent-linux/1.0.0"
}

resource "aws_imagebuilder_component" "user_data" {
  data = yamlencode({
    phases = [{
      name = "build"
      steps = [{
        action = "ExecuteBash"
        inputs = {
          commands = ["apt update", "apt-get install -y awscli unzip jq virtualenv",
            "cd /home/ubuntu/", "ARTIFACT=$(aws s3 ls s3://codepipeline-us-east-1-blog/blog-pipeline/BuildArtif/ --recursive | sort | tail -n 1 | awk '{print $4}')",
          "aws s3 cp s3://codepipeline-us-east-1-blog/$ARTIFACT .", "unzip -o ./*", "dpkg -i pyapp.deb"]
        }
        name      = "user_data"
        onFailure = "Continue"
      }]
    }]
    schemaVersion = 1.0
  })

  name     = "PyApp-user_data"
  platform = "Linux"
  version  = "1.0.0"
}