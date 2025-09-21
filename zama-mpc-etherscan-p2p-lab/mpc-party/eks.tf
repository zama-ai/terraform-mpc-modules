

# Launch template for system-ng: enable IMDSv2 with HopLimit=2 so pods can reach IMDS
resource "aws_launch_template" "system_ng_lt" {
  name_prefix = "${var.cluster_name}-system-ng-"

  # IMPORTANT: do NOT set AMI here; let EKS pick the AMI for managed nodegroups.
  # Also skip block_device_mappings here so you can keep `disk_size` in the nodegroup.

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"   # or "optional"
    http_put_response_hop_limit = 2            # critical so pods can reach IMDS
  }

  # Root volume on gp3; adjust size as you like (40 is enough for system nodes)
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 50     # ← disk size GiB
      volume_type           = "gp3"
      iops                  = 3000   # gp3 baseline
      throughput            = 125    # gp3 baseline
      delete_on_termination = true
    }
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = "${var.cluster_name}-system-ng"
    }
  }
}

# Terraform: create a dedicated EKS Managed Node Group for System workloads
resource "aws_eks_node_group" "system_ng" {
  cluster_name    = var.cluster_name
  node_group_name = "system_ng"
  node_role_arn   = "arn:aws:iam::455309426926:role/mpc-party-nodegroup-eks-node-group-20250919031002116900000001"
  subnet_ids      = ["subnet-0b7a706ae7eae6809", "subnet-03437f7c685339999", "subnet-0a368495c072e860b"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 3
  }

  instance_types = ["t3.medium"] # or c7a.large/m7a.large etc

  
  labels = {
    role     = "system"
    workload = "system-addons"
  }

  # 👇 Reference the launch template with IMDS settings
  launch_template {
    id      = aws_launch_template.system_ng_lt.id
    version = "$Latest"
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name     = "${var.cluster_name}-system-ng"
    Workload = "system"
  }

}

# Default StorageClass backed by EBS CSI (gp3)
resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      # Make gp3 the default StorageClass
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  parameters             = {
    type  = "gp3"
    fsType = "ext4"
  }
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
}