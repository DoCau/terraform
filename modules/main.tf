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
}
#---------------------------EC2--------------------------------



#---------------------------EC2--------------------------------
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
#---------------------------EC2--------------------------------



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
