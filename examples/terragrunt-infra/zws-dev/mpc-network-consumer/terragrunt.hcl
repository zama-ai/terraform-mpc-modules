# ZWS-Dev Environment Configuration - MPC Network Consumer
# Uses dynamic AWS profile configuration from common.hcl

# Include root configuration (contains dynamic provider generation)
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Include common configuration for dynamic profile mapping
include "common" {
  path = find_in_parent_folders("common.hcl")
}

# Reference the mpc-network-consumer example module
terraform {
  source = "../../../..//modules/vpc-endpoint-consumer"
  
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
  # AWS profile and region are automatically set based on environment (zws-dev)
} 