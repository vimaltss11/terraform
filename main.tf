provider "aws" {
  region = "us-west-2"
}

#### Data block to fetch ami id of linux from aws ####### 
data "aws_ami" "amazonlinux" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

#####Create an VPC Resource############3
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "name" = "${var.env_prefix}-vpc"
  }
}

###### Create subnet ########
resource "aws_subnet" "my-subnet" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.subnet_cidr
  availability_zone = var.availability_zone
    tags = {
    "name" = "${var.env_prefix}-subnet-1"
  }
}

####### Create Security Group ############
resource "aws_security_group" "mysecgroup" {
  name = "my-default-sg"
  vpc_id = aws_vpc.myvpc.id

  ingress  {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
    "name" = "${var.env_prefix}-sg"
  }
}

###### Create IGW #######
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.myvpc.id
    tags = {
    "name" = "${var.env_prefix}-igw"
  }
}


##### Create Route Table #########
resource "aws_route_table" "my-route" {
  vpc_id = aws_vpc.myvpc.id

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

####Create aws key pair###
resource "aws_key_pair" "ssh-pair" {
  key_name = "myapp-key"
  public_key = file(var.ssh)
}

##### Create Aws Instance####

resource "aws_instance" "my-instance" {
  ami = data.aws_ami.amazonlinux.id
  availability_zone = var.availability_zone
  instance_type = var.instance_type
  security_groups = [ aws_security_group.mysecgroup.id ]
  subnet_id = aws_subnet.my-subnet.id
  associate_public_ip_address = "true"
  key_name = "myapp-key"
    tags = {
    "name" = "${var.env_prefix}-server"
  }

  user_data = <<EOF
                #!/bin/bash
                sudo yum update -y && sudo yum install -y docker
                sudo systemctl start docker
                sudo usermod -aG docker ec2-user
                sudo docker run -p 80:80 nginx
              EOF
}


