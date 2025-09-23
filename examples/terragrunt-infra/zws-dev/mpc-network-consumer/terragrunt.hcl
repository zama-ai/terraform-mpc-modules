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

# Reference the vpc-endpoint-consumer module
terraform {
  source = "git::https://github.com/zama-ai/terraform-mpc-modules.git//modules/vpc-endpoint-consumer?ref=v0.1.6"

  extra_arguments "tfvars" {
    commands = get_terraform_commands_that_need_vars()
    arguments = [
      "-var-file=${get_terragrunt_dir()}/terraform.tfvars"
    ]
  }
}

inputs = {
}
