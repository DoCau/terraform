module "full-infra" {
  source = "./modules"

  jenkins_password      = var.JENKINS_PASSWORD
  jenkins_username      = var.JENKINS_USERNAME
  aws_access_key_id     = var.AWS_ACCESS_KEY_ID
  aws_secret_access_key = var.AWS_SECRET_ACCESS_KEY
  github_username       = var.GITHUB_USERNAME
  github_password       = var.GITHUB_PASSWORD
  ssh_username          = var.SSH_USERNAME
  ssh_passphrase        = var.SSH_PASSPHRASE
  ssh_private_key       = var.SSH_PRIVATE_KEY
}
