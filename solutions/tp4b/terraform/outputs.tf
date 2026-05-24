output "vpc_id" {
  description = "ID du VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID du subnet public."
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID du subnet privé."
  value       = aws_subnet.private.id
}

output "web_sg_id" {
  description = "ID du Security Group web."
  value       = aws_security_group.web.id
}

output "app_sg_id" {
  description = "ID du Security Group app."
  value       = aws_security_group.app.id
}

output "private_nacl_id" {
  description = "ID du NACL privé."
  value       = aws_network_acl.private.id
}
