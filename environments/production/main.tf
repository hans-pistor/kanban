module "swarm" {
  source           = "../../modules/cloud/aws/compute/swarm"
  private_key_path = "${path.module}/private_key.pem"
  region           = "us-west-2"
  account_id       = "647664114478"
}

module "repository_secrets" {
  source = "../../modules/integrations/github/secrets"
  secrets = {
    "PRIVATE_KEY"           = module.swarm.private_key,
    "AWS_ACCESS_KEY_ID"     = var.aws_access_key_id,
    "AWS_SECRET_ACCESS_KEY" = var.aws_secret_access_key,
    "AGE_KEY"               = var.age_key,
    "GH_PAT"                = var.gh_pat
  }
  repository   = "kanban"
  github_owner = "hans-pistor"
}

module "contributing_workflow" {
  source       = "../../modules/integrations/github/contributing_workflow"
  repository   = "kanban"
  github_owner = "hans-pistor"
  status_checks = [
    "Check, Compile, Test"
  ]
}

output "ssh_commands" {
  value = module.swarm.ssh_commands
}
