module "full-infra" {
  source = "./modules"

  jenkins_password = var.JENKINS_PASSWORD
  jenkins_username = var.JENKINS_USERNAME
}
