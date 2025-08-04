# =============================================================================
# MPC Node Group with KubeIP Configuration - kms-dev-v1 Development Environment  
# =============================================================================
# This configuration deploys the complete MPC infrastructure including:
# - Dedicated enclave node group in public subnets
# - Security groups with MPC-specific ports
# - KubeIP for automatic Elastic IP assignment
# =============================================================================

# Core Configuration
name_prefix  = "kms-dev-v1-mpc"
cluster_name = "kms-development-v1"
environment  = "development"
kubeconfig_path = "~/.kube/config"
kubeconfig_context = "arn:aws:eks:eu-west-3:767398008331:cluster/kms-development-v1"

# Node Group Configuration - Development sizing
nodegroup_min_size         = 1
nodegroup_max_size         = 1  
nodegroup_desired_size     = 1
nodegroup_instance_types   = ["t3.large"]
nodegroup_capacity_type    = "ON_DEMAND"  # Cost optimization for dev
nodegroup_ami_type         = "AL2_x86_64"
nodegroup_disk_size        = 30
# Can be change in the futur if using other interconnection strategy
nodegroup_enable_public_access = true

# Additional node group labels for development
nodegroup_labels = {
  environment     = "development"
  project         = "mpc"
  workload-type   = "enclave"
  cost-center     = "research"
  nodepool        = "mpc-enclave"
  kubeip          = "true"
}

# MPC P2P Port Configuration - Updated ports
mpc_p2p_ports = [
  {
    from_port   = 50001
    to_port     = 50001
    protocol    = "tcp"
    description = "MPC P2P TCP"
  },
  {
    from_port   = 50100
    to_port     = 50100
    protocol    = "tcp"
    description = "MPC gRPC port"
  },
  {
    from_port   = 9646
    to_port     = 9646
    protocol    = "tcp"
    description = "MPC metrics port"
  }
]

# Security Configuration - Development peer access
# NOTE: In production, restrict these to actual partner CIDRs
allowed_peer_cidrs = [
  "52.47.71.156/32",
  "54.217.182.97/32",
  "54.228.234.185/32",
  "99.81.27.249/32",

  # Nat Gateway IP of zws-dev
  "52.48.121.38/32"
]

# Additional security group rules for development
additional_security_group_rules = []

# Remote Access Configuration - Enable for development
enable_remote_access = false
# ec2_ssh_key         = "zws-dev-keypair"  # Update with your key pair name

kubeip_target_node_labels = {
  nodepool        = "mpc-enclave"
  kubeip          = "use"
  workload-type   = "enclave"
}

# Additional node selector for KubeIP pods
kubeip_node_selector = {
  kubeip = "true"
  nodepool = "mpc-enclave"
}

# KubeIP logging for development troubleshooting
kubeip_log_level = "debug"

# KubeIP namespace
kubeip_namespace = "kube-system"

# Development-specific resource limits (lighter for cost optimization)
kubeip_resource_requests = {
  cpu    = "5m"
  memory = "16Mi"
}

kubeip_resource_limits = {
  cpu    = "100m"
  memory = "128Mi"
}

# Common Tags for all resources
tags = {
  Environment   = "development"
  Project       = "mpc"
  Owner         = "zama-team"
  ManagedBy     = "terraform"
  CostCenter    = "research"
  Purpose       = "mpc-development"
  
  # Terragrunt tracking
  TerragruntPath = "examples/terragrunt-infra/kms-dev-v1/mpc-nodegroup-kubeip"
}