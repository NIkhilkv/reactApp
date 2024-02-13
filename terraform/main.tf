provider "aws" {
  region = "us-east-1"
}

variable "existing_subnet_id" {
  type    = string
  default = "" 
}

resource "aws_default_vpc" "default" {}

resource "aws_instance" "jenkins" {
  tags = {
    Name = "jenkins"
  }
  ami           = "ami-0e731c8a588258d0d"
  instance_type = "t2.micro"

  key_name   = "east1"
  subnet_id  = "subnet-039a81e0b004a679c"

  vpc_security_group_ids = ["sg-01bd9cb2946c97e51"] 
  user_data = <<-EOF
            #!/bin/bash
            sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
            sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
            sudo yum upgrade
            sudo yum install -y java-11-amazon-corretto
            sudo yum install jenkins -y
            sudo systemctl daemon-reload
            sudo systemctl enable jenkins
            sudo systemctl start jenkins
            sudo systemctl status jenkins
            EOF
}

resource "aws_instance" "nexus" {
  tags = {
    Name = "nexus"
  }
  ami           = "ami-0e731c8a588258d0d"
  instance_type = "t2.micro"
  key_name   = "east1"
  subnet_id  = "subnet-039a81e0b004a679c"
  vpc_security_group_ids = ["sg-01bd9cb2946c97e51"] 
user_data = <<-EOF
sudo yum update -y 
sudo yum install wget -y
sudo yum install -y java-11-amazon-corretto
sudo wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz
sudo tar -xvf nexus.tar.gz
sudo mv nexus-3* nexus
sudo adduser nexus
sudo chown -R nexus:nexus nexus
sudo chown -R nexus:nexus sonatype-work
sudo sed -i 's/#run_as_user=""/run_as_user="nexus"/' /home/ec2-user/nexus/bin/nexus.rc
sudo tee /etc/systemd/system/nexus.service <<EOL
[Unit]
Description=Nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
ExecStart=/home/ec2-user/nexus/bin/nexus start
ExecStop=/home/ec2-user/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOL

sudo chkconfig nexus on
sudo systemctl start nexus
EOF
}

# resource "aws_instance" "sonar" {
#   tags = {
#     Name = "sonar"
#   }
#   ami           = "ami-0e731c8a588258d0d"
#   instance_type = "t2.micro"

#   key_name   = "east1"
#   subnet_id  = "subnet-039a81e0b004a679c"

#   vpc_security_group_ids = ["sg-01bd9cb2946c97e51"] 
# }
