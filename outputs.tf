output "webapp_i_id" {
  value = aws_instance.webapp_blog.id
}

output "webapp_region" {
  value = var.region
}

output "webapp_sg_id" {
  value = aws_security_group.webapp_blog.id
}

output "elastic_ip" {
  value = aws_eip.webapp_blog.public_ip
}