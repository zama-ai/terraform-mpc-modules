# MPC Infrastructure Root Module
# Orchestrates nodegroup, firewall, and kubeip child modules to deploy
# dedicated enclave node groups with automatic public IP assignment

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}


# Data sources
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}


# Get details for all subnets used by the EKS cluster
data "aws_subnet" "cluster_subnets" {
  for_each = toset(data.aws_eks_cluster.cluster.vpc_config[0].subnet_ids)
  id       = each.value
}

# Local values for computed data
locals {
  cluster_vpc_id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
  cluster_subnet_ids = data.aws_eks_cluster.cluster.vpc_config[0].subnet_ids
  
  # Use specified kubernetes_version or default to cluster version
  kubernetes_version = var.kubernetes_version != null ? var.kubernetes_version : data.aws_eks_cluster.cluster.version

  # Get public subnet IDs by filtering subnets that have a route to an internet gateway
  public_subnet_ids = length(coalesce(var.subnet_ids, [])) > 0 ? var.subnet_ids : [
    for subnet_id, subnet in data.aws_subnet.cluster_subnets : subnet_id
    if subnet.map_public_ip_on_launch == true
  ]

  private_subnet_ids = length(coalesce(var.subnet_ids, [])) > 0 ? var.subnet_ids : [
    for subnet_id, subnet in data.aws_subnet.cluster_subnets : subnet_id
    if subnet.map_public_ip_on_launch == false
  ]
  
  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    "Environment"   = var.environment
    "Project"       = "mpc-infrastructure"
    "ManagedBy"     = "terraform"
    "ClusterName"   = var.cluster_name
  })
  
  # Convert EIP filter tags map to KubeIP filter string format
  # Example: { kubeip = "reserved", environment = "demo" } 
  # Becomes: "Name=tag:kubeip,Values=reserved;Name=tag:environment,Values=demo"
  kubeip_filter_string = join(";", [
    for key, value in var.kubeip_eip_filter_tags : "Name=tag:${key},Values=${value}"
  ])
}



# Create dedicated security group with MPC-specific rules
module "firewall" {
  source = "./modules/firewall"
  
  name                          = "${var.name_prefix}-firewall"
  cluster_name                  = var.cluster_name
  create_node_security_group    = true
  node_security_group_name      = "${var.name_prefix}-enclave-sg"
  node_security_group_description = "Security group for MPC enclave nodes with restricted P2P access"
  
  # P2P port configuration for MPC networking
  p2p_ports = var.mpc_p2p_ports
  
  # Allowed peer access (other MPC participants)
  allowed_peer_cidrs            = var.allowed_peer_cidrs
  allowed_peer_security_groups  = var.allowed_peer_security_groups
  
  # Additional security rules for MPC requirements
  additional_security_group_rules = var.additional_security_group_rules
  
  tags = merge(local.common_tags, {
    "Component" = "firewall"
    "Purpose"   = "mpc-enclave-security"
  }, var.firewall_tags)
}

# Create dedicated node group for MPC enclaves
module "nodegroup" {
  source = "./modules/nodegroup"
  
  name                = var.name_prefix
  cluster_name        = var.cluster_name
  kubernetes_version  = local.kubernetes_version
  
  # Scaling configuration
  min_size     = var.nodegroup_min_size
  max_size     = var.nodegroup_max_size
  desired_size = var.nodegroup_desired_size
  
  # Instance configuration
  instance_types = var.nodegroup_instance_types
  capacity_type  = var.nodegroup_capacity_type
  ami_type       = var.nodegroup_ami_type
  disk_size      = var.nodegroup_disk_size

  subnet_ids = var.nodegroup_enable_public_access ? local.public_subnet_ids : local.private_subnet_ids

  cluster_primary_security_group_id = data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
  
  # Security groups from firewall module
  security_group_ids = var.enable_dedicated_security_group ? concat([module.firewall.node_security_group_id], var.nodegroup_additional_security_group_ids) : concat(tolist(data.aws_eks_cluster.cluster.vpc_config[0].security_group_ids), var.nodegroup_additional_security_group_ids)
  
  # Remote access configuration
  enable_remote_access      = var.enable_remote_access
  ec2_ssh_key              = var.ec2_ssh_key
  source_security_group_ids = var.source_security_group_ids
  
  # Node labels and taints for MPC workloads
  labels = merge({
    "nodepool"           = "mpc-enclave"
    "mpc.io/enclave"     = "true"
    "kubeip"             = "true"  # Label for KubeIP targeting
  }, var.nodegroup_labels)
  
  taints = merge({
    # Dedicated taint to ensure only MPC workloads run on these nodes
    "mpc-enclave" = {
      key    = "mpc.io/enclave"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  }, var.nodegroup_taints)
  
  tags = merge(local.common_tags, {
    "Component" = "nodegroup"
    "Purpose"   = "mpc-enclave-compute"
  }, var.nodegroup_tags)
  
  depends_on = [module.firewall]
}

# Deploy KubeIP for automatic Elastic IP assignment
module "kubeip" {
  source = "./modules/kubeip"
  
  name         = "${var.name_prefix}-kubeip"
  cluster_name = var.cluster_name
  namespace    = var.kubeip_namespace
  
  # KubeIP configuration
  kubeip_version = var.kubeip_version
  
  # EIP filtering using AWS tags (converted from map to string)
  eip_filter_tags = local.kubeip_filter_string
  
  # Target nodes with specific labels
  target_node_labels = var.kubeip_target_node_labels
  node_selector      = var.kubeip_node_selector
  
  # Logging configuration
  log_level = var.kubeip_log_level
  
  # Service account and IRSA
  create_service_account = true
  service_account_name   = "${var.name_prefix}-kubeip-service-account"
  enable_irsa           = true
  
  # Additional tolerations for MPC enclave nodes
  additional_tolerations = concat([
    {
      key      = "mpc.io/enclave"
      operator = "Equal"
      value    = "true"
      effect   = "NoSchedule"
    }
  ], var.kubeip_additional_tolerations)
  
  # Resource configuration
  resource_requests = var.kubeip_resource_requests
  resource_limits   = var.kubeip_resource_limits
  
  tags = merge(local.common_tags, {
    "Component" = "kubeip"
    "Purpose"   = "ip-assignment"
  }, var.kubeip_tags)
  
  depends_on = [module.nodegroup]
}
