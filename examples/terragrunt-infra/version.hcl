# Common Provider Versions

locals {
  # Default provider versions - can be overridden by environment-specific version.hcl
  provider_versions = {
    # Terraform version requirement
    terraform_version = ">= 1.0"
    
    # Provider versions (sources are hardcoded in root.hcl)
    aws_version        = ">= 5.0"
    kubernetes_version = ">= 2.23"
    random_version     = ">= 3.1"
    kubectl_version    = "~> 1.19.0"
    helm_version       = ">= 2.17"
  }
}

# Export versions for use in other configurations
inputs = {
  provider_versions = local.provider_versions
}
