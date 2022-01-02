output "vpc" {
  description = "VPC environ"
  value = module.vpc
}
output "nat_instance" {
  description = "NAT instance for this VPC"
  value = aws_eip.nat
}