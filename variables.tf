variable "JENKINS_PASSWORD" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "JENKINS_USERNAME" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "AWS_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "AWS_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "GITHUB_USERNAME" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "GITHUB_PASSWORD" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "SSH_USERNAME" {
  type      = string
  nullable  = false
  sensitive = true
}

variable "SSH_PASSPHRASE" {
  type      = string
  nullable  = true
  sensitive = true
  default   = ""
}

variable "SSH_PRIVATE_KEY" {
  type      = string
  nullable  = false
  sensitive = true
}

