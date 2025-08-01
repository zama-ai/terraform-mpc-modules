# AWS Configuration
aws_region = "eu-west-3"

# MPC Party Configuration
party_name  = "kms-threshold-4"
environment = "dev"

# S3 Bucket Configuration
bucket_prefix = "zama-kms-decentralized-threshold-4"
config_map_name = "kms-threshold-4"

# Kubernetes Configuration
cluster_name         = "kms-development-v1"
namespace           = "kms-decentralized"
service_account_name = "kms-threshold-4"
create_namespace    = false

# IRSA Configuration (recommended for production)
create_irsa = true

# Kubernetes Provider Configuration
kubeconfig_path    = "~/.kube/config"
kubeconfig_context = "arn:aws:eks:eu-west-3:767398008331:cluster/kms-development-v1"
eks_cluster_name   = "kms-development-v1"  # For automatic EKS token authentication

# Tagging
owner = "mpc-team"
additional_tags = {
  "Project"     = "mpc-infrastructure"
  "Team"        = "security"
  "Cost-Center" = "engineering"
}

# Example configurations for different scenarios:

# Scenario 1: Development environment with IRSA
# party_name  = "dev-party-alice"
# environment = "dev"
# create_irsa = true

# Scenario 2: Production environment with custom naming
# party_name    = "prod-party-bank-a"
# environment   = "prod"
# bucket_prefix = "company-secure-mpc"
# create_irsa   = true

# Scenario 3: Testing without IRSA (use manual AWS credentials)
# party_name  = "test-party"
# environment = "test"
# create_irsa = false 