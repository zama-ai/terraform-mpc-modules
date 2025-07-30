# ==============================================================================
# VPC Endpoint Consumer Module - Main Configuration
# ==============================================================================
# 
# This module creates VPC interface endpoints to connect to partner MPC services.
# It supports two configuration modes:
#
# 1. EKS Cluster Lookup: Automatically retrieves network details from EKS cluster
# 2. Direct Specification: Uses manually provided VPC/subnet/security group IDs
#
# The module uses conditional logic to determine which configuration mode to use
# based on whether cluster_name is provided.
# ==============================================================================

# Provider requirements are defined in versions.tf

# Data source to get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Conditional data source to lookup EKS cluster (only when cluster_name is provided)
# This is only executed when using EKS Cluster Lookup mode
data "aws_eks_cluster" "selected" {
  count = var.cluster_name != null ? 1 : 0
  name  = var.cluster_name
}

# Local values for determining network configuration based on mode
locals {
  # Determine configuration mode and values to use
  # Mode detection: if cluster_name is provided, use EKS lookup mode
  use_eks_cluster = var.cluster_name != null && var.cluster_name != ""
  
  # Network configuration based on mode
  # In EKS mode: extract from cluster data source
  # In direct mode: use provided variables
  vpc_id = local.use_eks_cluster ? data.aws_eks_cluster.selected[0].vpc_config[0].vpc_id : var.vpc_id
  subnet_ids = local.use_eks_cluster ? data.aws_eks_cluster.selected[0].vpc_config[0].subnet_ids : var.subnet_ids
  security_group_ids = local.use_eks_cluster ? [data.aws_eks_cluster.selected[0].vpc_config[0].cluster_security_group_id] : (var.security_group_ids != null ? var.security_group_ids : [])
  
  # Cluster name for tagging (use provided cluster_name or default)
  cluster_name_for_tags = var.cluster_name != null ? var.cluster_name : "mpc-cluster"

  # Use the VPC endpoint service names provided by partners
  # Note: vpc_endpoint_service_name must be provided directly by the partner
  # as AWS auto-generates these names when creating VPC endpoint services
  vpc_endpoint_service_names = [
    for service in var.party_services : service.vpc_endpoint_service_name
  ]

  # Create a map for easy reference
  partner_service_map = {
    for i, service in var.party_services : "${service.name}-${i}" => {
      name                      = service.name
      region                    = service.region
      account_id                = service.account_id
      vpc_endpoint_service_name = local.vpc_endpoint_service_names[i]
      ports                     = service.ports
      create_kube_service       = service.create_kube_service
      kube_service_config       = service.kube_service_config
    }
  }
}

# Create VPC interface endpoints to connect to partner MPC services
resource "aws_vpc_endpoint" "party_interface_endpoints" {
  count = length(var.party_services)

  vpc_id             = local.vpc_id
  service_name       = local.vpc_endpoint_service_names[count.index]
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.subnet_ids
  security_group_ids = local.security_group_ids
  service_region     = var.party_services[count.index].region

  # Policy document for the VPC endpoint
  //policy = var.endpoint_policy != null ? var.endpoint_policy : jsonencode({
  //  Version = "2012-10-17"
  //  Statement = [
  //    {
  //      Effect    = "Allow"
  //      Principal = "*"
  //      Action = [
  //        "*"
  //      ]
  //      Resource = "*"
  //    }
  //  ]
  //})

  # DNS options
  private_dns_enabled = var.private_dns_enabled

  # Route table IDs if specified
  route_table_ids = var.route_table_ids

  tags = merge(
    var.common_tags,
    {
      Name                  = "${var.name_prefix}-${var.party_services[count.index].name}-interface"
      "mpc:partner-service" = var.party_services[count.index].name
      "mpc:partner-region"  = var.party_services[count.index].region
      "mpc:component"       = "partner-interface"
      "mpc:cluster"         = local.cluster_name_for_tags
      "mpc:config-mode"     = local.use_eks_cluster ? "eks-cluster-lookup" : "direct-specification"
    },
    var.party_services[count.index].account_id != null ? {
      "mpc:partner-account" = var.party_services[count.index].account_id
    } : {},
    var.additional_tags
  )

  timeouts {
    create = var.endpoint_create_timeout
    delete = var.endpoint_delete_timeout
  }
}

# Create namespace if it doesn't exist (for Kubernetes services)
# Only create if at least one service needs Kubernetes services
resource "kubernetes_namespace" "partner_namespace" {
  count = var.create_namespace && anytrue([for service in var.party_services : service.create_kube_service]) ? 1 : 0

  metadata {
    name = var.namespace
  }
}

# Create Kubernetes services that route to the VPC interface endpoints
# Create based on individual service create_kube_service flags
resource "kubernetes_service" "party_services" {
  count = length([for service in var.party_services : service if service.create_kube_service])

  metadata {
    name      = var.party_services[count.index].name
    namespace = var.create_namespace ? kubernetes_namespace.partner_namespace[0].metadata[0].name : var.namespace

    annotations = merge({
      "mpc.io/partner-region"  = var.party_services[count.index].region
      "mpc.io/vpc-endpoint-id" = aws_vpc_endpoint.party_interface_endpoints[count.index].id
      "mpc.io/connection-type" = "partner-interface"
      "mpc.io/partner-service" = var.party_services[count.index].name
    },
    var.party_services[count.index].account_id != null ? {
      "mpc.io/partner-account" = var.party_services[count.index].account_id
    } : {},
    var.party_services[count.index].kube_service_config.additional_annotations)

    labels = merge({
      "app.kubernetes.io/name"      = var.party_services[count.index].name
      "app.kubernetes.io/instance"  = var.party_services[count.index].name
      "app.kubernetes.io/component" = "mpc-partner-interface"
      "app.kubernetes.io/part-of"   = "mpc-cluster"
      "mpc.io/partner-service"      = "true"
    }, var.party_services[count.index].kube_service_config.labels)
  }

  spec {
    type             = "ExternalName"
    external_name    = aws_vpc_endpoint.party_interface_endpoints[count.index].dns_entry[0].dns_name
    session_affinity = var.party_services[count.index].kube_service_config.session_affinity

    dynamic "port" {
      for_each = var.party_services[count.index].ports
      content {
        name        = port.value.name
        port        = port.value.port
        target_port = port.value.target_port
        protocol    = port.value.protocol
      }
    }
  }
}

# Optional: Create Route53 private hosted zone records for custom DNS names
resource "aws_route53_record" "partner_dns" {
  count = var.create_custom_dns_records ? length(var.party_services) : 0

  zone_id = var.private_zone_id
  name    = "${var.party_services[count.index].name}.${var.dns_domain}"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.party_interface_endpoints[count.index].dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.party_interface_endpoints[count.index].dns_entry[0].hosted_zone_id
    evaluate_target_health = true
  }
} 