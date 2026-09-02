# GitHub Actions Workflow Guide

This document describes the CI/CD pipelines for the terraform-port-skills modules.

## Workflows

### 1. **Terraform Validate** (`terraform-validate.yml`)

**Trigger**: Push to `main` or Pull Request to `main`

**What it does:**
- ✅ Checks Terraform code formatting (`terraform fmt`)
- ✅ Validates Terraform syntax (`terraform validate`)
- ✅ Verifies required files (README.md, .gitignore)
- ✅ Scans for accidentally committed secrets

**Status**: Blocks merging if validation fails

### 2. **Terraform Plan** (`terraform-plan.yml`)

**Trigger**: Pull Request to `main` (when `.tf` or `.tfvars` files change)

**What it does:**
- ✅ Runs `terraform plan` (non-destructive preview)
- ✅ Posts plan output as PR comment
- ✅ Shows what changes will be made
- ✅ Allows review before merge

**Status**: Informational - doesn't block merge

### 3. **Terraform Deploy** (`terraform-deploy.yml`)

**Trigger**: Manual workflow dispatch from GitHub

**What it does:**
- ✅ Supports `plan` and `apply` operations
- ✅ Environment selection (Development, Staging, Production)
- ✅ Saves plan artifacts for review
- ✅ Applies changes to infrastructure
- ✅ Reports status to Port (if configured)

**Usage**:
```bash
# From GitHub Actions tab:
1. Click "Terraform Port Skills Deployment"
2. Select operation (plan or apply)
3. Select environment
4. Click "Run workflow"
```

## Required Secrets

Configure these in GitHub repository Settings → Secrets and variables:

### **Required for all workflows:**
- `PORT_CLIENT_ID` — Port API credentials
- `PORT_CLIENT_SECRET` — Port API credentials

### **Optional (for GitHub documentation integration):**
- `GH_DOCS_REPO_TOKEN` — GitHub token for private documentation repo
  - Scope: `repo` (full control of private repositories)

## Required Variables

Configure these in GitHub repository Settings → Variables:

### **Optional environment-specific variables:**
- `TF_STATE_BUCKET` — S3 bucket for Terraform state (if using remote backend)
- `TF_STATE_KEY` — Path in S3 bucket (if using remote backend)

## Setup Instructions

### 1. Create GitHub Secrets

```bash
# Using GitHub CLI
gh secret set PORT_CLIENT_ID --body "your_client_id"
gh secret set PORT_CLIENT_SECRET --body "your_client_secret"
gh secret set GH_DOCS_REPO_TOKEN --body "ghp_xxxxxxxxxxxx"  # Optional
```

Or via web UI:
1. Go to repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret

### 2. Configure Branch Protection

Recommended for `main` branch:

Settings → Branches → Branch protection rules → Add rule:
- ✅ Require status checks to pass before merging
- ✅ Require code review before merging
- ✅ Dismiss stale PR approvals
- ✅ Require up-to-date branches before merging

### 3. Environment Protection Rules

For Production environment:
1. Go to Settings → Environments → Create "Production"
2. Add required reviewers
3. Select "Require reviewers to approve workflow runs before deploying"

## Workflow Details

### Terraform Validate
```
Push to main / PR to main
    ↓
[Validate] Format check, syntax validation
[Docs] README and .gitignore check
[Security] Secret scan
    ↓
✅ Pass / ❌ Fail (blocks merge)
```

### Terraform Plan
```
PR to main (Terraform files changed)
    ↓
[Plan] Runs terraform plan
    ↓
[Comment] Posts results in PR
    ↓
📊 Shows what will change
```

### Terraform Deploy
```
Manual trigger (Run workflow)
    ↓
Choose operation + environment
    ↓
[Plan] Preview changes (if plan selected)
  OR
[Apply] Deploy changes (if apply selected)
    ↓
✅ Success / ❌ Failure
    ↓
[Report] Status logged (Port integration)
```

## Best Practices

### When Pushing Code
1. ✅ All workflows pass (validate, format)
2. ✅ PR gets review
3. ✅ Plan shows expected changes
4. ✅ Merge to main

### When Deploying
1. ✅ Run `plan` operation first
2. ✅ Review plan output
3. ✅ Run `apply` operation after approval
4. ✅ Monitor execution in GitHub Actions

### For Production
1. ✅ Use Production environment
2. ✅ Require multiple reviewers
3. ✅ Plan before apply
4. ✅ Monitor Port for deployment status

## Troubleshooting

### Workflow fails with "authentication error"
**Solution**: Verify secrets are set correctly
```bash
gh secret list  # Check if secrets exist
```

### Plan shows no changes
**Solution**: Check that infrastructure already exists or module has no resources

### Apply fails with permission denied
**Solution**: Verify Port credentials have required permissions

### Can't create secrets
**Solution**: You need admin access to the repository

## Port Integration

Workflows can report status to Port:
- Plan progress and completion
- Apply progress and completion
- Failures with error details

Configure via environment variables in workflow:
- `PORT_CLIENT_ID`
- `PORT_CLIENT_SECRET`
- `PORT_WORKFLOW_NODE_RUN_ID`

## Security

✅ **Good practices in these workflows:**
- Secrets never printed in logs
- Code validation before deployment
- Secret detection
- Environment-based approvals
- Artifact retention limits

❌ **Never:**
- Commit secrets to Git
- Use personal access tokens in code
- Share secrets in PR comments
- Disable validation checks

## Monitoring

View workflow status:
1. Go to repository Actions tab
2. Select workflow
3. See real-time progress and logs
4. Download artifacts if needed

Set notifications:
1. Go to Watching (bell icon)
2. Select "All Activity" for real-time alerts

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform GitHub Actions](https://github.com/hashicorp/setup-terraform)
- [Port Documentation](https://docs.getport.io)
