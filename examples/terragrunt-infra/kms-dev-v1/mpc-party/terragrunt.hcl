# KMS-Dev-V1 Environment Configuration - MPC Party
# Uses dynamic AWS profile configuration from common.hcl

# Include root configuration (contains dynamic provider generation)
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Include common configuration for dynamic profile mapping
include "common" {
  path = find_in_parent_folders("common.hcl")
}

# Reference the mpc-network-provider example module
terraform {
  source = "git::https://github.com/zama-ai/terraform-mpc-modules.git//modules/mpc-party?ref=ghislain/chore/prepare-release-v0.1.8"

  extra_arguments "tfvars" {
    commands = get_terraform_commands_that_need_vars()
    arguments = [
      "-var-file=${get_terragrunt_dir()}/terraform.tfvars"
    ]
  }
}

inputs = {
}
