# Port Skills Registry Sync

Synchronizes Markdown skill files from a GitHub repository into Port's shared `skill`
blueprint. Each source file becomes one Port skill entity.

## What it manages

- The shared Port `skill` blueprint: `description`, `instructions`, `location`,
  `references`, and `assets`.
- One `skill` entity per discovered Markdown file.
- The `sync_port_skills_registry` Port workflow, which dispatches this module's
  GitHub Actions sync job through GitHub Ocean.

Skills removed from GitHub are removed from Port on the next Terraform apply.

## Source repository

Defaults:

```hcl
skills_registry_owner      = "sce81"
skills_registry_repository = "Port-Skills-Registry"
skills_registry_branch     = "main"
skills_registry_path       = "terraform-skills"
```

`skills_registry_path` is optional. Set it to empty to discover Markdown files
at every depth in the repository.

Files may use YAML front matter to explicitly set `name`, `title`, `description`,
and `location`:

```markdown
---
name: incident-response
description: Coordinate investigation and recovery during an incident.
location: global
---

# Incident response

1. Assess the impact.
2. Engage the on-call team.
```

When it is present, `name` becomes the Port entity identifier, `description`
becomes the entity description, and all content after the closing front-matter
delimiter becomes the Port `instructions` value. `location` is optional and
defaults to `global`.

For registry files without front matter, the lowercased file name becomes the
identifier (`Terraform_Standards.md` becomes `terraform_standards`) and the first
Markdown heading becomes the title and description. This supports the current
`terraform-skills/*.md` layout in Port-Skills-Registry.

## Prerequisites

- Port credentials available as `PORT_CLIENT_ID` and `PORT_CLIENT_SECRET`.
- A fine-grained GitHub token with read-only **Contents** access to
  `sce81/Port-Skills-Registry`, supplied as `TF_VAR_skills_registry_token`.
- An installed Port GitHub Ocean integration named `github-ocean`, or override
  `github_ocean_installation_id`.
- S3 backend configuration for Terraform state.

The GitHub Actions sync workflow imports an existing `skill` blueprint into
the configured remote state before its first apply. No local Terraform command
is required.

## Local use

```bash
export PORT_CLIENT_ID="..."
export PORT_CLIENT_SECRET="..."
export TF_VAR_skills_registry_token="..."

terraform init -reconfigure -backend-config=backend.hcl
terraform plan
terraform apply
```

## Port-triggered sync

The Terraform apply creates **Sync Port Skills Registry** in Port. A user selects
a GitHub environment, and the workflow dispatches
`.github/workflows/sync-port-skills.yml` in this repository.

Configure these environment-scoped GitHub secrets:

- `PORT_CLIENT_ID`
- `PORT_CLIENT_SECRET`
- `PORT_SKILLS_REGISTRY_TOKEN`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Configure these environment-scoped GitHub variables:

- `TF_STATE_REGION`
- `TF_STATE_BUCKET`
- `TF_STATE_KEY`

The workflow runs `terraform init`, imports the existing shared `skill`
blueprint when it is not yet in state, then runs `terraform validate` and
`terraform apply`.
GitHub Ocean reports the run outcome back to Port.

## Registry merge automation

The Port workflow has no Environment field; it always dispatches the configured
`Development` GitHub environment. Changes merged to `main` under `terraform-skills/**/*.md` in
`sce81/Port-Skills-Registry` also dispatch this workflow automatically. The
registry repository requires a `PORT_SKILLS_SYNC_DISPATCH_TOKEN` secret with
Actions read/write access to this root-module repository.
