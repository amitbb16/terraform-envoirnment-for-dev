terraform {
  required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "5.31.0"
      }
  }
}

provider "aws" {
  profile = "amit"
  region  = "us-west-2"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "dev-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


resource "aws_instance" "app_server" {
  ami           = "ami-008fe2fc65df48dac"
  instance_type = "t2.micro"
  key_name      = "terraformproject"
  security_groups = [ aws_security_group.allow_http.name ]
  tags = {
    Name       = "Machine1FromTerraform"
    Type       = "AppServer"
    Webserver  = "Nginx"
    managed-by = "Terraform"
  }
  user_data     =  "${file("install.sh")}"

}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

  ingress {
    description      = "HTTP nginx webserver"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH Server"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}