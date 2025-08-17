# Partner Provider MPC Cluster Example

data "aws_region" "current" {}

# Deploy VPC endpoints for the created NLBs (optional, only in provider mode)
module "vpc_endpoint_provider" {
  source = "../..//modules/vpc-endpoint-provider"

  namespace        = var.namespace
  create_namespace = false
  mpc_services     = var.mpc_services
  aws_region       = data.aws_region.current.region

  service_create_timeout = var.service_create_timeout


  # Use the NLB service names from the nlb-service-provider module
  #service_details = [
  #  for i, svc in module.nlb_service_provider.service_details : {
  #    display_name = svc.name
  #    lb_arn       = svc.lb_arn
  #  }
  #]

  # VPC Endpoint Service configuration
  acceptance_required = var.vpc_endpoint_acceptance_required
  allowed_principals  = var.allowed_vpc_endpoint_principals
  # Always ensure current region is included in supported_regions
  supported_regions = length(var.vpc_endpoint_supported_regions) > 0 ? distinct(concat(var.vpc_endpoint_supported_regions, [data.aws_region.current.id])) : [data.aws_region.current.id]
  tags               = var.common_tags
}
