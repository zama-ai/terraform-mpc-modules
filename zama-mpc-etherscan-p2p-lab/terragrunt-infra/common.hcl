# Common Terragrunt Configuration
# Shared configuration for dynamic AWS profile and environment management
locals {
  # Extract environment from directory path
  env_regex = "terragrunt-infra/([a-zA-Z0-9-]+)/"
  environment = try(regex(local.env_regex, get_original_terragrunt_dir())[0], "default")
  
  # Define environment-to-config mapping
  env_configs = {
    "kms-dev-v1" = {
      profile             = "token-kms-dev"
      region              = "eu-west-3"
      account_id          = "767398008331"
      kubeconfig_path     = "~/.kube/config"
      kubeconfig_context = "arn:aws:eks:eu-west-3:767398008331:cluster/kms-development-v1"
      cluster_name        = "kms-development-v1"
      use_eks_cluster_authentication = true
      terraform_state_bucket = "zama-terraform-kms-dev-v1-mpc-modules-tfstate"
    }
    "zws-dev" = {
      profile             = "token-zws-dev"
      region              = "eu-west-1"
      account_id          = "715841358639"
      kubeconfig_path     = "~/.kube/config"
      kubeconfig_context = "zama-dev"
      cluster_name        = "zws-dev"
      use_eks_cluster_authentication = false
      kubeconfig_context = "tailscale-operator-zws-dev.diplodocus-boa.ts.net"
      terraform_state_bucket = "zama-terraform-mpc-modules-tfstate"
    }
  }
  
  # Get current environment config with fallback
  current_env_config = lookup(local.env_configs, local.environment, {
    profile                = "default"
    region                 = "eu-west-3"
    account_id             = ""
    kubeconfig_path        = "~/.kube/config"
    kubeconfig_context     = "default"
    cluster_name           = "default"
    use_eks_cluster_authentication = false
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

  # Kubeconfig
  kubeconfig_path     = local.current_env_config.kubeconfig_path
  kubeconfig_context = local.current_env_config.kubeconfig_context
  use_eks_cluster_authentication = local.current_env_config.use_eks_cluster_authentication
  cluster_name = local.current_env_config.cluster_name
  
  # Additional common inputs
  project_name           = "mpc-modules"
}