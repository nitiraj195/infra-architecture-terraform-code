data "aws_availability_zones" "my_az" {
  state             = "available"
  exclude_names = var.blacklisted_az
}

### VPC ###
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "vpc-${var.region}"
  }
}

### Internet Gateway ###
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "np-${var.region}-igw"
  }
}

# Elastic IP for NAT

resource "aws_eip" "nat_eip" {
  count      = length(data.aws_availability_zones.my_az.names)
  vpc        = true
  depends_on = [aws_internet_gateway.default]
}

### NAT Gateway ###
resource "aws_nat_gateway" "nat" {
  count         = length(data.aws_availability_zones.my_az.names)
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.default]
  tags = {
    Name = "np-${var.region}-ngw"
  }
}


### Public Subnet ###
resource "aws_subnet" "public" {
  count                           = length(data.aws_availability_zones.my_az.names)
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
#  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index)
  map_public_ip_on_launch         = true
#  assign_ipv6_address_on_creation = true
  availability_zone               = element(data.aws_availability_zones.my_az.names, count.index)

  tags = {
    Name = "np-${element(data.aws_availability_zones.my_az.names, count.index)}-public"
  }
}

### Route Table for Public Subnet ###
resource "aws_route_table" "public" {
  count  = length(data.aws_availability_zones.my_az.names)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

### Private Subnet ###
resource "aws_subnet" "private" {
  count                           = length(data.aws_availability_zones.my_az.names)
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 10 )
#  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index)
  map_public_ip_on_launch         = false
#  assign_ipv6_address_on_creation = true
  availability_zone               = element(data.aws_availability_zones.my_az.names, count.index)

  tags = {
    Name = "np-${element(data.aws_availability_zones.my_az.names, count.index)}-private"
  }
}

### Route Table for Private Subnet ###
resource "aws_route_table" "private" {
  count  = length(data.aws_availability_zones.my_az.names)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }
}

### Route Table Associations ###
resource "aws_route_table_association" "public" {
  count          = length(data.aws_availability_zones.my_az.names)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(data.aws_availability_zones.my_az.names)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
