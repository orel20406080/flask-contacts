
# variables
variable "VULTR_API_KEY" {}
variable "VULTR_PUBLIC_SSH_KEY" {}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}


terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.19.0"  # או הגרסה העדכנית ביותר
    }
  }
}

provider "vultr" {
  # Configuration options
  api_key = var.VULTR_API_KEY
  rate_limit = 100
  retry_limit = 3
}

data "vultr_ssh_key" "my_ssh_key" { 
  filter {
    name = "name"
    values = [ "orel"]
  }
}

data "vultr_instance" "jenkins" {
  filter {
    name   = "label"
    values = ["jenkins-server"]
  }
}
#data "vultr_instance" "docker" {
#  filter {
#    name   = "label"
#    values = ["docker-server"]
#  }
#}

data "vultr_startup_script" "perpear" {
  filter {
    name   = "name"
    values = [ "perpear" ]
  }
}


output "ip_address_jenkins" {
  value = data.vultr_instance.jenkins.main_ip
}

#output "ip_address_docker" {
#  value = data.vultr_instance.docker.main_ip
#}

resource "vultr_instance" "jenkins" {
  plan          = "vc2-1c-1gb"  # שנה לתוכנית הרצויה
  region        = "tlv"         # שנה לאזור הרצוי
  os_id         = 1743           # Ubuntu 20.04 x64
  label         = "jenkins-server"
  hostname      = "jenkins"
  #tags = [ "ubunutu", "jenkins" ]
  user_data = "${file("prepare.yaml")}"
  ssh_key_ids = [data.vultr_ssh_key.my_ssh_key.id]
  script_id = data.vultr_startup_script.perpear.id
  #user_data     = filebase64("${path.module}/jenkins-startup-script.sh")

 # ssh_key_ids = [
 #   vultr_ssh_key.default.id
  #]

#resource "vultr_ssh_key" "default" {
#  name = "default"
#  ssh_key = file("${var.ssh_public_key_path}")
#}


}
# קובץ Startup Script
#resource "local_file" "jenkins_startup_script" {
#  content = <<-EOF
    #!/bin/bash
    #apt-get update
    #apt-get install -y openjdk-11-jdk wget gnupg2
    #wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
    #sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    #apt-get update
    #apt-get install -y jenkins
    #systemctl start jenkins
    #systemctl enable jenkins
    #apt-get install -y docker.io
    #usermod -aG docker jenkins
    #systemctl restart jenkins
  #EOF
  #filename = "${path.module}/jenkins-startup-script.sh"
#}

