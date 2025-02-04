module "full-infra" {
  source = "./modules"

  jenkins_password      = var.JENKINS_PASSWORD
  jenkins_username      = var.JENKINS_USERNAME
  aws_access_key_id     = var.AWS_ACCESS_KEY_ID
  aws_secret_access_key = var.AWS_SECRET_ACCESS_KEY
}
