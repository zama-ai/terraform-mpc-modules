# Common Terragrunt Configuration
# Shared configuration for dynamic AWS profile and environment management

locals {
  # Extract environment from directory path
  env_regex = "terragrunt-infra/([a-zA-Z0-9-]+)/"
  environment = try(regex(local.env_regex, get_original_terragrunt_dir())[0], "default")
  
  # Define environment-to-profile mapping
  # Update these profile names to match your actual AWS profiles
  aws_profiles = {
    "kms-dev-v1" = {
      profile             = "token-kms-dev"        # Replace with your actual profile name
      region              = "eu-west-3"
      account_id          = "767398008331"
      terraform_state_bucket = "zama-terraform-kms-dev-v1-mpc-modules-tfstate"  # Custom bucket for kms-dev-v1
    }
    "zws-dev" = {
      profile             = "token-zws-dev"        # Replace with your actual profile name
      region              = "eu-west-1"
      account_id          = "715841358639"           # Replace with your actual account ID
      terraform_state_bucket = "zama-terraform-mpc-modules-tfstate"  # Default bucket for zws-dev
    }
  }
  
  # Get current environment config with fallback
  current_env_config = lookup(local.aws_profiles, local.environment, {
    profile                = "default"
    region                 = "eu-west-3"
    account_id             = ""
    terraform_state_bucket = "zama-terraform-mpc-modules-tfstate"
  })
  
  # Allow override via environment variables for flexibility
  aws_profile            = get_env("AWS_PROFILE_OVERRIDE", local.current_env_config.profile)
  aws_region             = get_env("AWS_REGION_OVERRIDE", local.current_env_config.region)
  aws_account_id         = get_env("AWS_ACCOUNT_ID_OVERRIDE", local.current_env_config.account_id)
  terraform_state_bucket = get_env("TERRAFORM_STATE_BUCKET_OVERRIDE", local.current_env_config.terraform_state_bucket)
}

# Export these values for use in other configurations
inputs = {
  environment            = local.environment
  aws_profile            = local.aws_profile
  aws_region             = local.aws_region
  aws_account_id         = local.aws_account_id
  terraform_state_bucket = local.terraform_state_bucket
  
  # Additional common inputs
  project_name           = "mpc-modules"
}