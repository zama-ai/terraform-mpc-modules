# ***************************************
#  Data sources
# ***************************************
data "aws_caller_identity" "current" {}

data "aws_region" "current" {
  lifecycle {
    postcondition {
      condition     = var.enable_region_validation ? contains(local.allowed_regions, self.region) : true
      error_message = "This module supports only ${join(", ", local.allowed_regions)} (got: ${self.region})."
    }
  }
}

data "aws_eks_cluster" "selected" {
  count = var.cluster_name != null ? 1 : 0
  name  = var.cluster_name
}

data "aws_subnet" "cluster_subnets" {
  for_each = toset(data.aws_eks_cluster.selected[0].vpc_config[0].subnet_ids)
  id       = each.value
}

# ***************************************
#  Local variables
# ***************************************
locals {
  allowed_regions = var.network_environment == "testnet" ? var.testnet_supported_regions : var.mainnet_supported_regions
  vpc_id          = var.vpc_id != null ? var.vpc_id : data.aws_eks_cluster.selected[0].vpc_config[0].vpc_id
  subnet_ids = length(coalesce(var.subnet_ids, [])) > 0 ? var.subnet_ids : [
    for subnet_id, subnet in data.aws_subnet.cluster_subnets : subnet_id
    if subnet.map_public_ip_on_launch == false
  ]
  security_group_ids = var.security_group_ids != null ? var.security_group_ids : [data.aws_eks_cluster.selected[0].vpc_config[0].cluster_security_group_id]

  # Cluster name for tagging (use provided cluster_name or default)
  cluster_name_for_tags = var.cluster_name != null ? var.cluster_name : "mpc-cluster"

  # Use the VPC endpoint service names provided by partners
  # Note: vpc_endpoint_service_name must be provided directly by the partner
  # as AWS auto-generates these names when creating VPC endpoint services
  vpc_endpoint_service_names = [
    for service in var.party_services : service.vpc_endpoint_service_name
  ]


  # Create a map for easy reference with default ports fallback
  partner_service_map = {
    for i, service in var.party_services : "${service.name}-${i}" => {
      party_id                  = service.party_id
      name                      = service.name
      region                    = service.region
      account_id                = service.account_id
      vpc_endpoint_service_name = local.vpc_endpoint_service_names[i]
      ports = length(coalesce(service.ports, [])) > 0 ? service.ports : [
        var.default_mpc_ports.grpc,
        var.default_mpc_ports.peer,
        var.default_mpc_ports.metrics
      ]
      create_kube_service = service.create_kube_service
      kube_service_config = service.kube_service_config
    }
  }
}

# ************************************************************
#  VPC interface endpoints to connect to partner MPC services
# ************************************************************
resource "aws_vpc_endpoint" "party_interface_endpoints" {
  count = length(var.party_services)

  vpc_id             = local.vpc_id
  service_name       = local.vpc_endpoint_service_names[count.index]
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.subnet_ids
  security_group_ids = local.security_group_ids
  service_region     = var.party_services[count.index].region

  # DNS options
  private_dns_enabled = var.private_dns_enabled

  # Route table IDs if specified
  route_table_ids = var.route_table_ids

  tags = merge(
    var.tags,
    {
      Name                  = "${var.name_prefix}-${var.party_services[count.index].name}-interface"
      "mpc:partner-service" = var.party_services[count.index].name
      "mpc:partner-region"  = var.party_services[count.index].region
      "mpc:component"       = "partner-interface"
      "mpc:cluster"         = local.cluster_name_for_tags
    },
    var.party_services[count.index].account_id != null ? {
      "mpc:partner-account" = var.party_services[count.index].account_id
    } : {},
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

# *********************************************************************
#  Create Kubernetes services that route to the VPC interface endpoints
# *********************************************************************
resource "kubernetes_service" "party_services" {
  count = length([for service in var.party_services : service if service.create_kube_service])

  metadata {
    name      = "mpc-node-${var.party_services[count.index].party_id}"
    namespace = var.create_namespace ? kubernetes_namespace.partner_namespace[0].metadata[0].name : var.namespace

    annotations = merge({
      "mpc.io/connection-type" = "partner-interface"
      "mpc.io/partner-service" = var.party_services[count.index].name
      },
      var.party_services[count.index].account_id != null ? {
        "mpc.io/partner-account" = var.party_services[count.index].account_id
      } : {},
    var.party_services[count.index].kube_service_config.additional_annotations)

    labels = merge({
      "app.kubernetes.io/name"      = "kms-${var.party_services[count.index].party_id}-core"
      "app.kubernetes.io/instance"  = "kms-${var.party_services[count.index].party_id}-core"
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
      for_each = [
        var.default_mpc_ports.grpc,
        var.default_mpc_ports.peer,
        var.default_mpc_ports.metrics
      ]
      content {
        name        = port.value.name
        port        = port.value.port
        target_port = port.value.target_port
        protocol    = port.value.protocol
      }
    }
  }
}

# **************************************************************************************
#  Create Route53 private hosted zone records for custom DNS names (in progress,optional)
# **************************************************************************************
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