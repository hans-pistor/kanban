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
