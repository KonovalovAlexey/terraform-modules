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
            "cd /home/ubuntu/",
            "ARTIFACT=$(aws codepipeline list-action-executions --pipeline-name blog-pipeline --query 'actionExecutionDetails[0].output.outputArtifacts[0].s3location.key' --region us-east-1 --output text)",
            "aws s3 cp s3://codepipeline-us-east-1-blog/$ARTIFACT .", "unzip -o ./*", "dpkg -i pyapp.deb"]
        }
        name      = "user_data"
        onFailure = "Abort"
      }]
    }]
    schemaVersion = 1.0
  })

  name     = "PyApp-user_data"
  platform = "Linux"
  version  = "1.0.0"
}