# Service Account Outputs
output "service_account_name" {
  description = "Name of the KubeIP service account"
  value       = var.create_service_account ? kubernetes_service_account.kubeip[0].metadata[0].name : var.service_account_name
}

output "service_account_namespace" {
  description = "Namespace of the KubeIP service account"
  value       = var.create_service_account ? kubernetes_service_account.kubeip[0].metadata[0].namespace : var.namespace
}

output "service_account_uid" {
  description = "UID of the KubeIP service account"
  value       = var.create_service_account ? kubernetes_service_account.kubeip[0].metadata[0].uid : null
}

# IAM Outputs
output "iam_role_arn" {
  description = "ARN of the IAM role for KubeIP (if IRSA is enabled)"
  value       = var.enable_irsa ? module.kubeip_eks_role[0].iam_role_arn : null
}

output "iam_role_name" {
  description = "Name of the IAM role for KubeIP (if IRSA is enabled)"
  value       = var.enable_irsa ? module.kubeip_eks_role[0].iam_role_name : null
}

output "iam_policy_arn" {
  description = "ARN of the IAM policy for KubeIP (if IRSA is enabled)"
  value       = var.enable_irsa ? aws_iam_policy.kubeip_policy[0].arn : null
}

# DaemonSet Outputs
output "daemonset_name" {
  description = "Name of the KubeIP DaemonSet"
  value       = kubernetes_daemonset.kubeip.metadata[0].name
}

output "daemonset_namespace" {
  description = "Namespace of the KubeIP DaemonSet"
  value       = kubernetes_daemonset.kubeip.metadata[0].namespace
}

output "daemonset_uid" {
  description = "UID of the KubeIP DaemonSet"
  value       = kubernetes_daemonset.kubeip.metadata[0].uid
}

output "daemonset_labels" {
  description = "Labels applied to the KubeIP DaemonSet"
  value       = kubernetes_daemonset.kubeip.metadata[0].labels
}

# RBAC Outputs
output "cluster_role_name" {
  description = "Name of the KubeIP ClusterRole"
  value       = kubernetes_cluster_role.kubeip_cluster_role.metadata[0].name
}

output "cluster_role_binding_name" {
  description = "Name of the KubeIP ClusterRoleBinding"
  value       = kubernetes_cluster_role_binding.kubeip_cluster_role_binding.metadata[0].name
}

# Configuration Summary
output "kubeip_configuration" {
  description = "Summary of KubeIP configuration"
  value = {
    name                = var.name
    namespace           = var.namespace
    kubeip_version      = var.kubeip_version
    eip_filter_tags     = var.eip_filter_tags
    target_node_labels  = var.target_node_labels
    irsa_enabled        = var.enable_irsa
    image               = "${var.kubeip_image}:${var.kubeip_version}"
  }
}