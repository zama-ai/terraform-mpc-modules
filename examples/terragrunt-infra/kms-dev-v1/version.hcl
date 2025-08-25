# KMS-Dev-V1 Environment Provider Versions

locals {
  common_versions = read_terragrunt_config("${get_repo_root()}/examples/terragrunt-infra/version.hcl")
  
  version_overrides = {
    # Example: Override AWS provider version for this environment if needed
    # aws_version = "~> 6.10"

    # Example: Pin kubectl to specific version for stability
    # kubectl_version = "~> 1.19.0"
  }
  
  provider_versions = merge(
    local.common_versions.inputs.provider_versions,
    local.version_overrides
  )
}

inputs = {
  provider_versions = local.provider_versions
}
