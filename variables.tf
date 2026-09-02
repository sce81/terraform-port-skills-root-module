variable "skills_source" {
  description = "GitHub source for skills module"
  type        = string
  default     = "github.com/sce81/terraform-port-skills"
}

variable "skills_ref" {
  description = "Git reference (tag/branch) for skills module"
  type        = string
  default     = "1.0.0"
}

variable "skills" {
  description = "List of skills to create"
  type = list(object({
    identifier   = string
    title        = string
    description  = string
    instructions = string
    relations    = optional(map(string), {})
  }))
  default = []
}

variable "skill_metadata" {
  description = "Metadata configuration for skills"
  type = list(object({
    skill_identifier = string
    owner            = string
    team             = string
    category         = string
    use_cases        = list(string)
    status           = string
    version          = string
    created_at       = string
    updated_at       = string
  }))
  default = []
}

variable "skill_permissions" {
  description = "Permission configurations for skills by team and role"
  type = list(object({
    team_identifier      = string
    role_identifier      = string
    skill_identifier     = string
    actions              = list(string)
  }))
  default = []
}

variable "publicly_accessible_skills" {
  description = "List of skill identifiers to make publicly accessible (guest role)"
  type        = list(string)
  default     = []
}

variable "skill_references" {
  description = "Reference documentation for skills"
  type = list(object({
    skill_identifier     = string
    reference_identifier = string
    title                = string
    reference_type       = string
    url                  = string
    documentation        = string
    owner                = string
  }))
  default = []
}

variable "github_docs_repo_enabled" {
  description = "Whether to fetch documentation from a GitHub repository"
  type        = bool
  default     = false
}

variable "github_docs_repo_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = ""
}

variable "github_docs_repo_name" {
  description = "GitHub repository name"
  type        = string
  default     = ""
}

variable "github_docs_repo_token" {
  description = "GitHub personal access token for private repository access"
  type        = string
  sensitive   = true
  default     = ""
}

variable "github_docs_repo_path" {
  description = "Path within the repository where skill documentation is stored"
  type        = string
  default     = "skills"
}

variable "github_docs_repo_branch" {
  description = "Git branch to fetch files from"
  type        = string
  default     = "main"
}

variable "github_repo_team_permissions" {
  description = "Team permissions for all skill references from GitHub repository"
  type = map(object({
    team_identifier = string
    role_identifier = string
    actions         = list(string)
  }))
  default = {}
}
