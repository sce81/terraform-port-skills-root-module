output "skill_blueprints" {
  description = "Created skill blueprints"
  value       = module.skills.skill_blueprints
}

output "skill_entities" {
  description = "Created skill entities"
  value       = module.skills.skill_entities
}

output "skill_identifiers" {
  description = "List of skill identifiers"
  value       = module.skills.skill_identifiers
}

output "skill_metadata_entities" {
  description = "Created skill metadata entities"
  value       = module.skills.skill_metadata_entities
}

output "skill_permissions" {
  description = "Created skill permission assignments"
  value       = module.skills.skill_permissions
}

output "public_skill_permissions" {
  description = "Public (guest) skill permission assignments"
  value       = module.skills.public_skill_permissions
}

output "skill_references" {
  description = "Created skill reference entities"
  value       = module.skills.skill_references
}

output "skill_github_references" {
  description = "Created skill reference entities from GitHub"
  value       = module.skills.skill_github_references
}

output "github_fetched_files" {
  description = "List of .md files discovered and fetched from GitHub"
  value       = module.skills.github_fetched_files
}

output "github_repo_permissions" {
  description = "Applied GitHub repository team permissions"
  value       = module.skills.github_repo_permissions
}
