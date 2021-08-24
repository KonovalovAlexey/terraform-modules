
data "terraform_remote_state" "admin" {
  backend = "s3"
  config = {
    bucket = "codepipeline-us-east-1-blog"
    region = "us-east-1"
    key    = "envadmin"
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "Profile-imagebuilder"
  role = aws_iam_role.imagebuilder_role.name
}

resource "aws_iam_role" "imagebuilder_role" {
  description = "Allows EC2 instances to call AWS services on your behalf"
  name        = "Imagebuilder-role"
  path        = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action : "sts:AssumeRole",
        Principal : {
          "Service" : "ec2.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "imagebuilder_aws_service_role" {
  role       = aws_iam_role.imagebuilder_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSImageBuilderFullAccess"
}

resource "aws_iam_role_policy_attachment" "imagebuilder_profile_role" {
  role       = aws_iam_role.imagebuilder_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

resource "aws_iam_role_policy_attachment" "imagebuilder_s3_role" {
  role       = aws_iam_role.imagebuilder_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "imagebuilder_ssm_role" {
  role       = aws_iam_role.imagebuilder_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "codepipeline_role" {
  role       = aws_iam_role.imagebuilder_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineReadOnlyAccess"
}
resource "aws_imagebuilder_infrastructure_configuration" "instance" {
  description           = "PyApp-infra"
  instance_profile_name = aws_iam_instance_profile.test_profile.name
  instance_types = [
  "t2.micro"]
  key_pair = data.terraform_remote_state.admin.outputs.key
  name     = "PyApp-infra"
  security_group_ids = [
  data.terraform_remote_state.admin.outputs.sg]
  //  sns_topic_arn                 = aws_sns_topic.example.arn
  subnet_id                     = data.terraform_remote_state.admin.outputs.public_subnet_id_a
  terminate_instance_on_failure = true
  logging {
    s3_logs {
      s3_bucket_name = data.terraform_remote_state.admin.config.bucket
      s3_key_prefix  = "logs"
    }
  }

  tags = {
    Name = "Pyapp-infra"
  }
}

output "arn_profile" {
  value = aws_iam_instance_profile.test_profile.arn
}

output "arn_role" {
  value = aws_iam_role.imagebuilder_role.arn
}