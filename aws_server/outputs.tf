output "public_ip" {
  value = aws_instance.web_server[*].public_ip
}
output "sg" {
  value = aws_security_group.web.id
}


