# Terraform Port Skills Child Module
# Repository: https://github.com/sce81/terraform-port-skills
# Documentation: See Child-Modules/terraform-port-skills/README.md
module "skills" {
  source = "${var.skills_source}?ref=${var.skills_ref}"

  skills                       = var.skills
  skill_metadata               = var.skill_metadata
  skill_permissions            = var.skill_permissions
  publicly_accessible_skills   = var.publicly_accessible_skills
  skill_references             = var.skill_references
  github_docs_repo_enabled     = var.github_docs_repo_enabled
  github_docs_repo_owner       = var.github_docs_repo_owner
  github_docs_repo_name        = var.github_docs_repo_name
  github_docs_repo_token       = var.github_docs_repo_token
  github_docs_repo_path        = var.github_docs_repo_path
  github_docs_repo_branch      = var.github_docs_repo_branch
  github_repo_team_permissions = var.github_repo_team_permissions
}
