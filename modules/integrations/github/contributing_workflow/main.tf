terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.41.0"
    }
  }
}

provider "github" {
  owner = var.github_owner
}

resource "github_branch_protection" "main" {
  repository_id = var.repository

  pattern        = "main"
  lock_branch    = true
  enforce_admins = false

  required_status_checks {
    strict   = true
    contexts = var.status_checks
  }

  required_pull_request_reviews {
    require_code_owner_reviews      = false
    required_approving_review_count = 0
  }
}
