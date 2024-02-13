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

  key_name   = "east1latest"
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
            sudo usermod -aG sudo jenkins
            sudo systemctl enable jenkins
            sudo systemctl start jenkins
            sudo systemctl status jenkins
            EOF
#   provisioner "local-exec" {
#     command = ""
                   
#   }
}
output "jenkins-public_ip" {
  value = aws_instance.jenkins.public_ip
}

resource "null_resource" "get_file_content" {
   depends_on = [aws_instance.jenkins]
   provisioner "local-exec" {
    #command = "ssh -i C:/Users/Nandu/Downloads/east1latest.pem ec2-user@${aws_instance.jenkins.public_ip} sudo cat /var/lib/jenkins/secrets/initialAdminPassword > output/jenkins-text.txt"
    command = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i C:/Users/Nandu/Downloads/east1latest.pem ec2-user@${aws_instance.jenkins.public_ip} sudo cat /var/lib/jenkins/secrets/initialAdminPassword > output/jenkins-text.txt"
    #command = "ssh -o StrictHostKeyChecking=no -i C:/Users/Nandu/Downloads/east1latest.pem ec2-user@${aws_instance.jenkins.public_ip} sudo cat /var/lib/jenkins/secrets/initialAdminPassword > output/jenkins-text.txt"
    interpreter = ["D:\\software\\Git\\bin\\bash.exe", "-c"]
    
   }
 }
 output "result" {
  value = null_resource.get_file_content.triggers
}
resource "null_resource" "print_public_ip" {
  provisioner "local-exec" {
    command = "echo Public IP: ${aws_instance.jenkins.public_ip}"
  }
}

# resource "aws_instance" "nexus" {
#   tags = {
#     Name = "nexus"
#   }
#   ami           = "ami-0e731c8a588258d0d"
#   instance_type = "t2.micro"
#   key_name   = "east1latest"
#   subnet_id  = "subnet-039a81e0b004a679c"
#   vpc_security_group_ids = ["sg-01bd9cb2946c97e51"] 
#   user_data = <<-EOF
#     #!/bin/bash
#     sudo yum update -y 
#     sudo yum install wget -y
    
#     sudo yum install -y java-1.8.0-amazon-corretto.x86_64
#     sudo wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz
#     #sudo wget -O nexus-3.tar.gz https://download.sonatype.com/nexus/3/nexus-3.59.0-01-unix.tar.gz
#     sudo tar -xvf nexus.tar.gz
#     sudo mv nexus-3* nexus
#     sudo adduser nexus
#     sudo chown -R nexus:nexus nexus
#     sudo chown -R nexus:nexus sonatype-work
#     sudo sed -i 's/#run_as_user=""/run_as_user="nexus"/' /nexus/bin/nexus.rc
#     sudo ./nexus/bin/nexus start
#     EOF
# }
# output "nexus-public_ip" {
#   value = aws_instance.nexus.public_ip
# }
# resource "aws_instance" "sonar" {
#   tags = {
#     Name = "sonar"
#   }
#   ami           = "ami-0e731c8a588258d0d"
#   instance_type = "t2.micro"

#   key_name   = "east1latest"
#   subnet_id  = "subnet-039a81e0b004a679c"

#   vpc_security_group_ids = ["sg-01bd9cb2946c97e51"] 
# }
