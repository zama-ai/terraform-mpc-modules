# MPC Party Outputs - Using Enhanced Module

# Party Information
output "party_name" {
  description = "Name of the deployed MPC party"
  value       = module.mpc_party.party_name
}

# RDS Information
output "rds_summary" {
  description = "Aggregated RDS database information"
  value       = module.mpc_party.rds_summary
}

# Vault Bucket Information
output "vault_bucket_storage_summary" {
  description = "Summary of the vault bucket storage"
  value       = module.mpc_party.vault_bucket_storage_summary
}

# EKS Managed Node Group Information
output "eks_managed_node_group_summary" {
  description = "Summary of the EKS managed node group"
  value       = module.mpc_party.eks_managed_node_group_summary
}

# IRSA Information
output "irsa_summary" {
  description = "Summary of the IRSA role for MPC party"
  value       = module.mpc_party.irsa_summary
}

# Kubernetes Service Account Information
output "k8s_service_account_summary" {
  description = "Summary of the Kubernetes service account for MPC party"
  value       = module.mpc_party.k8s_service_account_summary
}

# Kubernetes ConfigMap Information
output "k8s_configmap_summary" {
  description = "Summary of the Kubernetes ConfigMap for MPC party"
  value       = module.mpc_party.k8s_configmap_summary
}

#debug
# output "eks_vpc_config" {
#   value = module.mpc_party.eks_vpc_config
# }

# output "cluster_sg_rules" {
#   value = module.mpc_party.cluster_sg_rules
# }

output "cluster_name" {
  value = module.mpc_party.cluster_name
}

