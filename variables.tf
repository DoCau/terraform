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
