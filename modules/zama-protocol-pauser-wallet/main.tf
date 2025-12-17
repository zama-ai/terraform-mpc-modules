# ************
# Data Sources
# ************
data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# Create Kubernetes namespace (optional)
resource "kubernetes_namespace" "zama_protocol_namespace" {
  count = var.k8s_create_namespace ? 1 : 0

  metadata {
    name = var.k8s_namespace
  }
}

# ************
# Application Ethereum Key
# ************
data "aws_iam_policy_document" "tx_sender_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:ImportKeyMaterial",
      "kms:DeleteImportedKeyMaterial"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.kms_cross_account_iam_role_arn != null ? var.kms_cross_account_iam_role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:DescribeKey", "kms:GetPublicKey", "kms:Sign", "kms:Verify"]
    resources = ["*"]
  }
}

# ************
# AWS External KMS Key for Ethereum TxSender
# ************

resource "aws_kms_external_key" "tx_sender" {
  count = var.kms_use_cross_account_kms_key ? 0 : 1
  description             = "Application ${var.app_name} tx sender key for ${var.cluster_name}"
  key_usage               = var.kms_key_usage
  key_spec                = var.kms_key_spec
  deletion_window_in_days = var.kms_deletion_window_in_days
  tags                    = var.tags
  policy                  = data.aws_iam_policy_document.tx_sender_policy.json
}

# ************
# KMS Key Alias for Application Ethereum TxSender Key
# ************
resource "aws_kms_alias" "tx_sender" {
  count = var.kms_use_cross_account_kms_key ? 0 : 1

  name          = "alias/${var.app_name}-${var.cluster_name}"
  target_key_id = aws_kms_external_key.tx_sender[0].id
}

resource "aws_iam_policy" "app_kms_policy" {
  count = var.kms_use_cross_account_kms_key ? 0 : 1

  name = "${var.app_name}-${var.cluster_name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPauserJobToUseKeyForEthereumTxSender"
        Effect = "Allow",
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
          "kms:Verify"
        ],
        Resource = aws_kms_external_key.tx_sender[0].arn
      },
    ]
  })
}

module "iam_assumable_role_tx_sender" {
  count                         = var.zama_protocol_pauser_iam_assumable_role_enabled ? 1 : 0
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.48.0"
  provider_url                  = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  create_role                   = true
  role_name                     = "${var.app_name}-${var.cluster_name}"
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}"]
  role_policy_arns              = [aws_iam_policy.app_kms_policy[0].arn]
}

resource "kubernetes_service_account" "tx_sender_irsa" {
  count = var.zama_protocol_pauser_iam_assumable_role_enabled && var.k8s_service_account_create ? 1 : 0
  metadata {
    name      = var.k8s_service_account_name
    namespace = var.k8s_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_tx_sender[0].iam_role_arn
    }
  }
}

locals {
  kms_key_id = var.kms_use_cross_account_kms_key ? var.kms_cross_account_kms_key_id : aws_kms_external_key.tx_sender[0].id
}

resource "kubernetes_config_map" "mpc_party_config" {
  count = var.k8s_config_map_create ? 1 : 0

  metadata {
    name      = var.k8s_config_map_name
    namespace = var.k8s_namespace

    labels = {
      "app.kubernetes.io/name"       = var.app_name
      "app.kubernetes.io/component"  = "config"
      "app.kubernetes.io/managed-by" = "terraform"
    }

    annotations = {
      "terraform.io/module" = "zama-protocol-pauser-wallet"
    }
  }

  data = {
    "AWS_KMS_KEY_ID"   = local.kms_key_id
  }

  depends_on = [kubernetes_namespace.zama_protocol_namespace]
}
