# Terraform Backend Configuration
#
# Default: Local backend storing state in terraform.tfstate
#
# To use S3 backend (recommended for production):
# 1. Add backend config in your terraform.tfvars:
#    backend_type = "s3"
#    backend_config = {
#      bucket         = "your-terraform-state-bucket"
#      key            = "port-skills/terraform.tfstate"
#      region         = "us-east-1"
#      encrypt        = true
#      dynamodb_table = "terraform-locks"
#    }
#
# 2. Or reconfigure during init:
#    terraform init -reconfigure \
#      -backend-config="bucket=your-bucket" \
#      -backend-config="key=port-skills/terraform.tfstate" \
#      -backend-config="region=us-east-1" \
#      -backend-config="encrypt=true" \
#      -backend-config="dynamodb_table=terraform-locks"
#
# See: https://developer.hashicorp.com/terraform/language/settings/backends/configuration

# Local backend is configured in provider.tf
# This file documents backend options and best practices
