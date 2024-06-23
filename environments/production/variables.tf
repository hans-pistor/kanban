variable "aws_access_key_id" {
  description = "The AWS access key ID"
  type        = string
}

variable "aws_secret_access_key" {
  description = "the AWS secret access key"
  type        = string
}

variable "age_key" {
  description = "the age key for sops encryption tool"
  type        = string
  sensitive   = true
}

variable "gh_pat" {
  description = "A GitHub personal access token, used to login to the github container repo"
  type        = string
  sensitive   = true
}
