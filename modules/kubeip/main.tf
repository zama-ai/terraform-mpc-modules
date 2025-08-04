# KubeIP Module - Automatically assigns Elastic IPs to Kubernetes nodes
# This module deploys KubeIP as a DaemonSet to assign pre-provisioned EIPs to nodes

# Data sources
data "aws_region" "current" {}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# Get caller identity for account ID
data "aws_caller_identity" "current" {}

# Construct OIDC provider ARN from cluster issuer URL
locals {
  # Extract the OIDC issuer URL without the https:// protocol
  oidc_issuer_host = var.enable_irsa ? replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "") : ""
  # Construct the OIDC provider ARN
  oidc_provider_arn = var.enable_irsa ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_issuer_host}" : ""
}

# KubeIP ServiceAccount with IRSA
resource "kubernetes_service_account" "kubeip" {
  count = var.create_service_account ? 1 : 0

  metadata {
    name      = var.service_account_name
    namespace = var.namespace
    
    annotations = var.enable_irsa ? {
      "eks.amazonaws.com/role-arn" = module.kubeip_eks_role[0].iam_role_arn
    } : {}

    labels = merge({
      "app.kubernetes.io/name"      = "kubeip"
      "app.kubernetes.io/instance"  = var.name
      "app.kubernetes.io/component" = "ip-assigner"
      "app.kubernetes.io/part-of"   = "mpc-infrastructure"
    }, var.service_account_labels)
  }

  automount_service_account_token = true
}

# IRSA Role using terraform-aws-modules (same approach as official example)
module "kubeip_eks_role" {
  count = var.enable_irsa ? 1 : 0
  
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.name}-kubeip-eks-role"

  role_policy_arns = {
    "kubeip-policy" = aws_iam_policy.kubeip_policy[0].arn
  }

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${var.service_account_name}"]
    }
  }

  tags = merge(var.tags, {
    Component = "kubeip-irsa"
  })
}

# IAM Policy for KubeIP - Based on official DoIT International implementation
resource "aws_iam_policy" "kubeip_policy" {
  count = var.enable_irsa ? 1 : 0

  name        = "${var.name}-kubeip-policy"
  description = "IAM policy for KubeIP to manage Elastic IPs - Based on official implementation"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeAddresses",
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress",
          "ec2:CreateTags",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name}-kubeip-policy"
    Component = "kubeip-policy"
  })
}

# RBAC - ClusterRole for KubeIP (based on official DoIT implementation)
resource "kubernetes_cluster_role" "kubeip_cluster_role" {
  metadata {
    name = "${var.name}-kubeip-cluster-role"
    
    labels = {
      "app.kubernetes.io/name"      = "kubeip"
      "app.kubernetes.io/instance"  = var.name
      "app.kubernetes.io/component" = "rbac"
    }
  }
  rule {
    api_groups = ["*"]
    resources  = ["nodes"]
    verbs      = ["get"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create", "delete", "get"]
  }
}

# RBAC - ClusterRoleBinding for KubeIP
resource "kubernetes_cluster_role_binding" "kubeip_cluster_role_binding" {
  metadata {
    name = "${var.name}-kubeip-cluster-role-binding"
    
    labels = {
      "app.kubernetes.io/name"      = "kubeip"
      "app.kubernetes.io/instance"  = var.name
      "app.kubernetes.io/component" = "rbac"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kubeip_cluster_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.create_service_account ? kubernetes_service_account.kubeip[0].metadata[0].name : var.service_account_name
    namespace = var.namespace
  }
}

# KubeIP DaemonSet
resource "kubernetes_daemonset" "kubeip" {
  metadata {
    name      = var.name
    namespace = var.namespace

    labels = merge({
      "app.kubernetes.io/name"      = "kubeip"
      "app.kubernetes.io/instance"  = var.name
      "app.kubernetes.io/version"   = var.kubeip_version
      "app.kubernetes.io/component" = "ip-assigner"
      "app.kubernetes.io/part-of"   = "mpc-infrastructure"
    }, var.daemonset_labels)
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name"     = "kubeip"
        "app.kubernetes.io/instance" = var.name
      }
    }

    template {
      metadata {
        labels = merge({
          "app.kubernetes.io/name"      = "kubeip"
          "app.kubernetes.io/instance"  = var.name
          "app.kubernetes.io/version"   = var.kubeip_version
          "app.kubernetes.io/component" = "ip-assigner"
        }, var.pod_labels)

        annotations = merge({
          "prometheus.io/scrape" = "false"  # Disable scraping by default
        }, var.pod_annotations)
      }

      spec {
        service_account_name             = var.create_service_account ? kubernetes_service_account.kubeip[0].metadata[0].name : var.service_account_name
        automount_service_account_token  = true
        termination_grace_period_seconds = 30

        # Standard tolerations for system workloads
        toleration {
          effect   = "NoSchedule"
          operator = "Exists"
        }

        toleration {
          effect   = "NoExecute"
          operator = "Exists"
        }

        # Additional custom tolerations
        dynamic "toleration" {
          for_each = var.additional_tolerations
          content {
            key                = toleration.value.key
            operator           = toleration.value.operator
            value              = toleration.value.value
            effect             = toleration.value.effect
            toleration_seconds = toleration.value.toleration_seconds
          }
        }

        # Node selector to target specific nodes
        node_selector = var.node_selector

        container {
          name              = "kubeip-agent"
          image             = "${var.kubeip_image}:${var.kubeip_version}"
          image_pull_policy = var.image_pull_policy

          # Node name from Kubernetes API
          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          # EIP filter configuration
          env {
            name  = "FILTER"
            value = var.eip_filter_tags
          }

          # Log level configuration
          env {
            name  = "LOG_LEVEL"
            value = var.log_level
          }

          # Additional environment variables
          dynamic "env" {
            for_each = var.environment_variables
            content {
              name  = env.key
              value = env.value
            }
          }

          # Resource limits and requests (based on official example)
          resources {
            requests = var.resource_requests
            limits   = var.resource_limits
          }

        }
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = "1"
      }
    }
  }

  depends_on = [
    kubernetes_service_account.kubeip,
    kubernetes_cluster_role.kubeip_cluster_role,
    kubernetes_cluster_role_binding.kubeip_cluster_role_binding
  ]
}

