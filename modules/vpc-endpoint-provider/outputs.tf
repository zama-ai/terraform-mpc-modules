output "vpc_endpoint_service_id" {
  description = "IDs of the created VPC endpoint services"
  value       = aws_vpc_endpoint_service.mpc_nlb_service.id
}

output "vpc_endpoint_service_name" {
  description = "Service names of the created VPC endpoint services (what consumers use to connect)"
  value       = aws_vpc_endpoint_service.mpc_nlb_service.service_name
}

output "vpc_endpoint_service_arn" {
  description = "ARNs of the created VPC endpoint services"
  value       = aws_vpc_endpoint_service.mpc_nlb_service.arn
}

output "nlb_details" {
  description = "Detailed information about the looked up NLBs"
  value       = local.nlb_details
}

output "service_details" {
  description = "Detailed information about the created VPC endpoint services"
  value = {
    id           = aws_vpc_endpoint_service.mpc_nlb_service.id
    service_name = aws_vpc_endpoint_service.mpc_nlb_service.service_name
    kubernetes_service_name = kubernetes_service.mpc_nlb.metadata[0].name
    arn          = aws_vpc_endpoint_service.mpc_nlb_service.arn
    state        = aws_vpc_endpoint_service.mpc_nlb_service.state
    service_type = aws_vpc_endpoint_service.mpc_nlb_service.service_type
    nlb_name     = local.nlb_details.display_name
    nlb_arn      = local.nlb_details.arn
  }
}