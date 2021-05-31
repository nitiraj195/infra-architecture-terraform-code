data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name      = "name"
    values    = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name      = "owner-alias"
    values    = ["amazon"]
  }
}

resource "aws_instance" "web" {
  count         = length(data.aws_availability_zones.my_az.names) * 1
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  vpc_security_group_ids = [aws_security_group.default.id, aws_vpc.vpc.default_security_group_id]
  tags = {
    Name = "Test"
  }
}

resource "aws_instance" "database" {
  count         = length(data.aws_availability_zones.my_az.names) * 1
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  vpc_security_group_ids = [aws_security_group.db_sg.id, aws_vpc.vpc.default_security_group_id]
  tags = {
    Name = "Test Database Instance"
  }
}

resource "aws_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.public_sg_ports
    iterator = port
    content {
    from_port = port.value
    to_port = port.value
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.vpc.id
  lifecycle {
    create_before_destroy = true
  }

  dynamic "ingress" {
    for_each = var.private_sg_ports
    iterator = port
    content {
    from_port = port.value
    to_port = port.value
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
