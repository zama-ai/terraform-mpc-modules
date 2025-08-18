# Data source to get eks cluster
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_subnet" "cluster_subnets" {
  for_each = toset(data.aws_eks_cluster.cluster.vpc_config[0].subnet_ids)
  id       = each.value
}

locals {
  private_subnet_ids = [
    for subnet_id, subnet in data.aws_subnet.cluster_subnets : subnet_id
    if subnet.map_public_ip_on_launch == false
  ]
}

# Create Kubernetes namespace (optional)
resource "kubernetes_namespace" "mpc_party_namespace" {
  count = var.create_namespace ? 1 : 0
  
  metadata {
    name = var.k8s_namespace
    
    labels = merge({
      "app.kubernetes.io/name"       = "mpc-party"
      "app.kubernetes.io/component"  = "storage"
      "app.kubernetes.io/part-of"    = "mpc-cluster"
      "app.kubernetes.io/managed-by" = "terraform"
      "mpc.io/party-name"            = var.party_name
    }, var.namespace_labels)
    
    annotations = merge({
      "terraform.io/module"   = "mpcparty"
      "mpc.io/party-name"     = var.party_name
      "mpc.io/cluster"        = var.cluster_name
    }, var.namespace_annotations)
  }
}

# ***************************************
#  S3 Buckets for Vault Public Storage
# ***************************************
resource "aws_s3_bucket" "vault_public_bucket" {
  bucket = var.vault_public_bucket_name
  force_destroy = true
  tags = merge(var.common_tags, {
    "Name"        = var.vault_public_bucket_name
    "Type"        = "public-vault"
    "Party"       = var.party_name
    "Purpose"     = "mpc-public-storage"
  })
}

resource "aws_s3_bucket_ownership_controls" "vault_public_bucket" {
  bucket = aws_s3_bucket.vault_public_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "vault_public_bucket" {
  bucket = aws_s3_bucket.vault_public_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "vault_public_bucket" {
  bucket = aws_s3_bucket.vault_public_bucket.id

  block_public_policy     = false
  restrict_public_buckets = false
  block_public_acls       = false
  ignore_public_acls      = false
}

resource "aws_s3_bucket_cors_configuration" "vault_public_bucket_cors" {
  bucket = aws_s3_bucket.vault_public_bucket.id

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["Access-Control-Allow-Origin"]
  }
}

resource "aws_s3_bucket_policy" "vault_public_bucket_policy" {
  bucket = aws_s3_bucket.vault_public_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.vault_public_bucket.id}/*"
      },
      {
        Sid       = "ZamaList"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:ListBucket"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.vault_public_bucket.id}"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.vault_public_bucket]
}

# ***************************************
#  S3 Buckets for Vault Private Storage
# ***************************************
resource "aws_s3_bucket" "vault_private_bucket" {
  force_destroy = true
  bucket = var.vault_private_bucket_name
  tags = merge(var.common_tags, {
    "Name"        = var.vault_private_bucket_name
    "Type"        = "private-vault"
    "Party"       = var.party_name
    "Purpose"     = "mpc-private-storage"
  })
}

resource "aws_s3_bucket_ownership_controls" "vault_private_bucket" {
  bucket = aws_s3_bucket.vault_private_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "vault_private_bucket" {
  bucket = aws_s3_bucket.vault_private_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "vault_private_bucket" {
  bucket = aws_s3_bucket.vault_private_bucket.id
  block_public_policy = true
}

# ***************************************
#  IAM Policy for MPC Party
# ***************************************
resource "aws_iam_policy" "mpc_aws" {
  name   = "mpc-${var.cluster_name}-${var.party_name}"
  policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Sid    = "AllowObjectActions"
      Effect = "Allow"
      Action = "s3:*Object"
      Resource = [
        "arn:aws:s3:::${aws_s3_bucket.vault_private_bucket.id}/*",
        "arn:aws:s3:::${aws_s3_bucket.vault_public_bucket.id}/*"
      ]
    },
    {
      Sid    = "AllowListBucket"
      Effect = "Allow"
      Action = "s3:ListBucket"
      Resource = [
        "arn:aws:s3:::${aws_s3_bucket.vault_private_bucket.id}",
        "arn:aws:s3:::${aws_s3_bucket.vault_public_bucket.id}"
      ]
    }
  ]
  })
}

module "iam_assumable_role_mpc_party" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.48.0"
  provider_url                  = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  create_role                   = true
  role_name                     = "mpc-${var.cluster_name}-${var.party_name}-nodegroup"
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}"]
  role_policy_arns              = [aws_iam_policy.mpc_aws.arn]
  depends_on = [aws_s3_bucket.vault_private_bucket, aws_s3_bucket.vault_public_bucket, kubernetes_namespace.mpc_party_namespace]
}

resource "kubernetes_service_account" "mpc_party_service_account" {
  count = var.create_service_account ? 1 : 0
  metadata {
    name      = var.k8s_service_account_name
    namespace = var.k8s_namespace
    
    labels = merge({
      "app.kubernetes.io/name"       = "mpc-party"
      "app.kubernetes.io/component"  = "service-account"
      "app.kubernetes.io/part-of"    = "mpc-cluster"
      "app.kubernetes.io/managed-by" = "terraform"
      "mpc.io/party-name"            = var.party_name
    }, var.service_account_labels)
    
    annotations = merge({
      "terraform.io/module"   = "mpcparty"
      "mpc.io/party-name"     = var.party_name
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_mpc_party.iam_role_arn
    }, var.service_account_annotations)
  }
  depends_on = [kubernetes_namespace.mpc_party_namespace, module.iam_assumable_role_mpc_party]
}

# ***************************************
#  ConfigMap with S3 bucket configuration
# ***************************************
resource "kubernetes_config_map" "mpc_party_config" {
  count = var.create_config_map ? 1 : 0
  
  metadata {
    name      = var.config_map_name != null ? var.config_map_name : "mpc-party-config-${var.party_name}"
    namespace = var.k8s_namespace
    
    labels = {
      "app.kubernetes.io/name"       = "mpc-party"
      "app.kubernetes.io/component"  = "config"
      "app.kubernetes.io/part-of"    = "mpc-cluster"
      "app.kubernetes.io/managed-by" = "terraform"
      "mpc.io/party-name"            = var.party_name
    }
    
    annotations = {
      "terraform.io/module" = "mpcparty"
      "mpc.io/party-name"   = var.party_name
    }
  }
  
  data = {
    "CORE_CLIENT__S3_ENDPOINT" = "https://${aws_s3_bucket.vault_public_bucket.id}.s3.${aws_s3_bucket.vault_public_bucket.region}.amazonaws.com"
    "KMS_CORE__PUBLIC_VAULT__STORAGE"  = "s3://${aws_s3_bucket.vault_public_bucket.id}"
    "KMS_CORE__PRIVATE_VAULT__STORAGE" = "s3://${aws_s3_bucket.vault_private_bucket.id}"
    "KMS_CORE__PRIVATE_VAULT__STORAGE__S3__BUCKET" = aws_s3_bucket.vault_private_bucket.id
    "KMS_CORE__PRIVATE_VAULT__STORAGE__S3__PREFIX" = ""
    "KMS_CORE__PUBLIC_VAULT__STORAGE__S3__BUCKET" = aws_s3_bucket.vault_public_bucket.id
    "KMS_CORE__PUBLIC_VAULT__STORAGE__S3__PREFIX" = ""
  }
  
  depends_on = [kubernetes_namespace.mpc_party_namespace, aws_s3_bucket.vault_private_bucket, aws_s3_bucket.vault_public_bucket]
}

# ***************************************
#  EKS Managed Node Group
# ***************************************
module "eks_managed_node_group" {
  count = var.create_nodegroup ? 1 : 0
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "21.0.6"

  name         = var.nodegroup_name
  cluster_name = var.cluster_name
  kubernetes_version = data.aws_eks_cluster.cluster.version

  subnet_ids = local.private_subnet_ids

  cluster_primary_security_group_id = data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
  vpc_security_group_ids            = concat(tolist(data.aws_eks_cluster.cluster.vpc_config[0].security_group_ids), var.nodegroup_additional_security_group_ids)

  # Scaling Configuration
  min_size     = var.nodegroup_min_size
  max_size     = var.nodegroup_max_size
  desired_size = var.nodegroup_desired_size

  # Instance Configuration (only when not using launch template)
  instance_types = var.nodegroup_instance_types
  capacity_type  = var.nodegroup_capacity_type
  ami_type       = var.nodegroup_ami_type
  
  # Disable settings that conflict with launch template
  enable_bootstrap_user_data = false
  
  # Cluster service CIDR for user data
  cluster_service_cidr = data.aws_eks_cluster.cluster.kubernetes_network_config[0].service_ipv4_cidr
  
  # Disk configuration (only when not using launch template)
  disk_size = var.nodegroup_disk_size

  # Remote Access Configuration (only when not using launch template)
  remote_access = var.nodegroup_enable_remote_access ? {
    ec2_ssh_key               = var.nodegroup_ec2_ssh_key
    source_security_group_ids = var.nodegroup_source_security_group_ids
  } : null

  # Labels and Taints
  labels = var.nodegroup_labels
  taints = var.nodegroup_taints

  # Tags
  tags = var.tags
}