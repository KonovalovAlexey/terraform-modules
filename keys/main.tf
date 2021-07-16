resource "aws_key_pair" "master_key" {
  key_name = var.key_pub
  public_key = file("~/.ssh/id_rsa.pub")
}