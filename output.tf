output "alb_dns_name" {
  value = aws_lb.rails.dns_name
}

output "route53_record" {
  value = aws_route53_record.alb_record.fqdn
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}