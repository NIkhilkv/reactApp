provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "useast1vpc" {
  
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "useast1-vpc"
  }
}
resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.useast1vpc.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "publicsubnet"
  }
}
resource "aws_networkfirewall_firewall" "terraformfw" {
  vpc_id = aws_vpc.useast1vpc.id 
  subnet_mapping {
    subnet_id = aws_subnet.public-subnet.id
  }
  name = "terraform-fw"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.terraform-fw-policy.id
}

resource "aws_networkfirewall_firewall_policy" "terraform-fw-policy" {
  name = "terraform-fw-policy"
  firewall_policy {  
    stateless_default_actions = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:drop"]
  }
}
resource "aws_security_group" "teerraformsg" {
  tags = {
    Name = "teerraform-sg"
  }
  name = "terraform-sg"
  vpc_id = aws_vpc.useast1vpc.id 
}
resource "aws_vpc_security_group_egress_rule" "sg-egress" {
  tags = {
    Name = "sg-egress"
  }
  security_group_id = aws_security_group.teerraformsg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  from_port = -1
  to_port = -1
}
resource "aws_vpc_security_group_ingress_rule" "sg-ingress" {
  tags = {
    Name = "sg-ingress"
  }
  security_group_id = aws_security_group.teerraformsg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  from_port = -1
  to_port = -1
}

resource "aws_network_interface" "terraformni" {
  subnet_id = aws_subnet.public-subnet.id
  #security_groups = aws_security_group.teerraformsg.id
}
resource "aws_instance" "jenkinsserver" {
  tags = {
    Name = "Jenkins-Server"
  }
  ami = "ami-0e731c8a588258d0d"
  associate_public_ip_address = true
  instance_type = "t2.micro"
  # network_interface {
  #   network_interface_id = aws_network_interface.terraformni.id 
  #   device_index = 0
  # }
  subnet_id = aws_subnet.public-subnet.id
}
