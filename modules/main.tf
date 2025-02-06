#---------------------------VPC--------------------------------
resource "aws_vpc" "master-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name         = "master-vpc"
    created_time = module.created_timestamp.created_timestamp
  }
}
#---------------------------VPC--------------------------------



#---------------------------SUBNET--------------------------------
resource "aws_subnet" "master-subnet" {
  vpc_id                  = aws_vpc.master-vpc.id
  map_public_ip_on_launch = var.subnet_public_ip_on_launch
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.subnet_availability_zone
  tags = {
    Name         = "master-subnet"
    subnet_az    = "${var.subnet_availability_zone}"
    created_time = module.created_timestamp.created_timestamp
  }

  depends_on = [aws_vpc.master-vpc]
}
#---------------------------SUBNET--------------------------------



#---------------------------ROUTE_TABLE--------------------------------
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.master-vpc.id
  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_internet_gateway.internet-gw.id
  # }

  tags = {
    Name         = "public-route-table"
    created_time = module.created_timestamp.created_timestamp
  }

  depends_on = [aws_subnet.master-subnet]
}

resource "aws_route_table_association" "route-tb-association" {
  subnet_id      = aws_subnet.master-subnet.id
  route_table_id = aws_route_table.public-route-table.id

  depends_on = [aws_subnet.master-subnet, aws_route_table.public-route-table]
}
#---------------------------ROUTE_TABLE--------------------------------



#---------------------------INTERNET_GATE_WAY--------------------------------
resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.master-vpc.id
  tags = {
    Name         = "internet-gw"
    created_time = module.created_timestamp.created_timestamp
  }
}

resource "aws_route" "internet-route" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = var.route_table_cidr
  gateway_id             = aws_internet_gateway.internet-gw.id
}
#---------------------------INTERNET_GATE_WAY--------------------------------



#---------------------------SECURITY_GROUP--------------------------------
resource "aws_security_group" "ec2-security-group" {
  name   = "ec2-security-group"
  vpc_id = aws_vpc.master-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.local_machine_cidr]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [local.local_machine_cidr]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.local_machine_cidr]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    created_time = module.created_timestamp.created_timestamp
  }
}
#---------------------------SECURITY_GROUP--------------------------------



#---------------------------EC2--------------------------------
/*
data "aws_ami" "machine-image" {
  filter {
    name   = "name"
    values = ["Amazon Linux 2 *"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    id = ""
  }

  owners = ["137112412989"]
}
*/
resource "aws_instance" "jenkins-master-ec2" {
  ami             = var.ami_id
  instance_type   = var.ec2_instance_type
  key_name        = aws_key_pair.ec2-public-key.key_name
  security_groups = [aws_security_group.ec2-security-group.id]
  subnet_id       = aws_subnet.master-subnet.id
  tags = {
    Name         = "jenkins-master-ec2"
    created_time = module.created_timestamp.created_timestamp
  }

  user_data = <<-EOF
  #!/bin/bash
  set -eux
  #export userdir=$(pwd)
  export userdir="/home/ubuntu"

  #Update system without recommend installations
  echo ">>>STEP 1<<<"
  sudo apt update  
  sudo apt upgrade -y --no-install-recommends

  #Install addtional packages
  echo ">>>STEP 2<<<"
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common tree

  #Download & add Docker GPG key
  echo ">>>STEP 3<<<"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  #Add Docker to apt list
  echo ">>>STEP 4<<<"
  sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

  #Update system after adding Docker to apt
  echo ">>>STEP 5<<<"
  sudo apt-get update

  #Install Docker and plugins
  echo ">>>STEP 6<<<"
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  #Add more configs to Docker
  echo ">>>STEP 7<<<"
  sudo usermod -aG docker ubuntu
  sudo systemctl enable docker

  #Add file docker-compose, change include content & rename file to .yml
  echo ">>>STEP 8<<<"
  cat <<EOT > /home/ubuntu/docker-compose
  services:
    jenkins:
      image: docker.io/bitnami/jenkins:2
      ports:
        - '8080:8080'
      environment:
        - JENKINS_USERNAME=${var.jenkins_username}
        - JENKINS_PASSWORD=${var.jenkins_password}
        - JENKINS_PLUGINS=github,github-pullrequest,pipeline-github,pipeline-model-definition,pipeline-stage-view,ssh-slaves,configuration-as-code
        - CASC_JENKINS_CONFIG=/bitnami/jenkins/casc_configs/jenkins.yaml
        - JENKINS_OPTS=--httpPort=8080 --httpsPort=-1
      volumes:
        - './jenkins_data:/bitnami/jenkins'
        - './jenkins.yml:/bitnami/jenkins/casc_configs/jenkins.yaml'
  EOT
  mv "$userdir/docker-compose" "$userdir/docker-compose.yml"
  
  #Add directory to store Jenkins data
  echo ">>>STEP 8<<<"
  mkdir -p "$userdir/jenkins_data"
  sudo chmod 777 -R "$userdir/jenkins_data"

  #Add file jenkins.yml to store data of plugin JENKINS-configuration-as-code
  echo ">>>STEP 8.1<<<"
  cat <<EOT > "$userdir/jenkins"
  jenkins:
    securityRealm: legacy
    authorizationStrategy: loggedInUsersCanDoAnyThing

  credentials:
    system:
      domainCredentials:
        - credentials:
            - usernamePassword:
                scope: GLOBAL
                id: "github_credential_for_jenkins_files"
                username: "${var.github_username}"
                password: "${var.github_password}"
                description: "jenkins pipelines take github credentials here"
            - basicSSHUserPrivateKey:
                scope: GLOBAL
                id: ssh_credentials_for_worker_node
                username: ${var.ssh_username}
                passphrase: ${var.ssh_passphrase}
                description: "SSH private passphrase & key for SSH connection to worker"
                privateKeySource:
                  directEntry:
                    privateKey: "${var.ssh_private_key}"
  EOT
  mv "$userdir/jenkins" "$userdir/jenkins.yml"
  sudo chmod 777 "$userdir/jenkins.yml"

  #Start docker
  echo ">>>STEP 10<<<"
  cd "$userdir"
  docker compose up -d
  EOF
}

resource "aws_instance" "jenkins-worker-ec2" {
  ami             = var.ami_id
  instance_type   = var.ec2_instance_type
  key_name        = aws_key_pair.ec2-public-key.key_name
  security_groups = [aws_security_group.ec2-security-group.id]
  subnet_id       = aws_subnet.master-subnet.id
  tags = {
    Name         = "jenkins-worker-ec2"
    created_time = module.created_timestamp.created_timestamp
  }

  user_data = <<-EOF
  #!/bin/bash
  set -eux
  #export userdir=$(pwd)
  export userdir="/home/ubuntu"

  #Update system without recommend installations
  echo ">>>STEP 1<<<"
  sudo apt update
  sudo apt upgrade -y --no-install-recommends

  #Install addtional packages
  echo ">>>STEP 2<<<"
  sudo apt-get install -y python3 python3-pip unzip apt-transport-https ca-certificates curl software-properties-common openjdk-21-jre-headless tree

  #Install GIT SCM
  echo ">>>STEP 2.1<<<"
  sudo apt-get install -y git

  #Download & install aws-cli
  echo ">>>STEP 3<<<"
  curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o "awscliv2.zip"

  #Unzip downloaded file
  echo ">>>STEP 4<<<"
  unzip awscliv2.zip -d "$userdir"

  #Install aws-cli
  echo ">>>STEP 5<<<"
  sudo chmod 777 -R "$userdir/aws"
  sudo "$userdir/aws/install"

  #Add gpg key for terraform, add terraform to apt, use apt to install terraform
  echo ">>>STEP 6<<<"
  wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install -y terraform

  #Update system after adding aws-cli & terraform
  echo ">>>STEP 7<<<"
  sudo apt-get update

  #Add credentials to aws cli
  echo ">>>STEP 8<<<"
  cd "$userdir"
  mkdir -p "$userdir/.aws"
  cd "$userdir/.aws"
  cat <<EOT > credentials
  [default]
  aws_access_key_id = ${var.aws_access_key_id}
  aws_secret_access_key = ${var.aws_secret_access_key}
  EOT
  cat <<EOT > config
  [default]
  region = ${var.aws_access_key_region}
  output = json
  EOT
  cd "$userdir"
  mkdir -p "$userdir/var"
  mkdir -p "$userdir/var/jenkins"
  sudo chmod 777 -R "$userdir/var/jenkins"

  echo "Done!"
  EOF
}
#---------------------------EC2--------------------------------



#---------------------------KEYPAIR--------------------------------
resource "tls_private_key" "ec2-key-pair-generator" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ec2-public-key" {
  key_name   = "ec2-public-key"
  public_key = tls_private_key.ec2-key-pair-generator.public_key_openssh
  tags = {
    created_time = module.created_timestamp.created_timestamp
  }
}

resource "local_file" "ec2-public-key" {
  filename = var.ec2_public_key_file_path
  content  = aws_key_pair.ec2-public-key.public_key
}

resource "local_file" "ec2-private-key" {
  filename = var.ec2_private_key_file_path
  content  = tls_private_key.ec2-key-pair-generator.private_key_openssh
}
#---------------------------KEYPAIR--------------------------------



#---------------------------UTILITY--------------------------------
module "created_timestamp" {
  source = "../utils"
}

data "http" "get_local_machine_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  local_machine_ip   = chomp(data.http.get_local_machine_ip.response_body)
  local_machine_cidr = "${local.local_machine_ip}/32"
}

# output "local_machine_cidr" {
#   value = local.local_machine_cidr
# }
#---------------------------UTILITY--------------------------------
