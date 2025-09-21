# MPC Party Information
output "party_name" {
  description = "Name of the MPC party"
  value       = var.party_name
}

#debug
output "eks_vpc_config" {
  value = data.aws_eks_cluster.cluster
}

#debug cluster_sg_rules
output "cluster_sg_rules" {
  value = data.aws_vpc_security_group_rules.cluster_rules
}

# Cluster Information
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.cluster_name
}

# Vault Bucket Information
output "vault_bucket_storage_summary" {
  description = "Summary of the vault buckets public and private storage"
  value = {
    private_bucket_name        = aws_s3_bucket.vault_private_bucket.id
    public_bucket_name         = aws_s3_bucket.vault_public_bucket.id
    private_bucket_arn         = aws_s3_bucket.vault_private_bucket.arn
    public_bucket_arn          = aws_s3_bucket.vault_public_bucket.arn
    private_bucket_domain_name = aws_s3_bucket.vault_private_bucket.bucket_domain_name
    public_bucket_domain_name  = aws_s3_bucket.vault_public_bucket.bucket_domain_name
    private_bucket_url         = "https://${aws_s3_bucket.vault_private_bucket.bucket_domain_name}"
    public_bucket_url          = "https://${aws_s3_bucket.vault_public_bucket.bucket_domain_name}"
  }
}

# IRSA Information
output "irsa_summary" {
  description = "Summary of the IRSA role for MPC party"
  value = {
    irsa_enabled   = var.create_irsa
    irsa_role_arn  = var.create_irsa ? module.iam_assumable_role_mpc_party.iam_role_arn : null
    irsa_role_name = var.create_irsa ? module.iam_assumable_role_mpc_party.iam_role_name : null
  }
}

# Kubernetes Service Account Information
output "k8s_service_account_summary" {
  description = "Summary of the Kubernetes service account for MPC party"
  value = {
    service_account_name              = var.k8s_service_account_name
    service_account_created           = var.create_service_account && !var.create_irsa
    service_account_namespace         = var.k8s_namespace
    service_account_namespace_created = var.create_namespace
    service_account_role_arn          = var.create_service_account && var.create_irsa ? module.iam_assumable_role_mpc_party.iam_role_arn : null
  }
}

# Kubernetes ConfigMap Information
output "k8s_configmap_summary" {
  description = "Summary of the Kubernetes ConfigMap for MPC party"
  value = {
    configmap_name    = var.create_config_map ? (var.config_map_name != null ? var.config_map_name : "mpc-party-config-${var.party_name}") : null
    configmap_created = var.create_config_map
    data              = var.create_config_map ? kubernetes_config_map.mpc_party_config[0].data : null
  }
}

# EKS Managed Node Group Information
output "eks_managed_node_group_summary" {
  description = "Summary of the EKS managed node group for MPC party"
  value = var.create_nodegroup ? {
    node_group_arn    = module.eks_managed_node_group[0].node_group_arn
    node_group_status = module.eks_managed_node_group[0].node_group_status
    node_group_taints = module.eks_managed_node_group[0].node_group_taints
  } : null
}

# Nitro Enclaves Information
output "nitro_enclaves_summary" {
  description = "Summary of the Nitro Enclaves for MPC party"
  value = var.create_nodegroup && var.nodegroup_enable_nitro_enclaves ? {
    nitro_enclaves_total_allocated_resources = {
      cpu_count  = local.node_group_nitro_enclaves_cpu_count
      memory_mib = local.node_group_nitro_enclaves_memory_mib
    }
  } : null
}

# RDS Information
output "rds_summary" {
  description = "Aggregated RDS database information"
  value = var.enable_rds ? {
    db_name  = module.rds_instance[0].db_instance_name
    endpoint = module.rds_instance[0].db_instance_endpoint
    port     = module.rds_instance[0].db_instance_port
    username = nonsensitive(module.rds_instance[0].db_instance_username)
  } : null
}

# Node Group Tolerations
output "node_group_tolerations" {
  description = "Kubernetes tolerations derived from EKS node group taints"
  value       = local.node_group_tolerations
}

# Node Group Auto Resolve Security Group Summary
output "nodegroup_auto_assign_security_group_summary" {
  description = "Summary of the auto resolved security group"
  value = var.nodegroup_auto_assign_security_group && local.auto_resolved_node_sg != null ? {
    auto_resolved_node_sg    = local.auto_resolved_node_sg
    auto_resolved_cluster_sg = local.auto_resolved_cluster_sg
    sg_rules_ids             = data.aws_vpc_security_group_rules.cluster_rules[0].ids
  } : null
}