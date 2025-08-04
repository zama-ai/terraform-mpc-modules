# KMS-Dev-V1 Environment Configuration - MPC Node Group with KubeIP
# Uses dynamic AWS profile configuration from common.hcl

# Include root configuration (contains dynamic provider generation)
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Include common configuration for dynamic profile mapping
include "common" {
  path = find_in_parent_folders("common.hcl")
}

# Reference the mpc-nodegroup-kubeip example module
terraform {
  source = "../../../..//"
  
  extra_arguments "tfvars" {
    commands = get_terraform_commands_that_need_vars()
    arguments = [
      "-var-file=${get_terragrunt_dir()}/terraform.tfvars"
    ]
  }
}

# Environment-specific inputs and overrides
inputs = {
  # Common variables are automatically injected from common.hcl
  # Environment-specific overrides can be added here if needed
  
  # Most configuration comes from the local terraform.tfvars file
  # AWS profile and region are automatically set based on environment (kms-dev-v1)
  # Custom S3 bucket for this environment: zama-terraform-kms-dev-v1-mpc-modules-tfstate
} 