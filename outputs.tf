output "skill_entities" {
  description = "Port skill entities synchronized from SKILL.md files"
  value = {
    for path, skill in port_entity.skill :
    path => skill.identifier
  }
}

output "skill_identifiers" {
  description = "Identifiers synchronized to the Port Skill Registry"
  value       = values(port_entity.skill)[*].identifier
}

output "skills_registry_sync_workflow_identifier" {
  description = "Port workflow identifier that dispatches the registry sync"
  value       = port_workflow.sync_skills_registry.identifier
}
