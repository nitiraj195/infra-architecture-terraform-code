output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public[*].id
}
output "private_subnet_id" {
  value = aws_subnet.private[*].id
}

output "ngw_public_ip" {
  value = aws_nat_gateway.nat[*].public_ip
}
