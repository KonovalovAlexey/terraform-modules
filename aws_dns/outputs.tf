output "dns" {
  value = aws_route53_record.record.name
}

output "zone_name" {
  value = aws_route53_record.record.zone_id
}