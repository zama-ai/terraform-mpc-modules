output "vpc_endpoint_service_ids" {
  description = "IDs of the created VPC endpoint services"
  value       = [for service in aws_vpc_endpoint_service.mpc_nlb_services : service.id]
}

output "vpc_endpoint_service_names" {
  description = "Service names of the created VPC endpoint services (what consumers use to connect)"
  value       = [for service in aws_vpc_endpoint_service.mpc_nlb_services : service.service_name]
}

output "vpc_endpoint_service_arns" {
  description = "ARNs of the created VPC endpoint services"
  value       = [for service in aws_vpc_endpoint_service.mpc_nlb_services : service.arn]
}

output "nlb_details" {
  description = "Detailed information about the looked up NLBs"
  value       = local.nlb_details
}

output "service_details" {
  description = "Detailed information about the created VPC endpoint services"
  value = [
    for i, service in aws_vpc_endpoint_service.mpc_nlb_services : {
      id           = service.id
      service_name = service.service_name
      arn          = service.arn
      state        = service.state
      service_type = service.service_type
      nlb_name     = var.service_details[i].display_name
      nlb_arn      = var.service_details[i].lb_arn
    }
  ]
}