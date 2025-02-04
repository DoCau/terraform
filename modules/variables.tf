variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/26"
}

variable "subnet_public_ip_on_launch" {
  type    = bool
  default = true
}

variable "subnet_cidr_block" {
  type    = string
  default = "10.0.0.0/26"
}

variable "subnet_availability_zone" {
  type    = string
  default = "ap-southeast-1a"
}

variable "route_table_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "internet_route_destination_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ec2_public_key_file_path" {
  type    = string
  default = "keypair/ec2-public-key.pub"
}

variable "ec2_private_key_file_path" {
  type    = string
  default = "keypair/ec2-private-key.pem"
}

variable "ami_id" {
  type    = string
  default = "ami-0672fd5b9210aa093"
}

variable "jenkins_password" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "jenkins_username" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "aws_access_key_id" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "aws_access_key_region" {
  type      = string
  default   = "ap-southeast-1"
  sensitive = true
  nullable  = false
}
