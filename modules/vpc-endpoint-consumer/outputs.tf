output "vpc_interface_endpoint_ids" {
  description = "IDs of the created VPC interface endpoints"
  value       = [for endpoint in aws_vpc_endpoint.party_interface_endpoints : endpoint.id]
}

output "vpc_interface_endpoint_dns_names" {
  description = "DNS names of the created VPC interface endpoints"
  value       = [for endpoint in aws_vpc_endpoint.party_interface_endpoints : endpoint.dns_entry[0].dns_name]
}

output "vpc_interface_endpoint_hosted_zone_ids" {
  description = "Hosted zone IDs of the created VPC interface endpoints"
  value       = [for endpoint in aws_vpc_endpoint.party_interface_endpoints : endpoint.dns_entry[0].hosted_zone_id]
}

output "vpc_interface_endpoint_service_names" {
  description = "Service names of the created VPC interface endpoints"
  value       = [for endpoint in aws_vpc_endpoint.party_interface_endpoints : endpoint.service_name]
}

output "partner_service_details" {
  description = "Detailed information about the partner services and their connections"
  value = [
    for i, endpoint in aws_vpc_endpoint.party_interface_endpoints : {
      service_name                 = var.party_services[i].name
      partner_region               = var.party_services[i].region
      partner_account_id           = var.party_services[i].account_id # Can be null
      vpc_endpoint_service_name    = endpoint.service_name
      vpc_interface_endpoint_id    = endpoint.id
      vpc_interface_dns_name       = endpoint.dns_entry[0].dns_name
      vpc_interface_hosted_zone_id = endpoint.dns_entry[0].hosted_zone_id
      network_interface_ids        = endpoint.network_interface_ids
      state                        = endpoint.state
      created_kube_service         = var.party_services[i].create_kube_service
      ports                        = var.party_services[i].ports
    }
  ]
}

output "kubernetes_service_names" {
  description = "Names of the created Kubernetes services for partner connections"
  value = [
    for i, service in kubernetes_service.party_services : service.metadata[0].name
  ]
}

output "kubernetes_service_namespaces" {
  description = "Namespaces of the created Kubernetes services for partner connections"
  value = [
    for service in kubernetes_service.party_services : service.metadata[0].namespace
  ]
}

output "kubernetes_service_external_names" {
  description = "External names (VPC interface endpoint DNS) used by the Kubernetes services"
  value = [
    for service in kubernetes_service.party_services : service.spec[0].external_name
  ]
}

output "namespace_name" {
  description = "Name of the namespace where partner services are deployed"
  value       = var.create_namespace && anytrue([for service in var.party_services : service.create_kube_service]) ? kubernetes_namespace.partner_namespace[0].metadata[0].name : var.namespace
}

output "custom_dns_records" {
  description = "Custom DNS records created for the VPC interface endpoints (if enabled)"
  value = var.create_custom_dns_records ? [
    for i, record in aws_route53_record.partner_dns : {
      name    = record.name
      type    = record.type
      zone_id = record.zone_id
      fqdn    = record.fqdn
    }
  ] : []
}

output "connection_summary" {
  description = "Summary of partner connections for easy reference"
  value = {
    total_partners          = length(var.party_services)
    partner_regions         = distinct([for service in var.party_services : service.region])
    partner_accounts        = distinct(compact([for service in var.party_services : service.account_id]))
    vpc_interface_endpoints = length(aws_vpc_endpoint.party_interface_endpoints)
    kubernetes_services     = length(kubernetes_service.party_services)
    custom_dns_records      = var.create_custom_dns_records ? length(aws_route53_record.partner_dns) : 0
    namespace               = var.create_namespace && anytrue([for service in var.party_services : service.create_kube_service]) ? kubernetes_namespace.partner_namespace[0].metadata[0].name : var.namespace
  }
}

# For applications that need to connect to partner services
output "partner_connection_endpoints" {
  description = "Connection endpoints for applications to use when connecting to partner services"
  value = {
    for i, service in var.party_services : service.name => {
      # Primary connection methods
      vpc_interface_dns       = aws_vpc_endpoint.party_interface_endpoints[i].dns_entry[0].dns_name
      kubernetes_service_name = service.create_kube_service ? "${service.name}.${var.create_namespace && anytrue([for s in var.party_services : s.create_kube_service]) ? kubernetes_namespace.partner_namespace[0].metadata[0].name : var.namespace}.svc.cluster.local" : null
      custom_dns_name         = var.create_custom_dns_records ? "${service.name}.${var.dns_domain}" : null

      # Service details
      ports           = service.ports
      partner_region  = service.region
      partner_account = service.account_id   # Can be null if not provided
      partner_name    = service.partner_name # Can be null if not provided
      connection_type = "vpc-interface"

      # Advanced connection options
      network_interface_ips = aws_vpc_endpoint.party_interface_endpoints[i].network_interface_ids
    }
  }
}
