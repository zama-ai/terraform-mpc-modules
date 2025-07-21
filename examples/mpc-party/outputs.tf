# MPC Party Outputs - Using Enhanced Module

# Party Information
output "party_name" {
  description = "Name of the deployed MPC party"
  value       = module.mpc_party.party_name
}

output "environment" {
  description = "Environment where the MPC party is deployed"
  value       = var.environment
}

# S3 Storage Information
output "vault_private_bucket_name" {
  description = "Name of the private S3 bucket for MPC party storage"
  value       = module.mpc_party.vault_private_bucket_name
}

output "vault_private_bucket_arn" {
  description = "ARN of the private S3 bucket for MPC party storage"
  value       = module.mpc_party.vault_private_bucket_arn
}

output "vault_public_bucket_name" {
  description = "Name of the public S3 bucket for MPC party storage"
  value       = module.mpc_party.vault_public_bucket_name
}

output "vault_public_bucket_arn" {
  description = "ARN of the public S3 bucket for MPC party storage"
  value       = module.mpc_party.vault_public_bucket_arn
}

output "vault_public_bucket_url" {
  description = "URL of the public S3 bucket for MPC party storage"
  value       = module.mpc_party.vault_public_bucket_url
}

# IAM and Security Information
output "irsa_role_arn" {
  description = "ARN of the IRSA role for MPC party (null if create_irsa is false)"
  value       = module.mpc_party.irsa_role_arn
}

output "irsa_role_name" {
  description = "Name of the IRSA role for MPC party (null if create_irsa is false)"
  value       = module.mpc_party.irsa_role_name
}

output "irsa_enabled" {
  description = "Whether IRSA is enabled for this MPC party"
  value       = module.mpc_party.irsa_enabled
}

# Kubernetes Information
output "k8s_service_account_name" {
  description = "Name of the Kubernetes service account for MPC party"
  value       = module.mpc_party.k8s_service_account_name
}

output "k8s_namespace" {
  description = "Kubernetes namespace for MPC party"
  value       = module.mpc_party.k8s_namespace
}

output "k8s_namespace_created" {
  description = "Whether the Kubernetes namespace was created by the module"
  value       = module.mpc_party.k8s_namespace_created
}

output "k8s_service_account_created" {
  description = "Whether the Kubernetes service account was created by the module"
  value       = module.mpc_party.k8s_service_account_created
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.mpc_party.cluster_name
}

# ConfigMap Information
output "config_map_name" {
  description = "Name of the ConfigMap containing S3 configuration"
  value       = module.mpc_party.config_map_name
}

output "config_map_created" {
  description = "Whether the ConfigMap was created by the module"
  value       = module.mpc_party.config_map_created
}

# Application Integration
output "s3_environment_variables" {
  description = "Environment variables for S3 configuration that applications can use"
  value       = module.mpc_party.s3_environment_variables
}

# Comprehensive Summary
output "deployment_summary" {
  description = "Summary of the MPC party deployment from the enhanced module"
  value       = module.mpc_party.deployment_summary
}

# Application Configuration Guide
output "application_config_guide" {
  description = "Configuration guide for MPC applications"
  value = {
    # Direct environment variables
    environment_variables = module.mpc_party.s3_environment_variables
    
    # Kubernetes deployment configuration
    kubernetes_deployment = {
      namespace       = module.mpc_party.k8s_namespace
      service_account = module.mpc_party.k8s_service_account_name
      irsa_role_arn   = module.mpc_party.irsa_role_arn
      
      # ConfigMap reference for environment variables
      config_map_ref = {
        name = module.mpc_party.config_map_name
      }
      
      # Example pod spec annotations (when using IRSA)
      pod_annotations = module.mpc_party.irsa_enabled ? {
        "eks.amazonaws.com/role-arn" = module.mpc_party.irsa_role_arn
      } : {}
    }
    
    # S3 access configuration
    s3_access = {
      method = module.mpc_party.irsa_enabled ? "IRSA (IAM Roles for Service Accounts)" : "Manual AWS credentials configuration"
      
      irsa_setup = module.mpc_party.irsa_enabled ? {
        enabled         = true
        role_arn        = module.mpc_party.irsa_role_arn
        service_account = module.mpc_party.k8s_service_account_name
        usage           = "Automatically provides AWS credentials to pods using the specified service account"
      } : {
        enabled = false
        note    = "Configure AWS credentials using AWS CLI, instance profiles, or environment variables"
      }
      
      permissions = [
        "s3:GetObject on both buckets",
        "s3:PutObject on both buckets",
        "s3:DeleteObject on both buckets", 
        "s3:ListBucket on both buckets"
      ]
    }
  }
}

# Next Steps Guide  
output "next_steps" {
  description = "Next steps after deploying the MPC party using the enhanced module"
  value = {
    "1_verify_deployment"     = "Check that S3 buckets are created: aws s3 ls | grep ${var.party_name}"
    "2_verify_k8s_resources"  = "Check Kubernetes resources: kubectl get namespace,sa,configmap -n ${module.mpc_party.k8s_namespace}"
    "3_test_s3_access"        = module.mpc_party.irsa_enabled ? "Test IRSA access by creating a test pod with the service account" : "Configure AWS credentials for your applications"
    "4_deploy_mpc_application" = "Deploy your MPC application using the ConfigMap: ${module.mpc_party.config_map_name}"
    "5_configure_networking"   = "If connecting to partners, consider using the partner-consumer or partner-provider examples"
  }
} 