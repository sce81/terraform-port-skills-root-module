# Terraform Backend Configuration
#
# S3 Backend with file-based locking (use_lockfile = true)
# Configured in: provider.tf
#
# Initialize with backend config:
#
#   terraform init -reconfigure \
#     -backend-config="bucket=your-bucket" \
#     -backend-config="key=port-skills/terraform.tfstate" \
#     -backend-config="region=us-east-1"
#
# Or with backend.hcl:
#
#   terraform init -reconfigure -backend-config=backend.hcl
#
# See: .github/BACKEND_CONFIG.md for complete setup guide
