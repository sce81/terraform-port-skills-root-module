# Terraform Backend Configuration
#
# Default: Local backend storing state in terraform.tfstate
#
# RECOMMENDED for production: Terraform Cloud
# - Go to https://app.terraform.io
# - Create organization and API token
# - Add backend.tf:
#
#   terraform {
#     cloud {
#       organization = "your-org-name"
#       workspaces {
#         name = "port-skills"
#       }
#     }
#   }
#
# - Run: terraform login
# - Run: terraform init
#
# Benefits: Free tier, state management, team collaboration, no DynamoDB needed
#
# Alternative: S3 Backend (without state locking)
# - Create S3 bucket with versioning and encryption
# - Run: terraform init -backend-config=backend.hcl
#
# See: .github/BACKEND_CONFIG.md for complete setup guide
# See: https://developer.hashicorp.com/terraform/language/settings/backends/configuration

# Local backend is configured in provider.tf
