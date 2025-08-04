# Cluster Information
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.cluster_name
}

output "cluster_vpc_id" {
  description = "VPC ID of the EKS cluster"
  value       = local.cluster_vpc_id
}

output "cluster_subnet_ids" {
  description = "Subnet IDs used by the EKS cluster"
  value       = local.cluster_subnet_ids
}

output "kubernetes_version" {
  description = "Kubernetes version used for the node group"
  value       = local.kubernetes_version
}



# Node Group Outputs
output "nodegroup_name" {
  description = "Name of the enclave node group"
  value       = module.nodegroup.node_group_id
}

output "nodegroup_arn" {
  description = "ARN of the enclave node group"
  value       = module.nodegroup.node_group_arn
}

output "nodegroup_status" {
  description = "Status of the enclave node group"
  value       = module.nodegroup.node_group_status
}

output "nodegroup_capacity_type" {
  description = "Capacity type of the enclave node group"
  value       = var.nodegroup_capacity_type
}

output "nodegroup_instance_types" {
  description = "Instance types of the enclave node group"
  value       = var.nodegroup_instance_types
}

output "nodegroup_launch_template_id" {
  description = "Launch template ID used by the enclave node group"
  value       = module.nodegroup.launch_template_id
}

output "nodegroup_asg_name" {
  description = "Auto Scaling Group name of the enclave node group"
  value       = module.nodegroup.asg_name
}

output "nodegroup_labels" {
  description = "Kubernetes labels applied to the enclave nodes"
  value = merge({
    "nodepool"           = "mpc-enclave"
    "mpc.io/enclave"     = "true"
    "kubeip"             = "true"
  }, var.nodegroup_labels)
}

output "nodegroup_taints" {
  description = "Kubernetes taints applied to the enclave nodes"
  value = merge({
    "mpc-enclave" = {
      key    = "mpc.io/enclave"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  }, var.nodegroup_taints)
}

# Firewall Outputs
output "node_security_group_id" {
  description = "ID of the dedicated security group for enclave nodes"
  value       = var.enable_dedicated_security_group ? module.firewall.node_security_group_id : null
}

output "node_security_group_arn" {
  description = "ARN of the dedicated security group for enclave nodes"
  value       = var.enable_dedicated_security_group ? module.firewall.node_security_group_arn : null
}

output "node_security_group_name" {
  description = "Name of the dedicated security group for enclave nodes"
  value       = var.enable_dedicated_security_group ? module.firewall.node_security_group_name : null
}

output "p2p_security_group_rules" {
  description = "List of P2P security group rules applied"
  value       = var.enable_dedicated_security_group ? module.firewall.p2p_security_group_rules : {}
}

# KubeIP Outputs
output "kubeip_service_account_name" {
  description = "Name of the KubeIP service account"
  value       = module.kubeip.service_account_name
}

output "kubeip_iam_role_arn" {
  description = "ARN of the IAM role for KubeIP"
  value       = module.kubeip.iam_role_arn
}

output "kubeip_daemonset_name" {
  description = "Name of the KubeIP DaemonSet"
  value       = module.kubeip.daemonset_name
}

output "kubeip_configuration" {
  description = "Summary of KubeIP configuration"
  value       = module.kubeip.kubeip_configuration
}

# Infrastructure Summary
output "mpc_infrastructure_summary" {
  description = "Summary of deployed MPC infrastructure"
  value = {
    cluster_name              = var.cluster_name
    environment              = var.environment
    name_prefix              = var.name_prefix
    
    # Node Group Information
    nodegroup_name           = module.nodegroup.node_group_id
    nodegroup_capacity       = {
      min     = var.nodegroup_min_size
      max     = var.nodegroup_max_size
      desired = var.nodegroup_desired_size
    }
    nodegroup_instance_types = var.nodegroup_instance_types
    
    # Networking Information
    security_group_id        = var.enable_dedicated_security_group ? module.firewall.node_security_group_id : null
    
    # P2P Configuration
    p2p_ports               = var.mpc_p2p_ports
    allowed_peer_cidrs      = var.allowed_peer_cidrs
    
    # KubeIP Configuration
    kubeip_enabled          = true
    kubeip_namespace        = var.kubeip_namespace
    kubeip_version          = var.kubeip_version
  }
  
  sensitive = false
}

# Connection Information for Other MPC Participants
output "mpc_connection_info" {
  description = "Information needed by other MPC participants to connect"
  value = {
    p2p_ports           = [for port in var.mpc_p2p_ports : "${port.protocol}:${port.from_port}-${port.to_port}"]
    cluster_region      = data.aws_region.current.name
    security_group_id   = var.enable_dedicated_security_group ? module.firewall.node_security_group_id : null
  }
  
  sensitive = false
}
