###### Create subnet ########
resource "aws_subnet" "my-subnet" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet_cidr
  availability_zone = var.availability_zone
    tags = {
    "name" = "${var.env_prefix}-subnet-1"
  }
}

###### Create IGW #######
resource "aws_internet_gateway" "my-igw" {
  vpc_id = var.vpc_id
    tags = {
    "name" = "${var.env_prefix}-igw"
  }
}

##### Create Route Table #########
resource "aws_route_table" "my-route" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.route_cidr
    gateway_id = aws_internet_gateway.my-igw.id
  }
    tags = {
    "name" = "${var.env_prefix}-route-table"
  }
}

#####Create route table association #######
resource "aws_route_table_association" "route-association" {
  subnet_id = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-route.id
}