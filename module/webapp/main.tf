####### Create Security Group ############
resource "aws_security_group" "mysecgroup" {
  name = "my-default-sg"
  vpc_id = var.vpc_id

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
  subnet_id = var.subnet_id
  associate_public_ip_address = "true"
  key_name = aws_key_pair.ssh-pair.key_name
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
