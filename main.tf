locals {
  registry_path_prefix = trim(var.skills_registry_path, "/")
  github_auth_headers = var.skills_registry_token == "" ? {
    Accept = "application/vnd.github+json"
    } : {
    Accept        = "application/vnd.github+json"
    Authorization = "Bearer ${var.skills_registry_token}"
  }
}

# Fetch the whole Git tree so a skill can live at any depth in the registry.
data "http" "skills_registry_tree" {
  url = "https://api.github.com/repos/${var.skills_registry_owner}/${var.skills_registry_repository}/git/trees/${var.skills_registry_branch}?recursive=1"

  request_headers = local.github_auth_headers

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Unable to read ${var.skills_registry_owner}/${var.skills_registry_repository}. Check the repository, branch, and skills_registry_token."
    }
  }
}

locals {
  registry_tree = jsondecode(data.http.skills_registry_tree.response_body).tree

  skill_files = {
    for file in local.registry_tree :
    file.path => file
    if file.type == "blob" &&
    endswith(lower(file.path), ".md") &&
    (local.registry_path_prefix == "" || startswith(file.path, "${local.registry_path_prefix}/"))
  }
}

data "http" "skill_documents" {
  for_each = local.skill_files

  url = "https://raw.githubusercontent.com/${var.skills_registry_owner}/${var.skills_registry_repository}/${var.skills_registry_branch}/${each.key}"

  request_headers = local.github_auth_headers

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Unable to read ${each.key} from the skills registry."
    }
  }
}

locals {
  skill_documents = {
    for path, document in data.http.skill_documents : path => {
      front_matter = try(yamldecode(regexall("(?s)^---\\s*\\n(.*?)\\n---", document.response_body)[0][0]), {})
      instructions = trimspace(replace(document.response_body, "/(?s)^---\\s*\\n.*?\\n---\\s*\\n?/", ""))
      source_url   = "https://github.com/${var.skills_registry_owner}/${var.skills_registry_repository}/blob/${var.skills_registry_branch}/${path}"
    }
  }
}

# The single Port Skill Registry blueprint. Import `skill` before the first
# apply if it already exists in Port.
resource "port_blueprint" "skill" {
  identifier  = "skill"
  title       = "Skill"
  icon        = "Learn"
  description = "Reusable instructions synchronized from the GitHub Skills Registry."

  properties = {
    string_props = {
      description = {
        title       = "Description"
        description = "What the skill does and when to use it"
        required    = true
      }
      instructions = {
        title       = "Instructions"
        description = "Instructions from the source SKILL.md"
        format      = "markdown"
        required    = true
      }
      location = {
        title       = "Location"
        description = "Target installation scope"
        enum        = ["global", "project"]
        required    = true
      }
    }
    array_props = {
      references = {
        title        = "References"
        description  = "Source registry location for this skill"
        object_items = {}
      }
      assets = {
        title        = "Assets"
        description  = "Reserved for skill assets"
        object_items = {}
      }
    }
  }
}

resource "port_entity" "skill" {
  for_each = local.skill_documents

  blueprint = port_blueprint.skill.identifier
  identifier = try(
    each.value.front_matter.name,
    lower(replace(basename(each.key), ".md", "")),
  )
  title = try(
    each.value.front_matter.title,
    trimspace(try(regexall("(?m)^#\\s+(.+)$", each.value.instructions)[0][0], replace(title(replace(basename(each.key), ".md", "")), "_", " "))),
  )

  properties = {
    description = try(
      each.value.front_matter.description,
      trimspace(try(regexall("(?m)^#\\s+(.+)$", each.value.instructions)[0][0], "Instructions synchronized from ${each.key}.")),
    )
    instructions = each.value.instructions
    location     = try(each.value.front_matter.location, var.default_skill_location)
    references = [{
      path        = each.key
      content     = each.value.instructions
      description = each.value.source_url
    }]
    assets = []
  }
}
