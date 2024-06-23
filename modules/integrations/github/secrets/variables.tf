variable "secrets" {
  description = "A map of secrets to be created"
  type        = map(string)
}

variable "github_owner" {
  description = "The name of the github organization"
  type        = string
}

variable "repository" {
  description = "The name of the github repository"
  type        = string
}
