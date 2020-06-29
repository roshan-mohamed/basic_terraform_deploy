provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Define a default vpc to instance
resource "aws_default_vpc" "default" {}

# create a security group and add rules
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

# create 2 instance's and use security group that created prior
resource "aws_instance" "test-server" {
  count = 2

  ami           = "ami-2757f631"
  instance_type = "t2.nano"
  key_name = "terraform"
  vpc_security_group_ids = [
  aws_security_group.allow_tls.id
  ]
}

# eip association for server 1
resource "aws_eip_association" "test-server"{
instance_id = aws_instance.test-server.0.id
allocation_id = aws_eip.ip.id
}
# create Elastic IP
resource "aws_eip" "ip" {
    vpc = true
}
