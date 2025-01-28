output "vpc_id" {
  value = aws_vpc.master-vpc.id
}

output "subnet_id" {
  value = aws_subnet.master-subnet.id
}

output "jenkins_master_ec2_public_ip" {
  value = aws_instance.jenkins-master-ec2.public_ip
}

output "jenkins_worker_ec2_public_ip" {
  value = aws_instance.jenkins-worker-ec2.public_ip
}

output "security_groups_egress_configs" {
  value = aws_security_group.ec2-security-group.egress
}

output "security_groups_ingress_configs" {
  value = aws_security_group.ec2-security-group.ingress
}
