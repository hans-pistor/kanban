variable "repository" {
  description = "Name of the github repository"
  type        = string
}

variable "github_owner" {
  description = "Owner where the GibHub repository resides."
  type        = string
}

variable "status_checks" {
  description = "List of required status checks that must pass"
  type        = list(string)
  default     = []
}
