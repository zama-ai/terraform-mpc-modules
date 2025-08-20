# Example MPC Cluster Outputs

output "vpc_endpoint_provider" {
  description = "Outputs from the vpc-endpoint-provider module"
  value       = module.vpc_endpoint_provider
}

# # Cluster Information
# output "cluster_name" {
#   description = "Name of the deployed MPC cluster"
#   value       = module.mpc_cluster.cluster_name
# }
#
# output "namespace" {
#   description = "Kubernetes namespace where MPC services are deployed"
#   value       = module.mpc_cluster.namespace
# }
#
# # Network Load Balancer Information
# output "nlb_hostnames" {
#   description = "Hostnames of the provisioned Network Load Balancers"
#   value       = module.mpc_cluster.nlb_hostnames
# }
#
# output "nlb_service_names" {
#   description = "Names of the Kubernetes LoadBalancer services"
#   value       = module.mpc_cluster.nlb_service_names
# }
#
# output "nlb_arns" {
#   description = "ARNs of the provisioned Network Load Balancers"
#   value       = module.mpc_cluster.nlb_arns
# }
#
# # VPC Endpoint Services Information (when created)
# output "vpc_endpoint_service_names" {
#   description = "Service names that consumers use to connect to your services"
#   value       = module.mpc_cluster.vpc_endpoint_service_names
# }
#
# output "vpc_endpoint_service_ids" {
#   description = "IDs of the created VPC endpoint services"
#   value       = module.mpc_cluster.vpc_endpoint_service_ids
# }
#
#
# # Comprehensive Cluster Endpoints
# output "cluster_endpoints" {
#   description = "Complete information about all MPC cluster endpoints"
#   value       = module.mpc_cluster.cluster_endpoints
# }
#
# # Deployment Summary
# output "deployment_summary" {
#   description = "Summary of the MPC cluster deployment"
#   value       = module.mpc_cluster.deployment_summary
# }
#
# # Connection Information for MPC Applications
# output "mpc_node_connections" {
#   description = "Connection information for MPC applications"
#   value = {
#     for endpoint in module.mpc_cluster.cluster_endpoints :
#     endpoint.service_name => {
#       # Primary connection (use NLB hostname directly)
#       primary_endpoint = endpoint.nlb_hostname
#       nlb_endpoint     = endpoint.nlb_hostname
#       vpc_endpoint_service_name = endpoint.vpc_endpoint_service_name
#
#       # Service-specific ports (extracted from service name)
#       ports = endpoint.service_name == "mpc-coordinator" ? {
#         api    = 9090
#         health = 9091
#         } : {
#         protocol = 8080
#         health   = 8081
#       }
#     }
#   }
# }
#
# # For reference when creating additional VPC endpoints
# output "nlb_names_for_cross_account_vpc_endpoints" {
#   description = "NLB names that can be used to create VPC endpoints in other AWS accounts"
#   value       = module.mpc_cluster.nlb_names_for_vpc_endpoints
# }