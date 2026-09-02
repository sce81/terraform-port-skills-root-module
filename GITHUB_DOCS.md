# GitHub Documentation Integration

The terraform-port-skills module automatically discovers and fetches all `.md` documentation files from a private GitHub repository. Skill associations are derived from the directory structure, and permissions are applied at the repository level.

## Setup

### 1. Create GitHub Personal Access Token

Generate a token with repository access:

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Click "Generate new token (classic)"
3. Name: `terraform-port-skills`
4. Select scope: `repo` (Full control of private repositories)
5. Copy the token

### 2. Set Environment Variable

```bash
export TF_VAR_github_docs_repo_token="ghp_xxxxxxxxxxxxxxxxxxxx"
```

Or add to `.env.local` (if using direnv or similar):

```bash
# .env.local
export TF_VAR_github_docs_repo_token="ghp_xxxxxxxxxxxxxxxxxxxx"
```

**Do NOT commit the token to version control.**

### 3. Create Documentation Repository

Create a private GitHub repository with the documentation structure:

```
skill-documentation/
├── README.md
└── skills/
    ├── incident-response/
    │   ├── rca-process.md
    │   ├── template.md
    │   └── checklist.md
    ├── deployment-review/
    │   ├── approval-process.md
    │   ├── pre-deploy-checklist.md
    │   └── rollback.md
    └── daily-standup/
        └── planning-guide.md
```

### 4. Configure Terraform Variables

```hcl
# Enable GitHub documentation discovery
github_docs_repo_enabled = true
github_docs_repo_owner   = "my-organization"
github_docs_repo_name    = "engineering-playbooks"
github_docs_repo_token   = ""  # Set via environment variable
github_docs_repo_path    = "skills"
github_docs_repo_branch  = "main"

# Set permissions for all skill references from this repository
github_repo_team_permissions = {
  "sre-team-admin" = {
    team_identifier = "sre-team"
    role_identifier = "admin"
    actions         = ["create", "read", "update", "delete"]
  }
  "engineering-member" = {
    team_identifier = "engineering"
    role_identifier = "member"
    actions         = ["read"]
  }
}
```

**That's it!** The module will automatically:
1. List all .md files in the `skills/` directory
2. Extract skill identifiers from directory names (e.g., `incident-response`)
3. Fetch each .md file content
4. Create skill_reference entities linked to the correct skill
5. Apply the defined team permissions to all references

## How It Works

1. **Lists directory** — Calls GitHub API to list all files in the repository path
2. **Discovers .md files** — Filters for `.md` files in the specified directory
3. **Extracts skill IDs** — Parses directory structure to determine skill identifier
   - Example: `skills/incident-response/rca-process.md` → skill ID: `incident-response`
4. **Fetches content** — Downloads raw markdown content for each discovered file
5. **Creates entities** — Creates skill_reference entities in Port with fetched content
6. **Applies permissions** — Assigns team permissions at the repository level
7. **Generates URLs** — Creates links back to files in GitHub repository

## Configuration Options

### github_docs_repo_enabled

**Type**: `bool`  
**Default**: `false`  
**Description**: Enable/disable GitHub documentation auto-discovery

### github_docs_repo_owner

**Type**: `string`  
**Default**: `""`  
**Description**: GitHub organization or username that owns the repository

### github_docs_repo_name

**Type**: `string`  
**Default**: `""`  
**Description**: Name of the GitHub repository

### github_docs_repo_token

**Type**: `string` (sensitive)  
**Default**: `""`  
**Description**: GitHub personal access token (set via `TF_VAR_github_docs_repo_token`)

### github_docs_repo_path

**Type**: `string`  
**Default**: `"skills"`  
**Description**: Path within the repository where skill documentation is stored

### github_docs_repo_branch

**Type**: `string`  
**Default**: `"main"`  
**Description**: Git branch to fetch files from

## Repository Team Permissions

Set permissions for all skill references discovered from the repository:

```hcl
variable "github_repo_team_permissions" {
  type = map(object({
    team_identifier = string  # Team that gets access
    role_identifier = string  # Role (admin, member, etc.)
    actions         = list(string)  # Actions: create, read, update, delete
  }))
}
```

**Example**:
```hcl
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

## Example: Multiple Skills with GitHub References

With this repository structure:

```
engineering-playbooks/
└── skills/
    ├── incident-response/
    │   ├── process.md
    │   ├── rca-template.md
    │   └── checklist.md
    └── deployment-review/
        ├── approval-process.md
        ├── checklist.md
        └── rollback.md
```

Configure Terraform simply:

```hcl
github_docs_repo_enabled = true
github_docs_repo_owner   = "acme-corp"
github_docs_repo_name    = "engineering-playbooks"
github_docs_repo_path    = "skills"
github_docs_repo_branch  = "main"

# Permissions apply to ALL skill references from this repo
github_repo_team_permissions = {
  "sre-team-admin" = {
    team_identifier = "sre-team"
    role_identifier = "admin"
    actions         = ["create", "read", "update", "delete"]
  }
  "eng-team-member" = {
    team_identifier = "engineering"
    role_identifier = "member"
    actions         = ["read"]
  }
  "platform-team-admin" = {
    team_identifier = "platform"
    role_identifier = "admin"
    actions         = ["create", "read", "update", "delete"]
  }
}
```

**Result**: All 6 .md files are automatically discovered and linked to their respective skills (`incident-response` and `deployment-review`), with team permissions applied to all references.

## Troubleshooting

### Authentication Error: 401

**Issue**: `Failed to fetch ... from GitHub repository. Status: 401`

**Solution**: 
- Verify GitHub token is set: `echo $TF_VAR_github_docs_repo_token`
- Check token has `repo` scope
- Verify token hasn't expired

### File Not Found: 404

**Issue**: `Failed to fetch ... from GitHub repository. Status: 404`

**Solution**:
- Verify `github_file_path` is relative to `github_docs_repo_path`
- Check file exists in the repository
- Verify branch name is correct
- Ensure repository is private and token has access

### Access Denied

**Issue**: Token is valid but still getting access errors

**Solution**:
- Verify the repository exists
- Check you have access to the repository with your GitHub account
- Verify the token has `repo` scope (not just `public_repo`)

## Example Repository Structure

Create a well-organized documentation repository:

```
engineering-playbooks/
├── README.md
├── incident-response/
│   ├── overview.md           # General process overview
│   ├── rca-process.md        # RCA specific process
│   ├── rca-template.md       # RCA markdown template
│   ├── checklist.md          # Incident response checklist
│   └── tools.md              # Tools and resources
├── deployments/
│   ├── approval-process.md   # Deployment approval workflow
│   ├── checklist.md          # Pre-deployment checklist
│   ├── rollback.md           # Rollback procedures
│   └── monitoring.md         # Post-deployment monitoring
└── planning/
    └── daily-standup.md      # Daily standup guidelines
```

## Best Practices

1. **Keep documentation updated** — Update .md files directly in the repository
2. **Use meaningful file paths** — Organize by skill/feature
3. **Version control** — Use Git branches for versioning (e.g., `v1.0.0`)
4. **Include metadata** — Add frontmatter to .md files with last-updated dates
5. **Test access** — Verify documentation renders correctly in Port
6. **Secure token** — Never commit the token; use environment variables
7. **Regular reviews** — Periodically review and update documentation

## GitHub API Limits

GitHub API has rate limits:
- **Authenticated requests**: 5,000 requests per hour per user
- **Unauthenticated requests**: 60 requests per hour per IP

For typical skill documentation fetching, you'll stay well within these limits.

## Integration with CI/CD

To fetch documentation in CI/CD pipelines:

```bash
# .github/workflows/deploy-skills.yml
- name: Deploy Skills with Documentation
  env:
    TF_VAR_github_docs_repo_token: ${{ secrets.GITHUB_TOKEN }}
  run: |
    terraform init
    terraform plan
    terraform apply -auto-approve
```

Use GitHub secrets to store the token securely.
