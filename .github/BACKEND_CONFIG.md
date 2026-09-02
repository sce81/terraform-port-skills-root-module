# Terraform Backend Configuration

The Port Skills modules use **S3 backend with file-based locking** (`use_lockfile = true`).

This configuration matches the standard used across all terraform modules in this organization.

## Configuration

Backend is defined in `provider.tf`:

```hcl
terraform {
  backend "s3" {
    encrypt      = true
    use_lockfile = true
  }
}
```

**Bucket, key, and region are passed at init time** (not hardcoded).

## Setup

### Initialize with Backend Config

**Option 1: Using backend.hcl file (Recommended)**

Create `backend.hcl`:

```hcl
bucket = "your-terraform-state-bucket"
key    = "port-skills/terraform.tfstate"
region = "us-east-1"
```

Initialize:

```bash
terraform init -reconfigure -backend-config=backend.hcl
```

**Option 2: Command-line flags**

```bash
terraform init -reconfigure \
  -backend-config="bucket=your-terraform-state-bucket" \
  -backend-config="key=port-skills/terraform.tfstate" \
  -backend-config="region=us-east-1"
```

**Option 3: Environment variables (CI/CD)**

```bash
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"

terraform init -reconfigure \
  -backend-config="bucket=your-terraform-state-bucket" \
  -backend-config="key=port-skills/terraform.tfstate" \
  -backend-config="region=us-east-1"
```

## GitHub Actions Workflow

The deploy workflow uses backend config from GitHub variables:

```yaml
- name: Terraform Init
  run: |
    terraform init -reconfigure \
      -backend-config="bucket=${{ vars.TF_STATE_BUCKET }}" \
      -backend-config="key=${{ vars.TF_STATE_KEY }}" \
      -backend-config="region=${{ vars.AWS_REGION }}"
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

Configure in GitHub repository Settings:

**Secrets:**
- `AWS_ACCESS_KEY_ID` — AWS credentials
- `AWS_SECRET_ACCESS_KEY` — AWS credentials

**Variables:**
- `TF_STATE_BUCKET` — Your S3 bucket name
- `TF_STATE_KEY` — Path in bucket (e.g., `port-skills/terraform.tfstate`)
- `AWS_REGION` — AWS region (e.g., `us-east-1`)

## File-Based Locking

The backend uses `use_lockfile = true` for state locking:

```hcl
backend "s3" {
  encrypt      = true
  use_lockfile = true
}
```

This creates `.terraform.tfstate.lock.info` file in S3 during operations to prevent concurrent modifications.

**No DynamoDB needed** — S3-based locking handles this automatically.

## State File Safety

✅ **Best practices:**
- State files are encrypted in S3
- Enable S3 versioning for recovery
- Use IAM policies to restrict access
- Enable S3 access logging
- Keep `.terraform.tfstate` out of Git

❌ **Never:**
- Commit `terraform.tfstate` to Git
- Share state files via email/Slack
- Make S3 bucket public
- Disable encryption
- Use shared AWS credentials

## Troubleshooting

### "Error acquiring the state lock"

State lock exists (incomplete operation). Wait a moment and retry:

```bash
terraform init -reconfigure -backend-config=backend.hcl
```

If still stuck, check S3 for lock file:

```bash
aws s3 ls s3://your-bucket/port-skills/ --recursive
```

### "Access Denied" to S3 bucket

Verify AWS credentials and S3 bucket permissions:

```bash
aws s3 ls s3://your-bucket/
```

### State file is corrupted

S3 versioning allows recovery of previous versions:

```bash
# List versions
aws s3api list-object-versions \
  --bucket your-bucket \
  --prefix port-skills/

# Restore specific version
aws s3api get-object \
  --bucket your-bucket \
  --key port-skills/terraform.tfstate \
  --version-id VERSION_ID \
  terraform.tfstate
```

## Resources

- [S3 Backend Documentation](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- [State Locking](https://developer.hashicorp.com/terraform/language/state/locking)
- [AWS S3 Security](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
