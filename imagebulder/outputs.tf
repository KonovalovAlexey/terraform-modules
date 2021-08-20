output "ami_name" {
  value = data.aws_ami.latest_pyapp.name
}

output "ami_id" {
  value = data.aws_ami.latest_pyapp.id
}
