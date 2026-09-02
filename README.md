# Port Skills Terraform Module

A Terraform module for managing **Port Skills** — reusable instruction sets that load automatically into AI agents based on context.

Use this module to define, organize, and govern skills across your organization through infrastructure-as-code.

## What This Does

This module creates and manages:

- **Skills** — Instruction sets that guide AI agents through your processes
- **Skill Metadata** — Ownership, team, category, version, and status information
- **Skill Permissions** — Team and role-based access control
- **Skill References** — Links to documentation, templates, and guides (from your repository or GitHub)

## Quick Start

### 1. Prerequisites

- **Terraform** `>= 1.0`
- **Port credentials** (Client ID and Secret)
- Optional: **GitHub token** (if using documentation from a private repository)

### 2. Get Your Port Credentials

1. Go to Port → Settings → Credentials
2. Click "Create API token"
3. Copy the Client ID and Secret
4. Save them securely (do NOT commit to Git)

### 3. Create Your Terraform Variables File

```bash
# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your configuration
nano terraform.tfvars
```

In `terraform.tfvars`, define your skills:

```hcl
skills = [
  {
    identifier   = "incident-response"
    title        = "Incident Response"
    description  = "Step-by-step incident response process"
    instructions = "1. Alert received\n2. Engage team\n3. Diagnose\n4. Resolve\n5. Document"
    relations    = {}
  }
]

skill_metadata = [
  {
    skill_identifier = "incident-response"
    owner            = "SRE Team"
    team             = "reliability"
    category         = "incident-management"
    use_cases        = ["incident-response", "post-mortem"]
    status           = "active"
    version          = "1.0.0"
    created_at       = "2024-01-15T10:00:00Z"
    updated_at       = "2024-09-02T14:30:00Z"
  }
]

skill_permissions = [
  {
    team_identifier      = "sre-team"
    role_identifier      = "admin"
    skill_identifier     = "incident-response"
    actions              = ["create", "read", "update", "delete"]
  }
]

publicly_accessible_skills = ["incident-response"]

skill_references = []
```

**⚠️ DO NOT put credentials in this file!** Use environment variables instead.

### 4. Set Environment Variables

Set your Port credentials via environment variables (never hardcode them):

```bash
export TF_VAR_port_client_id="your_client_id_here"
export TF_VAR_port_client_secret="your_client_secret_here"
```

**Better: Use a `.env.local` file:**

Create a file at the root of this directory:

```bash
# .env.local (DO NOT COMMIT)
export TF_VAR_port_client_id="your_client_id_here"
export TF_VAR_port_client_secret="your_client_secret_here"
```

Add `.env.local` to your `.gitignore`:

```bash
echo ".env.local" >> .gitignore
```

Then load it before running Terraform:

```bash
source .env.local
terraform init
terraform plan
terraform apply
```

### 5. Deploy

```bash
# Load your environment variables
source .env.local

# Initialize Terraform (first time only)
terraform init

# Review what will be created
terraform plan

# Deploy the skills
terraform apply
```

## Configuration Guide

### Define Skills

Skills are the core instruction sets for AI agents:

```hcl
skills = [
  {
    identifier   = "unique-skill-id"    # Must be unique, lowercase with hyphens
    title        = "Human Readable Name" # Display name
    description  = "What this skill does"
    instructions = "Step-by-step instructions for the AI agent"
    relations    = {}                    # Optional relationships to other entities
  }
]
```

**Tips:**
- Use `identifier` for machine-readable IDs: `incident-response`, not `Incident Response`
- Use multi-line instructions with newlines: `"Step 1\nStep 2\nStep 3"`
- Use heredoc syntax for longer instructions:

```hcl
skills = [
  {
    identifier   = "incident-response"
    title        = "Incident Response"
    description  = "Handles production incidents"
    instructions = <<-EOT
      1. Acknowledge the alert in our incident management tool
      2. Gather information from monitoring dashboards
      3. Create incident ticket with severity level
      4. Engage on-call team in Slack channel
      5. Track resolution progress in ticket
      6. Schedule post-mortem meeting once resolved
      7. Document learnings and action items
    EOT
    relations    = {}
  }
]
```

### Add Skill Metadata

Track who owns skills and their status:

```hcl
skill_metadata = [
  {
    skill_identifier = "incident-response"
    owner            = "SRE Team"       # Team responsible for this skill
    team             = "reliability"     # Team identifier (lowercase)
    category         = "incident-mgmt"  # Category for organization
    use_cases        = [                # What this skill is used for
      "incident-response",
      "post-mortem-analysis",
      "on-call-escalation"
    ]
    status           = "active"         # active, beta, or deprecated
    version          = "1.0.0"          # Semantic versioning
    created_at       = "2024-01-15T10:00:00Z"  # ISO 8601 datetime
    updated_at       = "2024-09-02T14:30:00Z"  # Last update
  }
]
```

### Control Access with Permissions

Specify which teams can do what with each skill:

```hcl
skill_permissions = [
  {
    team_identifier  = "sre-team"        # Port team ID
    role_identifier  = "admin"           # Role: admin, member, viewer
    skill_identifier = "incident-response"
    actions          = [
      "create",   # Can create new skills
      "read",     # Can view
      "update",   # Can modify
      "delete"    # Can remove
    ]
  },
  {
    team_identifier  = "engineering"
    role_identifier  = "member"
    skill_identifier = "incident-response"
    actions          = ["read"]  # Read-only for engineers
  }
]
```

### Make Skills Public

Allow guests (unauthenticated users) to access skills:

```hcl
publicly_accessible_skills = [
  "incident-response",
  "deployment-review",
  "daily-standup"
]
```

### Add Static Documentation References

Link to external documentation (wikis, websites, etc.):

```hcl
skill_references = [
  {
    skill_identifier     = "incident-response"
    reference_identifier = "rca-template"
    title                = "RCA Template"
    reference_type       = "template"  # documentation, template, guide, runbook
    url                  = "https://wiki.example.com/rca-template.md"
    documentation        = "Standard template for root cause analysis"
    owner                = "SRE Team"
  }
]
```

## GitHub Documentation Integration

Automatically fetch `.md` files from a private GitHub repository.

### Setup

1. **Create a GitHub personal access token:**
   - Go to GitHub → Settings → Developer settings → Personal access tokens
   - Click "Generate new token (classic)"
   - Select scope: `repo` (full control of private repositories)
   - Copy the token

2. **Set the environment variable:**

```bash
export TF_VAR_github_docs_repo_token="ghp_xxxxxxxxxxxxxxxxxxxx"
```

3. **Configure in terraform.tfvars:**

```hcl
github_docs_repo_enabled = true
github_docs_repo_owner   = "my-organization"
github_docs_repo_name    = "engineering-playbooks"
github_docs_repo_path    = "skills"
github_docs_repo_branch  = "main"

# Permissions for all GitHub-sourced documentation
github_repo_team_permissions = {
  "sre-admin" = {
    team_identifier = "sre-team"
    role_identifier = "admin"
    actions         = ["create", "read", "update", "delete"]
  }
  "eng-member" = {
    team_identifier = "engineering"
    role_identifier = "member"
    actions         = ["read"]
  }
}
```

### Repository Structure

Organize your documentation by skill:

```
engineering-playbooks/
└── skills/
    ├── incident-response/
    │   ├── rca-process.md
    │   ├── template.md
    │   └── checklist.md
    └── deployment-review/
        ├── approval-process.md
        ├── pre-deploy-checklist.md
        └── rollback.md
```

**How it works:**
- The module lists all `.md` files in the `skills/` directory
- Extracts skill identifier from directory name: `incident-response/` → skill ID: `incident-response`
- Fetches each file's content automatically
- Creates skill_reference entities and links them to the correct skill
- Applies team permissions to all references

See **[GITHUB_DOCS.md](./GITHUB_DOCS.md)** for detailed setup and troubleshooting.

## Environment Variables Reference

### Port Authentication (Required)

Set your Port API credentials:

```bash
export TF_VAR_port_client_id="your_client_id"
export TF_VAR_port_client_secret="your_client_secret"
```

### GitHub Integration (Optional)

If using GitHub documentation:

```bash
export TF_VAR_github_docs_repo_token="ghp_xxxxxxxxxxxxxxxxxxxx"
```

### Using `.env.local` (Recommended)

Create a local file to manage secrets:

```bash
# .env.local - Add to .gitignore!
export TF_VAR_port_client_id="your_id"
export TF_VAR_port_client_secret="your_secret"
export TF_VAR_github_docs_repo_token="ghp_xxx"
```

Load before running Terraform:

```bash
source .env.local
terraform plan
```

## Examples

Look at the included example files:

- **`example.tfvars`** — Complete example with 3 skills, metadata, permissions, and static references
- **`example-github.tfvars`** — Same example configured to fetch documentation from GitHub

Try an example:

```bash
cp example.tfvars terraform.tfvars
source .env.local
terraform plan
terraform apply
```

## Common Tasks

### Update skill instructions

```bash
# 1. Edit terraform.tfvars - change the instructions field
# 2. Review the change
terraform plan

# 3. Deploy
terraform apply
```

### Add a new skill

```bash
# 1. Add to the skills list in terraform.tfvars
# 2. Add metadata, permissions, etc.
# 3. Deploy
terraform plan
terraform apply
```

### Grant team access to a skill

```bash
# Add to skill_permissions in terraform.tfvars
skill_permissions = [
  # ... existing permissions ...
  {
    team_identifier  = "new-team"
    role_identifier  = "member"
    skill_identifier = "incident-response"
    actions          = ["read"]
  }
]

terraform apply
```

### Make a skill public

```bash
# Add to publicly_accessible_skills list
publicly_accessible_skills = [
  "incident-response",  # ← Add this
  "deployment-review"
]

terraform apply
```

### Update GitHub documentation

Just push new `.md` files to your GitHub repository. They'll be automatically discovered and fetched on the next `terraform apply`.

## Troubleshooting

### "Unauthorized" or "Authentication failed"

**Problem**: Error when running `terraform plan`

**Solution**: Check your Port credentials
```bash
# Verify environment variables are set
echo $TF_VAR_port_client_id
echo $TF_VAR_port_client_secret

# Make sure they're correct:
source .env.local  # Reload if needed
terraform plan
```

### "Failed to fetch from GitHub" (Status: 401)

**Problem**: Error fetching GitHub documentation

**Solution**: Verify your GitHub token
```bash
# Check token is set
echo $TF_VAR_github_docs_repo_token

# Verify it has the right scope (repo)
# Check it hasn't expired
```

### "Failed to fetch from GitHub" (Status: 404)

**Problem**: Cannot find files in GitHub repository

**Solution**:
- Verify `github_docs_repo_path` is correct (e.g., `skills/`)
- Verify files exist in the repository
- Verify the branch name is correct (`main`, `master`, etc.)
- Check repository is private but token has access

### Skills not showing up in Port

**Solution**:
1. Check `terraform apply` completed successfully
2. Review output for error messages
3. Verify skill `identifier` is unique (no duplicates)
4. Check Port web UI → Data Model → Entities

## Next Steps

1. ✅ Copy `terraform.tfvars.example` → `terraform.tfvars`
2. ✅ Create `.env.local` with your Port credentials
3. ✅ Define your first skill in `terraform.tfvars`
4. ✅ Run `terraform init`
5. ✅ Run `terraform plan`
6. ✅ Run `terraform apply`
7. ✅ Check Port web UI for your new skill

## Getting Help

- **Port Documentation**: https://docs.getport.io
- **Terraform Provider Docs**: https://registry.terraform.io/providers/port-labs/port/latest/docs
- **GitHub Issues**: Check the repository for this module

## Best Practices

✅ **Do:**
- Use environment variables for all secrets (never commit credentials)
- Use semantic versioning for skill versions: `1.0.0`, `1.2.3`, etc.
- Write clear skill descriptions that help AI agents understand their purpose
- Keep skill identifiers lowercase with hyphens: `incident-response`, not `IncidentResponse`
- Review `terraform plan` output before applying changes
- Document your skills in a README or wiki for your team

❌ **Don't:**
- Commit `.tfvars` files with secrets to Git
- Use uppercase or spaces in skill identifiers
- Share GitHub tokens in Slack, email, or documentation
- Deploy without reviewing `terraform plan` first
- Delete skills without checking if anything depends on them

## License

MIT
