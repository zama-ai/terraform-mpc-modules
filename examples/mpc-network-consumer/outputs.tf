# Partner Consumer Example Outputs

# Cluster Information
output "cluster_name" {
  description = "Name of the deployed MPC cluster"
  value       = module.mpc_cluster_consumer.cluster_name
}

output "deployment_mode" {
  description = "Deployment mode of the MPC cluster"
  value       = module.mpc_cluster_consumer.deployment_mode
}

output "namespace" {
  description = "Kubernetes namespace where partner services are deployed"
  value       = module.mpc_cluster_consumer.namespace
}

# Partner Interface Endpoints Information
output "party_interface_endpoint_ids" {
  description = "IDs of the created VPC interface endpoints for partner connections"
  value       = module.mpc_cluster_consumer.party_interface_endpoint_ids
}

output "party_interface_dns_names" {
  description = "DNS names of the created VPC interface endpoints for partner connections"
  value       = module.mpc_cluster_consumer.party_interface_dns_names
}

output "partner_service_details" {
  description = "Detailed information about partner services and their connections"
  value       = module.mpc_cluster_consumer.partner_service_details
}

# Connection Information for Applications
output "partner_connection_endpoints" {
  description = "Connection endpoints for applications to use when connecting to partner services"
  value       = module.mpc_cluster_consumer.partner_connection_endpoints
}

# Deployment Summary
output "deployment_summary" {
  description = "Summary of the partner consumer deployment"
  value       = module.mpc_cluster_consumer.deployment_summary
}

# Application Connection Guide
output "application_connection_guide" {
  description = "Connection guide for MPC applications running in this cluster"
  value = {
    for service_name, endpoint_info in module.mpc_cluster_consumer.partner_connection_endpoints :
    service_name => {
      # Recommended connection method for Kubernetes applications
      kubernetes_service_dns = endpoint_info.kubernetes_service_name

      # Alternative connection methods
      vpc_interface_dns = endpoint_info.vpc_interface_dns
      custom_dns        = endpoint_info.custom_dns_name

      # Connection details
      ports = [
        for port in endpoint_info.ports : "${port.name}:${port.port}"
      ]

      # Partner information
      partner_info = {
        region  = endpoint_info.partner_region
        account = endpoint_info.partner_account
      }

      # Example connection strings
      examples = {
        # For applications running in the same Kubernetes cluster
        internal_k8s = endpoint_info.kubernetes_service_name != null ? "http://${endpoint_info.kubernetes_service_name}:${endpoint_info.ports[0].port}" : null

        # For applications connecting via VPC interface endpoint directly
        vpc_interface = "http://${endpoint_info.vpc_interface_dns}:${endpoint_info.ports[0].port}"

        # For applications using custom DNS (if configured)
        custom_dns = endpoint_info.custom_dns_name != null ? "http://${endpoint_info.custom_dns_name}:${endpoint_info.ports[0].port}" : null
      }
    }
  }
}

# Cross-Region Partner Summary
output "cross_region_partner_summary" {
  description = "Summary of partners across different regions"
  value = {
    total_partners = length(module.mpc_cluster_consumer.partner_service_details)
    regions = distinct([
      for service in module.mpc_cluster_consumer.partner_service_details : service.partner_region
    ])
    accounts = distinct(compact([
      for service in module.mpc_cluster_consumer.partner_service_details : service.partner_account_id
    ]))

    # Group services by region
    services_by_region = {
      for region in distinct([for service in module.mpc_cluster_consumer.partner_service_details : service.partner_region]) :
      region => [
        for service in module.mpc_cluster_consumer.partner_service_details :
        service.service_name if service.partner_region == region
      ]
    }

    # Group services by account (only for services with account_id)
    services_by_account = {
      for account in distinct(compact([for service in module.mpc_cluster_consumer.partner_service_details : service.partner_account_id])) :
      account => [
        for service in module.mpc_cluster_consumer.partner_service_details :
        service.service_name if service.partner_account_id == account
      ]
    }
  }
} 