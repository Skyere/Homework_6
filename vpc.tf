data "aws_availability_zones" "available" {}
data "aws_ami" "latest_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name      = "name"
    values    = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
# ========================================================================= VPC and INTERNET GATEWAY
resource "aws_vpc" "wordpress_vpc" {
  cidr_block  = var.vpc_cidr 
  tags        = {
    Name      = "${var.project}-vpc"
  }
}
resource "aws_internet_gateway" "wordpress_igw" {
  vpc_id  = aws_vpc.wordpress_vpc.id
  tags    = {
    Name  = "${var.project}-igw"
  }
}

# ========================================================================= PUBLIC and PRIVATE SUBNETs
resource "aws_subnet" "wordpress_public_subnet" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  count                   = length(var.public_subnet_cidrs)
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true 
  tags   = {
    Name = "${var.project}-public-${count.index+1}"
  }
}
resource "aws_subnet" "wordpress_private_subnet" {
  vpc_id                  = aws_vpc.wordpress_vpc.id
  count                   = length(var.private_subnet_cidrs)
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags   = {
    Name = "${var.project}-private-${count.index+1}"
  }
}
# ========================================================================= ROUTE TABLE
resource "aws_route_table" "wordpress_rt" {
  vpc_id        = aws_vpc.wordpress_vpc.id
  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.wordpress_igw.id
  }
  tags   = {
    Name = "${var.project}-public-rt"
  }
}

# ========================================================================= ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "wordpress_rt_private" {
  count           = length(aws_subnet.wordpress_private_subnet[*].id)
  route_table_id  = aws_route_table.wordpress_rt_private.id
  subnet_id       = element(aws_subnet.wordpress_private_subnet[*].id, count.index)
}
resource "aws_route_table_association" "wordpress_rt" {
  count           = length(aws_subnet.wordpress_public_subnet[*].id)
  route_table_id  = aws_route_table.wordpress_rt.id
  subnet_id       = element(aws_subnet.wordpress_public_subnet[*].id, count.index)
}
resource "aws_db_subnet_group" "db_subnet" {
  name            = "${var.project}-db_subnet"
  subnet_ids      = aws_subnet.wordpress_private_subnet[*].id
  tags = {
    Name = "${var.project}-db_subnet"
  }
}
