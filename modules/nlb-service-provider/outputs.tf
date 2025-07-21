output "nlb_service_names" {
  description = "Names of the created Kubernetes LoadBalancer services"
  value       = [for service in kubernetes_service.mpc_nlb : service.metadata[0].name]
}

output "nlb_service_namespaces" {
  description = "Namespaces of the created Kubernetes LoadBalancer services"
  value       = [for service in kubernetes_service.mpc_nlb : service.metadata[0].namespace]
}

output "nlb_hostnames" {
  description = "Hostnames of the provisioned Network Load Balancers"
  value       = [for i, service in kubernetes_service.mpc_nlb : service.status[0].load_balancer[0].ingress[0].hostname]
}

output "nlb_arns" {
  description = "ARNs of the provisioned Network Load Balancers (looked up from AWS)"
  value       = [for lb in data.aws_lb.kubernetes_nlbs : lb.arn]
}

output "service_details" {
  description = "Detailed information about the created services"
  value = [
    for i, service in kubernetes_service.mpc_nlb : {
      name        = service.metadata[0].name
      namespace   = service.metadata[0].namespace
      hostname    = service.status[0].load_balancer[0].ingress[0].hostname
      lb_arn      = data.aws_lb.kubernetes_nlbs[i].arn
      lb_dns_name = data.aws_lb.kubernetes_nlbs[i].dns_name
      lb_zone_id  = data.aws_lb.kubernetes_nlbs[i].zone_id
      ports = [for port in service.spec[0].port : {
        name        = port.name
        port        = port.port
        target_port = port.target_port
        protocol    = port.protocol
        node_port   = port.node_port
      }]
      annotations = service.metadata[0].annotations
      labels      = service.metadata[0].labels
    }
  ]
}

output "namespace_name" {
  description = "Name of the namespace where services are deployed"
  value       = var.create_namespace ? kubernetes_namespace.mpc_namespace[0].metadata[0].name : var.namespace
}

# Additional Load Balancer information
output "nlb_dns_names" {
  description = "DNS names of the Network Load Balancers (from AWS)"
  value       = [for lb in data.aws_lb.kubernetes_nlbs : lb.dns_name]
}

output "nlb_zone_ids" {
  description = "Hosted zone IDs of the Network Load Balancers (useful for Route53 alias records)"
  value       = [for lb in data.aws_lb.kubernetes_nlbs : lb.zone_id]
}

output "nlb_names" {
  description = "Names of the Network Load Balancers"
  value       = [for lb in data.aws_lb.kubernetes_nlbs : lb.name]
}

# Data sources for region and account information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {} 