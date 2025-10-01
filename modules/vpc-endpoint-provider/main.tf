# **************************************************************
#  Data sources
# **************************************************************

data "aws_region" "current" {
  lifecycle {
    postcondition {
      condition     = var.enable_region_validation ? contains(local.allowed_regions, self.region) : true
      error_message = "This module supports only ${join(", ", local.allowed_regions)} (got: ${self.region})."
    }
  }
}

# **************************************************************
#  Create namespace if it doesn't exist (optional)
# **************************************************************
resource "kubernetes_namespace" "mpc_namespace" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

# ********************************************
#  Create LoadBalancer services for MPC nodes
# ********************************************
resource "kubernetes_service" "mpc_nlb" {
  wait_for_load_balancer = true
  metadata {
    name      = "mpc-node-${var.party_id}"
    namespace = var.create_namespace ? kubernetes_namespace.mpc_namespace[0].metadata[0].name : var.namespace

    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                              = "external"
      "service.beta.kubernetes.io/aws-load-balancer-scheme"                            = "internal"
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"                  = "tcp"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                          = "true"
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type"                   = "ip"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = join(",", concat([
        "mpc-node=node-${var.party_id}",
        "environment=${var.network_environment}"
      ], [for k, v in var.tags : "${k}=${v}"]))
    }

    labels = merge({
      "app.kubernetes.io/name"      = "mpc-node-${var.party_id}"
      "app.kubernetes.io/instance"  = "mpc-node-${var.party_id}"
      "app.kubernetes.io/component" = "mpc-node"
      "app.kubernetes.io/part-of"   = "mpc-cluster"
    }, var.kubernetes_nlb_extra_labels)
  }

  spec {
    type                = "LoadBalancer"
    load_balancer_class = "service.k8s.aws/nlb"

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

    selector = {
      "app" = "kms-core"
    }
  }

  timeouts {
    create = var.service_create_timeout
  }
}

# ***************************************
#  Local variables
# ***************************************
locals {
  allowed_regions = var.network_environment == "testnet" ? var.testnet_supported_regions : var.mainnet_supported_regions
  hostname_parts  = split("-", split(".", kubernetes_service.mpc_nlb.status[0].load_balancer[0].ingress[0].hostname)[0])
  nlb_name        = join("-", slice(local.hostname_parts, 0, length(local.hostname_parts) - 1))
}

# Look up the actual Network Load Balancers using AWS data sources
data "aws_lb" "kubernetes_nlb" {
  name       = local.nlb_name
  depends_on = [kubernetes_service.mpc_nlb]
}

# ********************************************************************
#  Wait for NLB to be available before creating VPC endpoint service
# ********************************************************************
data "external" "wait_nlb" {
  program = ["bash", "-c", <<-EOF
    set -e
    aws elbv2 wait load-balancer-available --region ${data.aws_region.current.region} --load-balancer-arns ${data.aws_lb.kubernetes_nlb.arn}
    echo '{"ready": "true"}'
  EOF
  ]
  depends_on = [data.aws_lb.kubernetes_nlb]
}

# Local values for creating VPC endpoint service details
locals {
  nlb_details = {
    arn          = data.aws_lb.kubernetes_nlb.arn
    dns_name     = data.aws_lb.kubernetes_nlb.dns_name
    zone_id      = data.aws_lb.kubernetes_nlb.zone_id
    vpc_id       = data.aws_lb.kubernetes_nlb.vpc_id
    display_name = "mpc-node-${var.party_id}"
  }
}


# Get all availability zones in the region to map names to IDs
data "aws_availability_zones" "all" {
  state = "available"
}

# Use external data source to get availability zone names from NLB
data "external" "nlb_availability_zones" {
  program = ["bash", "-c", <<-EOF
    set -e
    
    # Get availability zone names from the NLB as a comma-separated string
    zone_names=$(aws elbv2 describe-load-balancers \
      --region ${data.aws_region.current.region} \
      --load-balancer-arns ${data.aws_lb.kubernetes_nlb.arn} \
      --query 'LoadBalancers[0].AvailabilityZones[].ZoneName' \
      --output text | tr '\t' ',')
    
    # Return as JSON with string value
    echo "{\"zone_names\": \"$zone_names\"}"
  EOF
  ]
  depends_on = [data.external.wait_nlb]
}

locals {
  # Map zone names to zone IDs
  zone_name_to_id = zipmap(data.aws_availability_zones.all.names, data.aws_availability_zones.all.zone_ids)

  # Get zone names from external data source
  nlb_zone_names = split(",", data.external.nlb_availability_zones.result.zone_names)

  # Convert zone names to zone IDs
  availability_zones = [for zone_name in local.nlb_zone_names : local.zone_name_to_id[zone_name]]
}

# **************************************************************
#  Create VPC endpoint services to expose NLBs via PrivateLink
# **************************************************************
resource "aws_vpc_endpoint_service" "mpc_nlb_service" {

  # Associate with the Network Load Balancer
  network_load_balancer_arns = [local.nlb_details.arn]

  # Whether manual acceptance is required for connections
  acceptance_required = var.acceptance_required

  # Which principals can connect to this service
  allowed_principals = var.allowed_principals
  supported_regions  = var.supported_regions

  tags = merge(
    var.tags,
    {
      Name = "${local.nlb_details.display_name}-endpoint-service"
      NLB  = local.nlb_details.display_name
    }
  )

  # Wait for NLB to be ready before creating VPC endpoint service
  depends_on = [data.external.wait_nlb]
}
