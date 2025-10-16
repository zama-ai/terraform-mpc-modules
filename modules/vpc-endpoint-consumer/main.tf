# ***************************************
#  Data sources
# ***************************************


data "aws_eks_cluster" "selected" {
  count = var.cluster_name != null ? 1 : 0
  name  = var.cluster_name
}

data "aws_subnet" "cluster_subnets" {
  for_each = toset(data.aws_eks_cluster.selected[0].vpc_config[0].subnet_ids)
  id       = each.value
}

data "aws_region" "current" {
}

# ***************************************
#  Local variables
# ***************************************
locals {
  vpc_id = var.vpc_id != null ? var.vpc_id : data.aws_eks_cluster.selected[0].vpc_config[0].vpc_id
  subnet_ids = length(coalesce(var.subnet_ids, [])) > 0 ? var.subnet_ids : [
    for subnet_id, subnet in data.aws_subnet.cluster_subnets : subnet_id
    if subnet.map_public_ip_on_launch == false
  ]
  security_group_ids = var.security_group_ids != null ? var.security_group_ids : [data.aws_eks_cluster.selected[0].vpc_config[0].cluster_security_group_id]

  # Cluster name for tagging (use provided cluster_name or default)
  cluster_name_for_tags = var.cluster_name != null ? var.cluster_name : "mpc-cluster"

  # Convert party_services list to map for for_each usage
  party_services_map = {
    for service in var.party_services : service.party_id => service
  }

  party_services_map_with_s3_bucket = {
    for service in var.party_services : service.party_id => service
    if service.public_bucket_url != null
  }

  # Create separate map for services that need Kubernetes services
  kube_services_map = {
    for service in var.party_services : service.party_id => service
    if service.create_kube_service
  }

}

# ************************************************************
#  VPC interface endpoints to connect to partner MPC services
# ************************************************************
resource "aws_vpc_endpoint" "party_interface_endpoints" {
  for_each = local.party_services_map

  vpc_id            = local.vpc_id
  service_name      = each.value.vpc_endpoint_service_name
  vpc_endpoint_type = "Interface"
  subnet_ids = length(coalesce(each.value.availability_zones, [])) > 0 && var.cluster_name != null ? [
    for subnet_id, subnet in data.aws_subnet.cluster_subnets : subnet_id
    if subnet.map_public_ip_on_launch == false && contains(each.value.availability_zones, subnet.availability_zone_id)
  ] : local.subnet_ids
  security_group_ids = local.security_group_ids
  service_region     = each.value.region

  # DNS options
  private_dns_enabled = var.private_dns_enabled

  # Route table IDs if specified
  route_table_ids = var.route_table_ids

  tags = merge(
    var.tags,
    {
      Name                  = "${var.name_prefix}-${each.value.name}-interface"
      "mpc:partner-service" = each.value.name
      "mpc:partner-party"   = each.key
      "mpc:partner-region"  = each.value.region
      "mpc:component"       = "partner-interface"
      "mpc:cluster"         = local.cluster_name_for_tags
    },
    each.value.account_id != null ? {
      "mpc:partner-account" = each.value.account_id
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
  for_each = local.kube_services_map

  metadata {
    name      = "mpc-node-${each.key}"
    namespace = var.create_namespace ? kubernetes_namespace.partner_namespace[0].metadata[0].name : var.namespace

    annotations = merge({
      "mpc.io/connection-type" = "partner-interface"
      "mpc.io/partner-service" = each.value.name
      "mpc.io/partner-party"   = each.key
      },
      each.value.account_id != null ? {
        "mpc.io/partner-account" = each.value.account_id
      } : {},
    each.value.kube_service_config.additional_annotations)

    labels = merge({
      "app.kubernetes.io/name"      = "kms-${each.key}-core"
      "app.kubernetes.io/instance"  = "kms-${each.key}-core"
      "app.kubernetes.io/component" = "mpc-partner-interface"
      "app.kubernetes.io/part-of"   = "mpc-cluster"
      "mpc.io/partner-service"      = "true"
    }, each.value.kube_service_config.labels)
  }

  spec {
    type             = "ExternalName"
    external_name    = aws_vpc_endpoint.party_interface_endpoints[each.key].dns_entry[0].dns_name
    session_affinity = each.value.kube_service_config.session_affinity

    dynamic "port" {
      for_each = concat(
        var.enable_grpc_port ? [var.default_mpc_ports.grpc] : [],
        [
          var.default_mpc_ports.peer,
          var.default_mpc_ports.metrics
        ]
      )
      content {
        name        = port.value.name
        port        = port.value.port
        target_port = port.value.target_port
        protocol    = port.value.protocol
      }
    }
  }
}

data "kubernetes_config_map_v1" "mpc_party_config" {
  count = var.sync_public_bucket.enabled ? 1 : 0
  metadata {
    name      = var.sync_public_bucket.configmap_name
    namespace = var.create_namespace ? kubernetes_namespace.partner_namespace[0].metadata[0].name : var.namespace
  }
}

locals {
  public_vault_s3_bucket_name = var.sync_public_bucket.enabled ? "s3://${data.kubernetes_config_map_v1.mpc_party_config[0].data["KMS_CORE__PUBLIC_VAULT__STORAGE__S3__BUCKET"]}" : ""
}

//resource "null_resource" "sync_s3_bucket" {
//  for_each = local.party_services_map_with_s3_bucket
//  provisioner "local-exec" {
//    interpreter = ["bash", "-c"]
//    command     = <<-EOT
//    set -e
//    TEMP_DIR=$(mktemp -d)
//    trap "rm -rf $TEMP_DIR" EXIT
//    aws s3 sync --region ${data.aws_region.current.region} ${each.value.public_bucket_url} "$TEMP_DIR"
//    aws s3 sync --region ${data.aws_region.current.region} "$TEMP_DIR" ${local.public_vault_s3_bucket_name}
//    EOT
//    when        = create
//    quiet       = true
//  }
//  depends_on = [kubernetes_service.party_services]
//}

# **************************************************************************************
#  Create Route53 private hosted zone records for custom DNS names (in progress,optional)
# **************************************************************************************
resource "aws_route53_record" "partner_dns" {
  for_each = var.create_custom_dns_records ? local.party_services_map : {}

  zone_id = var.private_zone_id
  name    = "${each.value.name}.${var.dns_domain}"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.party_interface_endpoints[each.key].dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.party_interface_endpoints[each.key].dns_entry[0].hosted_zone_id
    evaluate_target_health = true
  }
}
