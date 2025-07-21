# MPC Cluster Outputs

# High-level cluster information
output "cluster_name" {
  description = "Name of the deployed MPC cluster"
  value       = var.cluster_name
}

output "deployment_mode" {
  description = "Deployment mode of the MPC cluster (provider or consumer)"
  value       = var.deployment_mode
}

output "namespace" {
  description = "Kubernetes namespace where MPC services are deployed"
  value = var.deployment_mode == "provider" && length(module.nlb_service_provider) > 0 ? module.nlb_service_provider[0].namespace_name : (
    var.deployment_mode == "consumer" && length(module.vpc_endpoint_consumer) > 0 ? module.vpc_endpoint_consumer[0].namespace_name : var.namespace
  )
}

# Combined cluster endpoints information
output "cluster_endpoints" {
  description = "Comprehensive information about all MPC cluster endpoints including NLBs and VPC endpoints"
  value       = local.cluster_endpoints
}

# NLB-specific outputs (from nlb-service-provider module, only in provider mode)
output "nlb_service_names" {
  description = "Names of the created Kubernetes LoadBalancer services (empty if in consumer mode)"
  value       = var.deployment_mode == "provider" && length(module.nlb_service_provider) > 0 ? module.nlb_service_provider[0].nlb_service_names : []
}

output "nlb_hostnames" {
  description = "Hostnames of the provisioned Network Load Balancers (empty if in consumer mode)"
  value       = var.deployment_mode == "provider" && length(module.nlb_service_provider) > 0 ? module.nlb_service_provider[0].nlb_hostnames : []
}

output "nlb_arns" {
  description = "ARNs of the provisioned Network Load Balancers (empty if in consumer mode)"
  value       = var.deployment_mode == "provider" && length(module.nlb_service_provider) > 0 ? module.nlb_service_provider[0].nlb_arns : []
}

output "nlb_service_details" {
  description = "Detailed information about the created NLB services (empty if in consumer mode)"
  value       = var.deployment_mode == "provider" && length(module.nlb_service_provider) > 0 ? module.nlb_service_provider[0].service_details : []
}

# VPC Endpoints outputs (conditional - only when VPC endpoints are created in provider mode)
output "vpc_endpoint_service_ids" {
  description = "IDs of the created VPC endpoint services (empty if VPC endpoints not created or in consumer mode)"
  value       = var.deployment_mode == "provider" && var.create_vpc_endpoints && length(module.vpc_endpoint_bridge) > 0 ? module.vpc_endpoint_bridge[0].vpc_endpoint_service_ids : []
}

output "vpc_endpoint_service_arns" {
  description = "ARNs of the created VPC endpoint services (empty if VPC endpoints not created or in consumer mode)"
  value       = var.deployment_mode == "provider" && var.create_vpc_endpoints && length(module.vpc_endpoint_bridge) > 0 ? module.vpc_endpoint_bridge[0].vpc_endpoint_service_arns : []
}

output "vpc_endpoint_service_names" {
  description = "Service names that consumers use to connect to your services (empty if VPC endpoints not created or in consumer mode)"
  value       = var.deployment_mode == "provider" && var.create_vpc_endpoints && length(module.vpc_endpoint_bridge) > 0 ? module.vpc_endpoint_bridge[0].vpc_endpoint_service_names : []
}

output "vpc_endpoint_service_details" {
  description = "Detailed information about the created VPC endpoint services (empty if VPC endpoints not created or in consumer mode)"
  value       = var.deployment_mode == "provider" && var.create_vpc_endpoints && length(module.vpc_endpoint_bridge) > 0 ? module.vpc_endpoint_bridge[0].service_details : []
}

# Partner Interface outputs (only in consumer mode)
output "partner_interface_endpoint_ids" {
  description = "IDs of the created VPC interface endpoints for partner connections (empty if in provider mode)"
  value       = var.deployment_mode == "consumer" && length(module.vpc_endpoint_consumer) > 0 ? module.vpc_endpoint_consumer[0].vpc_interface_endpoint_ids : []
}

output "partner_interface_dns_names" {
  description = "DNS names of the created VPC interface endpoints for partner connections (empty if in provider mode)"
  value       = var.deployment_mode == "consumer" && length(module.vpc_endpoint_consumer) > 0 ? module.vpc_endpoint_consumer[0].vpc_interface_endpoint_dns_names : []
}

output "partner_service_details" {
  description = "Detailed information about partner services and their connections (empty if in provider mode)"
  value       = var.deployment_mode == "consumer" && length(module.vpc_endpoint_consumer) > 0 ? module.vpc_endpoint_consumer[0].partner_service_details : []
}

output "partner_connection_endpoints" {
  description = "Connection endpoints for applications to use when connecting to partner services (empty if in provider mode)"
  value       = var.deployment_mode == "consumer" && length(module.vpc_endpoint_consumer) > 0 ? module.vpc_endpoint_consumer[0].partner_connection_endpoints : {}
}

# Deployment configuration summary
output "deployment_summary" {
  description = "Summary of the MPC cluster deployment configuration"
  value = {
    cluster_name    = var.cluster_name
    deployment_mode = var.deployment_mode
    namespace = var.deployment_mode == "provider" && length(module.nlb_service_provider) > 0 ? module.nlb_service_provider[0].namespace_name : (
      var.deployment_mode == "consumer" && length(module.vpc_endpoint_consumer) > 0 ? module.vpc_endpoint_consumer[0].namespace_name : var.namespace
    )
    total_services = var.deployment_mode == "provider" ? length(var.mpc_services) : length(var.partner_services_config.partner_services)
    service_names = var.deployment_mode == "provider" && length(module.nlb_service_provider) > 0 ? module.nlb_service_provider[0].nlb_service_names : (
      var.deployment_mode == "consumer" && length(module.vpc_endpoint_consumer) > 0 ? module.vpc_endpoint_consumer[0].kubernetes_service_names : []
    )
    vpc_endpoints_created      = var.deployment_mode == "provider" ? var.create_vpc_endpoints : false
    vpc_endpoints_count        = var.deployment_mode == "provider" && var.create_vpc_endpoints && length(module.vpc_endpoint_bridge) > 0 ? length(module.vpc_endpoint_bridge[0].vpc_endpoint_service_ids) : 0
    partner_interfaces_created = var.deployment_mode == "consumer" ? length(var.partner_services_config.partner_services) : 0
    partner_interfaces_count   = var.deployment_mode == "consumer" && length(module.vpc_endpoint_consumer) > 0 ? length(module.vpc_endpoint_consumer[0].vpc_interface_endpoint_ids) : 0
    common_tags                = var.common_tags
  }
}

# For users who want to create VPC endpoints in separate Terraform runs (provider mode only)
output "nlb_names_for_vpc_endpoints" {
  description = "NLB service names that can be used as input for the vpc-endpoint-bridge module in separate Terraform runs (empty if in consumer mode)"
  value       = var.deployment_mode == "provider" && length(module.nlb_service_provider) > 0 ? module.nlb_service_provider[0].nlb_service_names : []
}

output "cluster_summary" {
  description = "Summary of the MPC cluster deployment"
  value = {
    deployment_mode    = var.deployment_mode
    cluster_name       = var.cluster_name
    namespace         = var.namespace
    total_endpoints   = length(local.cluster_endpoints)
    provider_services = var.deployment_mode == "provider" ? length(var.mpc_services) : 0
    consumer_services = var.deployment_mode == "consumer" ? length(var.partner_services_config.partner_services) : 0
    vpc_endpoints_enabled = var.deployment_mode == "provider" ? var.create_vpc_endpoints : true
  }
}
