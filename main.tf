module "skills_registry" {
  source = "github.com/sce81/terraform-port-skills-registry?ref=v1.0.0"

  skills_registry_owner         = var.skills_registry_owner
  skills_registry_repository    = var.skills_registry_repository
  skills_registry_branch        = var.skills_registry_branch
  skills_registry_path          = var.skills_registry_path
  skills_registry_token         = var.skills_registry_token
  default_skill_location        = var.default_skill_location
  sync_workflow_roles           = var.sync_workflow_roles
  github_ocean_installation_id = var.github_ocean_installation_id
  github_sync_owner             = var.github_sync_owner
  github_sync_repository        = var.github_sync_repository
  github_sync_workflow          = var.github_sync_workflow
}

# Temporary state migrations. Remove after a successful remote apply verifies
# the resources are managed through the v1.0.0 child module.
moved {
  from = port_blueprint.skill
  to   = module.skills_registry.port_blueprint.skill
}

moved {
  from = port_entity.skill
  to   = module.skills_registry.port_entity.skill
}

moved {
  from = port_workflow.sync_skills_registry
  to   = module.skills_registry.port_workflow.sync_skills_registry
}
