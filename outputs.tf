output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "web_server_1_pub_ip" {
  value = aws_instance.web_server.public_ip
}

output "web_server_1_user_pub_dns" {
  value = "ubuntu@${aws_instance.web_server.public_dns}"
}

output "web_server_2_pub_ip" {
  value = aws_instance.web_server_2.public_ip
}

output "api_server_user_pub_dns" {
  value = [for server in aws_instance.api_server : "ubuntu@${server.public_dns}"]
  # value = "ubuntu@${aws_instance.api_server.public_dns}"
}

output "api_server_pub_ip" {
  value = [for server in aws_instance.api_server : server.public_ip]
  # value = aws_instance.api_server.public_ip
}

output "web_server_2_user_pub_dns" {
  value = "ubuntu@${aws_instance.web_server_2.public_dns}"
}

output "lb_pub_ip" {
  value = aws_lb.front_end.dns_name
}

output "domain_name" {
  value = aws_route53_zone.primary.name
}

output "name_servers" {
  value = aws_route53_zone.primary.name_servers
}

