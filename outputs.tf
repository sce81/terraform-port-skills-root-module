output "skill_entities" {
  description = "Port skill entities synchronized from Markdown files"
  value       = module.skills_registry.skill_entities
}

output "skill_identifiers" {
  description = "Identifiers synchronized to the Port Skill Registry"
  value       = module.skills_registry.skill_identifiers
}

output "skills_registry_sync_workflow_identifier" {
  description = "Port workflow identifier that dispatches the registry sync"
  value       = module.skills_registry.sync_workflow_identifier
}

output "skills_registry_child_module_release" {
  description = "Immutable release of the child module consumed by this root module"
  value       = local.skills_registry_child_module_release
}
