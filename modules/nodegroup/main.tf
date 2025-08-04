# Data sources for AMI and cluster information
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# EKS Managed Node Group
module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "21.0.6"

  name         = var.name
  cluster_name = var.cluster_name
  kubernetes_version = var.kubernetes_version

  subnet_ids = var.subnet_ids

  cluster_primary_security_group_id = var.cluster_primary_security_group_id
  vpc_security_group_ids            = var.security_group_ids

  # Scaling Configuration
  min_size     = var.min_size
  max_size     = var.max_size
  desired_size = var.desired_size

  # Instance Configuration (only when not using launch template)
  instance_types = var.instance_types
  capacity_type  = var.capacity_type
  ami_type       = var.ami_type
  


  
  # Disable settings that conflict with launch template
  enable_bootstrap_user_data = false
  
  # Cluster service CIDR for user data
  cluster_service_cidr = data.aws_eks_cluster.cluster.kubernetes_network_config[0].service_ipv4_cidr
  
  # Disk configuration (only when not using launch template)
  disk_size = var.disk_size

  # Remote Access Configuration (only when not using launch template)
  remote_access = var.enable_remote_access ? {
    ec2_ssh_key               = var.ec2_ssh_key
    source_security_group_ids = var.source_security_group_ids
  } : null

  # Labels and Taints
  labels = var.labels
  taints = var.taints

  # Tags
  tags = var.tags
}