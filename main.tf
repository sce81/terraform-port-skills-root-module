module "skills_registry" {
  source = "github.com/sce81/terraform-port-skills-registry?ref=v1.0.2"

  skills_registry_owner        = var.skills_registry_owner
  skills_registry_repository   = var.skills_registry_repository
  skills_registry_branch       = var.skills_registry_branch
  skills_registry_path         = var.skills_registry_path
  skills_registry_token        = var.skills_registry_token
  default_skill_location       = var.default_skill_location
  sync_workflow_roles          = var.sync_workflow_roles
  github_ocean_installation_id = var.github_ocean_installation_id
  github_sync_owner            = var.github_sync_owner
  github_sync_repository       = var.github_sync_repository
  github_sync_workflow         = var.github_sync_workflow
}
