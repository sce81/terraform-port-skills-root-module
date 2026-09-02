# Terraform Backend Configuration

This document explains backend options for the Port Skills modules.

## Default Configuration

By default, the modules use a **local backend** that stores state in `terraform.tfstate`:

```hcl
backend "local" {
  path = "terraform.tfstate"
}
```

**Good for:**
- ✅ Local development
- ✅ Single-user projects
- ✅ Learning/testing

**Not recommended for:**
- ❌ Team environments (state conflicts)
- ❌ Production (no remote backup)
- ❌ CI/CD pipelines (security risk)

## Recommended: Terraform Cloud Backend

**Best option for teams and production** — Use [Terraform Cloud](https://app.terraform.io/):

### Setup

1. **Create Terraform Cloud account:**
   - Go to https://app.terraform.io
   - Sign up (free tier available)
   - Create organization

2. **Generate API token:**
   - Settings → Tokens → Create API token
   - Save it securely

3. **Create `backend.tf`:**

```hcl
terraform {
  cloud {
    organization = "your-org-name"
    
    workspaces {
      name = "port-skills"
    }
  }
}
```

4. **Authenticate locally:**

```bash
terraform login
# Paste your API token when prompted
```

5. **Initialize:**

```bash
terraform init
```

### Benefits

✅ **Free tier:** Includes state management, runs, VCS integration  
✅ **State management:** Remote, encrypted, versioned  
✅ **Team collaboration:** Multiple users, approval workflows  
✅ **Run history:** View all applies and plans  
✅ **Cost estimation:** Before/after changes  
✅ **Drift detection:** Automatic state checks  
✅ **No DynamoDB** — Handles locking automatically  

### CI/CD Integration

For GitHub Actions, use API token:

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
  with:
    cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

- name: Terraform Init
  run: terraform init
```

Add to GitHub Secrets:
- `TF_API_TOKEN` — Your Terraform Cloud API token

## Alternative: S3 Backend (Simple)

If you prefer AWS S3 without state locking:

### Setup

1. **Create S3 bucket:**

```bash
aws s3api create-bucket \
  --bucket terraform-state-port-skills \
  --region us-east-1
```

2. **Enable versioning:**

```bash
aws s3api put-bucket-versioning \
  --bucket terraform-state-port-skills \
  --versioning-configuration Status=Enabled
```

3. **Enable encryption:**

```bash
aws s3api put-bucket-encryption \
  --bucket terraform-state-port-skills \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

4. **Block public access:**

```bash
aws s3api put-public-access-block \
  --bucket terraform-state-port-skills \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

5. **Configure backend:**

Create `backend.hcl`:

```hcl
bucket = "terraform-state-port-skills"
key    = "port-skills/terraform.tfstate"
region = "us-east-1"
encrypt = true
```

Update `provider.tf`:

```hcl
terraform {
  backend "s3" {}
  # ... rest of config
}
```

Initialize:

```bash
terraform init -backend-config=backend.hcl
```

### CI/CD Integration

```yaml
- name: Terraform Init
  run: |
    terraform init -reconfigure \
      -backend-config="bucket=${{ vars.TF_STATE_BUCKET }}" \
      -backend-config="key=${{ vars.TF_STATE_KEY }}" \
      -backend-config="region=${{ vars.AWS_REGION }}" \
      -backend-config="encrypt=true"
```

Add GitHub variables:
- `TF_STATE_BUCKET` = `terraform-state-port-skills`
- `TF_STATE_KEY` = `port-skills/terraform.tfstate`
- `AWS_REGION` = `us-east-1`

## State File Safety

### Good Practices

✅ **Enable:**
- Versioning (recover previous states)
- Encryption (protect sensitive data)
- Access logging (audit who accesses state)

✅ **Restrict access:**
- IAM policies limiting who can read/write
- Bucket policies denying public access
- Enable CloudTrail logging

✅ **Backup:**
- S3 cross-region replication
- Regular snapshots
- Test restore procedures

### Never

❌ **Don't:**
- Commit `terraform.tfstate` to Git
- Share state files via email/Slack
- Use public S3 buckets
- Disable encryption
- Allow unauthenticated access

## Migrating State

### From Local to Terraform Cloud

1. **Backup local state:**

```bash
cp terraform.tfstate terraform.tfstate.backup
```

2. **Create `backend.tf`:**

```hcl
terraform {
  cloud {
    organization = "your-org"
    workspaces {
      name = "port-skills"
    }
  }
}
```

3. **Authenticate:**

```bash
terraform login
```

4. **Initialize (will migrate automatically):**

```bash
terraform init
```

5. **Confirm in Terraform Cloud UI**

### From Local to S3

1. **Backup local state:**

```bash
cp terraform.tfstate terraform.tfstate.backup
```

2. **Create `backend.hcl`** (see S3 setup above)

3. **Reinitialize:**

```bash
terraform init -backend-config=backend.hcl
```

4. **Confirm migration:**

```bash
terraform state list
```

## Comparison

| Feature | Local | Terraform Cloud | S3 |
|---------|-------|-----------------|-----|
| **Cost** | Free | Free tier | ~$1-5/mo |
| **Team Use** | ❌ No | ✅ Yes | ❌ Complex |
| **Encryption** | ❌ No | ✅ Yes | ✅ Yes |
| **Versioning** | ❌ No | ✅ Yes | ✅ Yes |
| **State Locking** | ❌ No | ✅ Auto | ❌ Not included |
| **Setup** | None | 5 min | 10 min |
| **Runs/Plans** | N/A | ✅ Web UI | ❌ CLI only |
| **Approvals** | ❌ No | ✅ Yes | ❌ No |
| **Recommended** | Dev only | ✅ **Production** | Alternative |

## Recommendation

**Use Terraform Cloud** — It's:
- ✅ Free tier for small teams
- ✅ No infrastructure to manage
- ✅ Automatic state locking
- ✅ Web UI for state inspection
- ✅ VCS integration (GitHub)
- ✅ Policy as Code (paid)

## Resources

- [Terraform Cloud](https://app.terraform.io)
- [Terraform Cloud Documentation](https://developer.hashicorp.com/terraform/cloud-docs)
- [Backend Configuration](https://developer.hashicorp.com/terraform/language/settings/backends)
- [S3 Backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
