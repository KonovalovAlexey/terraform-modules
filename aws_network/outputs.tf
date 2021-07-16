
output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}
output "igw" {
  value = aws_internet_gateway.igw.id
}
output "availability_zones" {
  value = data.aws_availability_zones.azs.names
}