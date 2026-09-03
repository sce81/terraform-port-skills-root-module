variable "skills_registry_owner" {
  description = "GitHub organization or user that owns the source skills registry"
  type        = string
  default     = "sce81"
}

variable "skills_registry_repository" {
  description = "GitHub repository containing Markdown skill files"
  type        = string
  default     = "Port-Skills-Registry"
}

variable "skills_registry_branch" {
  description = "Registry branch to synchronize"
  type        = string
  default     = "main"
}

variable "skills_registry_path" {
  description = "Optional directory under which Markdown skill files are discovered; empty searches the whole repository"
  type        = string
  default     = "terraform-skills"
}

variable "skills_registry_token" {
  description = "Fine-grained GitHub token with read-only Contents access to the skills registry"
  type        = string
  sensitive   = true
}

variable "default_skill_location" {
  description = "Default Port skill installation scope when the SKILL.md front matter omits location"
  type        = string
  default     = "global"

  validation {
    condition     = contains(["global", "project"], var.default_skill_location)
    error_message = "default_skill_location must be global or project."
  }
}

variable "sync_workflow_roles" {
  description = "Port roles allowed to trigger the skills registry sync"
  type        = list(string)
  default     = ["Member"]
}

variable "github_ocean_installation_id" {
  description = "Installed GitHub Ocean integration identifier used by the Port workflow"
  type        = string
  default     = "github-ocean"
}

variable "github_sync_owner" {
  description = "GitHub organization or user that owns the repository containing the sync workflow"
  type        = string
  default     = "sce81"
}

variable "github_sync_repository" {
  description = "GitHub repository containing this Terraform root module and its sync workflow"
  type        = string
  default     = "terraform-port-skills-root-module"
}

variable "github_sync_workflow" {
  description = "GitHub Actions workflow filename dispatched by Port"
  type        = string
  default     = "sync-port-skills.yml"
}
