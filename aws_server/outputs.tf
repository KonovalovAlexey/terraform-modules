output "web_server_public_ip" {
  value = aws_instance.web_server[*].public_ip
}

output "aws_key_pub" {
  value = aws_key_pair.master_key.key_name
}