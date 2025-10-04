# Partner Provider MPC Cluster Example

data "aws_region" "current" {}

# Deploy VPC endpoints for the created NLBs (optional, only in provider mode)
module "vpc_endpoint_provider" {
  source = "git::https://github.com/zama-ai/terraform-mpc-modules.git//modules/vpc-endpoint-provider?ref=v0.1.9"
  #source = "../../modules/vpc-endpoint-provider"
  # Network environment configuration
  network_environment      = var.network_environment
  enable_region_validation = var.enable_region_validation

  # Party Configuration
  party_id     = var.party_id
  partner_name = var.partner_name

  namespace        = var.namespace
  create_namespace = false

  service_create_timeout = var.service_create_timeout

  # VPC Endpoint Service configuration
  acceptance_required = var.vpc_endpoint_acceptance_required
  allowed_principals  = var.allowed_vpc_endpoint_principals
  # Always ensure current region is included in supported_regions
  supported_regions = length(var.vpc_endpoint_supported_regions) > 0 ? distinct(concat(var.vpc_endpoint_supported_regions, [data.aws_region.current.id])) : [data.aws_region.current.id]
  tags              = var.common_tags
}
