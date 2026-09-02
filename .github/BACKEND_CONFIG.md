# Terraform Backend Configuration

This document explains the Terraform backend options for the Port Skills modules.

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

## Production Setup: S3 Backend

For production and team environments, use S3 backend:

### Prerequisites

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

5. **Create DynamoDB table for state locking:**
```bash
aws dynamodb create-table \
  --table-name terraform-locks-port-skills \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### Configure Backend

#### Option 1: Update provider.tf

Edit `provider.tf` and replace the `backend` block:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-port-skills"
    key            = "port-skills/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks-port-skills"
  }

  required_version = ">= 1.0"
  # ... rest of config
}
```

Then reinitialize:
```bash
terraform init
```

#### Option 2: Backend config file (Recommended)

Create `backend.hcl`:

```hcl
# backend.hcl
bucket         = "terraform-state-port-skills"
key            = "port-skills/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-locks-port-skills"
```

Keep `provider.tf` with empty backend:

```hcl
terraform {
  backend "s3" {}
  # ... rest of config
}
```

Initialize with config file:

```bash
terraform init -backend-config=backend.hcl
```

#### Option 3: Command-line flags (CI/CD)

During init, pass backend config:

```bash
terraform init \
  -backend-config="bucket=terraform-state-port-skills" \
  -backend-config="key=port-skills/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=terraform-locks-port-skills"
```

## For GitHub Actions Workflows

Update `.github/workflows/terraform-deploy.yml`:

```yaml
- name: Terraform Init
  run: |
    terraform init -reconfigure \
      -backend-config="bucket=${{ vars.TF_STATE_BUCKET }}" \
      -backend-config="key=${{ vars.TF_STATE_KEY }}" \
      -backend-config="region=${{ vars.AWS_REGION }}" \
      -backend-config="encrypt=true" \
      -backend-config="dynamodb_table=${{ vars.TF_LOCKS_TABLE }}"
```

Add repository variables in GitHub Settings → Variables:
- `TF_STATE_BUCKET` = `terraform-state-port-skills`
- `TF_STATE_KEY` = `port-skills/terraform.tfstate`
- `AWS_REGION` = `us-east-1`
- `TF_LOCKS_TABLE` = `terraform-locks-port-skills`

## State File Safety

### Good Practices

✅ **Enable:**
- Versioning (recover previous states)
- Encryption (protect sensitive data)
- Access logging (audit who accesses state)
- State locking (prevent concurrent modifications)
- MFA delete (extra protection)

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

### From Local to S3

1. **Backup local state:**
```bash
cp terraform.tfstate terraform.tfstate.backup
```

2. **Update backend in provider.tf** (or create backend.hcl)

3. **Reinitialize:**
```bash
terraform init
```

4. **Confirm migration:**
```bash
terraform state list
```

5. **Update .gitignore** to exclude state files:
```bash
# .gitignore
terraform.tfstate
terraform.tfstate.*
*.tfstate
*.tfstate.*
```

### Between S3 Buckets

```bash
# Backup old state
aws s3 cp s3://old-bucket/path/terraform.tfstate .

# Update backend configuration

# Reinitialize
terraform init

# Migrate state
terraform init -migrate-state
```

## Troubleshooting

### "Backend has not been initialized"
```bash
terraform init
```

### "Error acquiring the state lock"
State is locked (likely from incomplete operation):
```bash
# View lock info
terraform force-unlock [LOCK_ID]
```

### "Access Denied" to S3 bucket
Check IAM permissions:
```bash
aws iam get-user-policy --user-name [USER] --policy-name terraform
```

### State file is corrupted
Restore from backup:
```bash
# Enable S3 versioning and recover previous version
aws s3api get-object \
  --bucket terraform-state-port-skills \
  --key port-skills/terraform.tfstate \
  --version-id [VERSION_ID] \
  terraform.tfstate
```

## Monitoring State

### CloudWatch Logs
Enable S3 access logging:
```bash
aws s3api put-bucket-logging \
  --bucket terraform-state-port-skills \
  --bucket-logging-status '{"LoggingEnabled":{"TargetBucket":"terraform-logs","TargetPrefix":"state/"}}'
```

### CloudTrail
Track API calls:
```bash
aws cloudtrail put-event-selectors \
  --trail-name terraform-audit \
  --event-selectors ReadWriteType=All,IncludeManagementEvents=true
```

## Summary

| Aspect | Local | S3 |
|--------|-------|-----|
| **Setup** | None | Complex |
| **Team Use** | ❌ No | ✅ Yes |
| **Encryption** | ❌ No | ✅ Yes |
| **Backup** | ❌ None | ✅ Versioning |
| **Locking** | ❌ No | ✅ DynamoDB |
| **Cost** | Free | ~$5/month |
| **Security** | ❌ Low | ✅ High |

**Recommendation**: Use **S3 backend** for anything beyond local testing.

## Resources

- [Terraform Backend Documentation](https://developer.hashicorp.com/terraform/language/settings/backends)
- [S3 Backend Configuration](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- [State Locking](https://developer.hashicorp.com/terraform/language/state/locking)
- [AWS S3 Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
