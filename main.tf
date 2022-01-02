data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "${var.vpcname}"
  cidr                 = "10.99.0.0/18"
  azs                  = data.aws_availability_zones.available.zone_ids
  public_subnets       = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets      = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  database_subnets     = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]
  enable_dns_hostnames = true
}

module "nat" {
  source = "int128/nat-instance/aws"

  name                        = "vpc-${var.vpcname}-nat-instance"
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
  key_name                    = var.nat_instance_key_name
}

resource "aws_eip" "nat" {
  network_interface = module.nat.eni_id
  tags = {
    "Name" = "vpc-${var.vpcname}-nat-instance-eip"
  }
}