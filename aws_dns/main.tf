data "aws_route53_zone" "dns" {
  name = var.dns-name
}


resource "aws_route53_record" "record" {
  name = join(".", [var.web_name, data.aws_route53_zone.dns.name])
  type = "A"
  zone_id = data.aws_route53_zone.dns.zone_id
  ttl = "300"
  records = [var.public_ip]
}