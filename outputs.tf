output "subnet_id" {
  value = module.full-infra.vpc_id
}

output "jenkins_master_ec2_public_ip" {
  value = module.full-infra.jenkins_master_ec2_public_ip
}

output "jenkins_worker_ec2_public_ip" {
  value = module.full-infra.jenkins_worker_ec2_public_ip
}

output "security_groups_egress_configs" {
  value = module.full-infra.security_groups_egress_configs
}

output "security_groups_ingress_configs" {
  value = module.full-infra.security_groups_ingress_configs
}
