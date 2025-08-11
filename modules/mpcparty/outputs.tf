# MPC Party Information
output "party_name" {
  description = "Name of the MPC party"
  value       = var.party_name
}

# S3 Storage Information
output "vault_private_bucket_name" {
  description = "Name of the private S3 bucket for MPC party storage"
  value       = aws_s3_bucket.vault_private_bucket.id
}

output "vault_private_bucket_arn" {
  description = "ARN of the private S3 bucket for MPC party storage"
  value       = aws_s3_bucket.vault_private_bucket.arn
}

output "vault_private_bucket_domain_name" {
  description = "Domain name of the private S3 bucket"
  value       = aws_s3_bucket.vault_private_bucket.bucket_domain_name
}

output "vault_public_bucket_name" {
  description = "Name of the public S3 bucket for MPC party storage"
  value       = aws_s3_bucket.vault_public_bucket.id
}

output "vault_public_bucket_arn" {
  description = "ARN of the public S3 bucket for MPC party storage"
  value       = aws_s3_bucket.vault_public_bucket.arn
}

output "vault_public_bucket_url" {
  description = "URL of the public S3 bucket for MPC party storage"
  value       = "https://${aws_s3_bucket.vault_public_bucket.bucket_domain_name}"
}

output "vault_public_bucket_domain_name" {
  description = "Domain name of the public S3 bucket"
  value       = aws_s3_bucket.vault_public_bucket.bucket_domain_name
}

# IAM and Security Information
output "irsa_role_arn" {
  description = "ARN of the IRSA role for MPC party (null if create_irsa is false)"
  value       = var.create_irsa ? module.irsa[0].iam_role_arn : null
}

output "irsa_role_name" {
  description = "Name of the IRSA role for MPC party (null if create_irsa is false)" 
  value       = var.create_irsa ? module.irsa[0].iam_role_name : null
}

output "irsa_enabled" {
  description = "Whether IRSA is enabled for this MPC party"
  value       = var.create_irsa
}

# Kubernetes Information
output "k8s_namespace" {
  description = "Kubernetes namespace for MPC party"
  value       = var.k8s_namespace
}

output "k8s_namespace_created" {
  description = "Whether the Kubernetes namespace was created by this module"
  value       = var.create_namespace
}

output "k8s_service_account_name" {
  description = "Name of the Kubernetes service account for MPC party"
  value       = var.k8s_service_account_name
}

output "k8s_service_account_created" {
  description = "Whether the Kubernetes service account was created by this module (excludes IRSA-created service accounts)"
  value       = var.create_service_account && !var.create_irsa
}

# ConfigMap Information
output "config_map_name" {
  description = "Name of the ConfigMap containing S3 configuration (null if create_config_map is false)"
  value       = var.create_config_map ? (var.config_map_name != null ? var.config_map_name : "mpc-party-config-${var.party_name}") : null
}

output "config_map_created" {
  description = "Whether the ConfigMap was created by this module"
  value       = var.create_config_map
}

# Environment Variables for Applications
output "s3_environment_variables" {
  description = "Environment variables for S3 configuration that applications can use"
  value = {
    KMS_CORE__PUBLIC_VAULT__STORAGE  = "s3://${aws_s3_bucket.vault_public_bucket.id}"
    KMS_CORE__PRIVATE_VAULT__STORAGE = "s3://${aws_s3_bucket.vault_private_bucket.id}"
  }
}

# Cluster Information
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.cluster_name
}

# Comprehensive deployment summary
output "deployment_summary" {
  description = "Summary of the MPC party deployment"
  value = {
    party_name = var.party_name
    cluster_name = var.cluster_name
    
    storage = {
      private_bucket = aws_s3_bucket.vault_private_bucket.id
      public_bucket  = aws_s3_bucket.vault_public_bucket.id
    }
    
    kubernetes = {
      namespace           = var.k8s_namespace
      namespace_created   = var.create_namespace
      service_account     = var.k8s_service_account_name
      service_account_created = var.create_service_account && !var.create_irsa
      config_map          = var.create_config_map ? (var.config_map_name != null ? var.config_map_name : "mpc-party-config-${var.party_name}") : null
      config_map_created  = var.create_config_map
    }
    
    security = {
      irsa_enabled = var.create_irsa
      irsa_role_arn = var.create_irsa ? module.irsa[0].iam_role_arn : null
    }
  }
}
