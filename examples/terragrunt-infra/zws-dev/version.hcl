# ZWS-Dev Environment Provider Versions

locals {
  common_versions = read_terragrunt_config("${get_repo_root()}/examples/terragrunt-infra/version.hcl")
  
  version_overrides = {
    # Example: Use latest AWS provider features in dev environment
    # aws_version = "~> 5.40"
    
    # Example: Use specific Kubernetes provider version for compatibility
    # kubernetes_version = "~> 2.25.0"
  }
  
  provider_versions = merge(
    local.common_versions.inputs.provider_versions,
    local.version_overrides
  )
}

inputs = {
  provider_versions = local.provider_versions
}
