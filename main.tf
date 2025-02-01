module "full-infra" {
  source = "./modules"

  jenkins_password = var.JENKINS_PASSWORD
}
