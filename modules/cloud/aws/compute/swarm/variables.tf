variable "private_key_path" {
  description = "The path to the private key file."
  type        = string
}

variable "number_of_nodes" {
  description = "Number of nodes to create"
  type        = number
  default     = 3
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "aws_access_key_id" {
  description = "The AWS access key ID."
  type        = string
  sensitive   = true
}
variable "aws_secret_access_key" {
  description = "The AWS secret access key."
  type        = string
  sensitive   = true
}
variable "gh_pat" {
  description = "The GitHub Personal Access Token (PAT)."
  type        = string
  sensitive   = true
}
variable "gh_owner" {
  description = "The GitHub owner of the repo."
  type        = string
}
variable "age_key_path" {
  description = "The path to the SOPS age key file."
  type        = string
}
variable "compose_file" {
  type        = string
  description = "Docker Compose file"
  default     = "../../docker-compose.yaml"
}

variable "image_to_deploy" {
  type        = string
  description = "Image to deploy"
  default     = "ghcr.io/hans-pistor/kanban:latest"
}
