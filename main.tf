# MPC Cluster Terraform Module
# This root module orchestrates the deployment of an MPC cluster including:
# 1. Kubernetes LoadBalancer services with NLB backend (mpc-nlb module)
# 2. VPC endpoints for cross-VPC connectivity (vpc-endpoints module)
# 3. Partner interface connections via VPC interface endpoints (mpc-partner-interface module)
# Note: MPC party storage infrastructure is now handled by dedicated examples

# Provider requirements are defined in versions.tf

# Configuration validation notes:
# - Provider mode: requires at least one mpc_service to be defined
# - Consumer mode: requires at least one partner service in partner_services_config

# Data source to get current AWS region
data "aws_region" "current" {}

# Deploy MPC services with Network Load Balancers (only if deployment_mode is "provider")
module "nlb_service_provider" {
  count  = var.deployment_mode == "provider" ? 1 : 0
  source = "./modules/nlb-service-provider"

  namespace        = var.namespace
  create_namespace = var.create_namespace
  mpc_services     = var.mpc_services
  common_tags      = var.common_tags

  service_create_timeout = var.service_create_timeout
}

# Deploy VPC endpoints for the created NLBs (optional, only in provider mode)
module "vpc_endpoint_bridge" {
  count  = var.deployment_mode == "provider" && var.create_vpc_endpoints ? 1 : 0
  source = "./modules/vpc-endpoint-bridge"

  # Use the NLB service names from the nlb-service-provider module
  service_details = [
    for i, svc in module.nlb_service_provider[0].service_details : {
      display_name = svc.name
      lb_arn       = svc.lb_arn
    }
  ]

  # VPC Endpoint Service configuration
  acceptance_required = var.vpc_endpoints_config.acceptance_required
  allowed_principals  = var.vpc_endpoints_config.allowed_principals
  # Always ensure current region is included in supported_regions
  supported_regions = length(var.vpc_endpoints_config.supported_regions) > 0 ? distinct(concat(var.vpc_endpoints_config.supported_regions, [data.aws_region.current.id])) : [data.aws_region.current.id]
  tags               = var.common_tags

  depends_on = [module.nlb_service_provider]
}

# Deploy partner interface connections (only in consumer mode)
# The vpc-endpoint-consumer module supports two configuration modes:
# - EKS Cluster Lookup: Automatically retrieves network config from consumer_cluster_name
# - Direct Specification: Uses manually provided consumer_vpc_id, consumer_subnet_ids, consumer_security_group_ids
module "vpc_endpoint_consumer" {
  count  = var.deployment_mode == "consumer" ? 1 : 0
  source = "./modules/vpc-endpoint-consumer"

  # Partner services configuration
  partner_services = var.partner_services_config.partner_services

  # Network configuration - now passed from root-level consumer variables
  cluster_name       = var.consumer_cluster_name
  vpc_id             = var.consumer_vpc_id
  subnet_ids         = var.consumer_subnet_ids
  security_group_ids = var.consumer_security_group_ids

  # VPC Interface Endpoint configuration
  endpoint_policy     = var.partner_services_config.endpoint_policy
  private_dns_enabled = var.partner_services_config.private_dns_enabled
  route_table_ids     = var.partner_services_config.route_table_ids

  # Naming and tagging
  name_prefix     = var.partner_services_config.name_prefix
  common_tags     = var.common_tags
  additional_tags = var.partner_services_config.additional_tags

  # Timeouts
  endpoint_create_timeout = var.partner_services_config.endpoint_create_timeout
  endpoint_delete_timeout = var.partner_services_config.endpoint_delete_timeout

  # Kubernetes configuration
  namespace        = var.partner_services_config.namespace
  create_namespace = var.partner_services_config.create_namespace

  # Custom DNS (optional)
  create_custom_dns_records = var.partner_services_config.create_custom_dns_records
  private_zone_id           = var.partner_services_config.private_zone_id
  dns_domain                = var.partner_services_config.dns_domain
}

# Local values for organizing outputs
locals {
  # Provider mode: Combine NLB and VPC endpoint information
  provider_cluster_endpoints = var.deployment_mode == "provider" && length(module.nlb_service_provider) > 0 ? (
    var.create_vpc_endpoints && length(module.vpc_endpoint_bridge) > 0 ? [
      for i, service_name in module.nlb_service_provider[0].nlb_service_names : {
        service_name              = service_name
        nlb_hostname              = module.nlb_service_provider[0].nlb_hostnames[i]
        nlb_arn                   = module.nlb_service_provider[0].nlb_arns[i]
        vpc_endpoint_service_id   = module.vpc_endpoint_bridge[0].vpc_endpoint_service_ids[i]
        vpc_endpoint_service_name = module.vpc_endpoint_bridge[0].vpc_endpoint_service_names[i]
        connection_type           = "provider"
      }
      ] : [
      for i, service_name in module.nlb_service_provider[0].nlb_service_names : {
        service_name              = service_name
        nlb_hostname              = module.nlb_service_provider[0].nlb_hostnames[i]
        nlb_arn                   = module.nlb_service_provider[0].nlb_arns[i]
        vpc_endpoint_service_id   = null
        vpc_endpoint_service_name = null
        connection_type           = "provider"
      }
    ]
  ) : []

  # Consumer mode: Partner interface endpoints information
  consumer_cluster_endpoints = var.deployment_mode == "consumer" && length(module.vpc_endpoint_consumer) > 0 ? [
    for service_name, endpoint_info in module.vpc_endpoint_consumer[0].partner_connection_endpoints : {
      service_name            = service_name
      vpc_interface_dns_name  = endpoint_info.vpc_interface_dns
      kubernetes_service_name = endpoint_info.kubernetes_service_name
      custom_dns_name         = endpoint_info.custom_dns_name
      partner_region          = endpoint_info.partner_region
      partner_account         = endpoint_info.partner_account
      ports                   = endpoint_info.ports
      connection_type         = "consumer"
    }
  ] : []

  # Combined cluster endpoints based on deployment mode
  cluster_endpoints = var.deployment_mode == "provider" ? local.provider_cluster_endpoints : local.consumer_cluster_endpoints
}
