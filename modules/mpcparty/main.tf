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

# S3 Bucket for Public Vault Storage
resource "aws_s3_bucket" "vault_public_bucket" {
  bucket = var.vault_public_bucket_name
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
}

# S3 Bucket for Private Vault Storage
resource "aws_s3_bucket" "vault_private_bucket" {
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

# IRSA Module for secure AWS access from Kubernetes
module "irsa" {
  count  = var.create_irsa ? 1 : 0
  source = "../irsa"
  
  cluster_name             = var.cluster_name
  party_name               = var.party_name
  k8s_namespace            = var.k8s_namespace
  k8s_service_account_name = var.k8s_service_account_name
  name                     = "mpc-party-${var.party_name}"
  
  # S3 access policy for the IRSA role
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
  
  depends_on = [
    aws_s3_bucket.vault_private_bucket,
    aws_s3_bucket.vault_public_bucket,
    kubernetes_namespace.mpc_party_namespace
  ]
}

# Create Kubernetes Service Account (only if not using IRSA)
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
      "eks.amazonaws.com/role-arn" = module.irsa[0].iam_role_arn
    }, var.service_account_annotations)
  }
  
  depends_on = [kubernetes_namespace.mpc_party_namespace, module.irsa]
}

# Create ConfigMap with S3 bucket configuration
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
    "KMS_CORE__PUBLIC_VAULT__STORAGE"  = "s3://${aws_s3_bucket.vault_public_bucket.id}"
    "KMS_CORE__PRIVATE_VAULT__STORAGE" = "s3://${aws_s3_bucket.vault_private_bucket.id}"
    "KMS_CORE__PRIVATE_VAULT__STORAGE__S3__BUCKET" = aws_s3_bucket.vault_private_bucket.id
    "KMS_CORE__PRIVATE_VAULT__STORAGE__S3__PREFIX" = ""
    "KMS_CORE__PUBLIC_VAULT__STORAGE__S3__BUCKET" = aws_s3_bucket.vault_public_bucket.id
    "KMS_CORE__PUBLIC_VAULT__STORAGE__S3__PREFIX" = ""
  }
  
  depends_on = [kubernetes_namespace.mpc_party_namespace, aws_s3_bucket.vault_private_bucket, aws_s3_bucket.vault_public_bucket]
}