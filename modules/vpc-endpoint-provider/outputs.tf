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
    id                      = aws_vpc_endpoint_service.mpc_nlb_service.id
    service_name            = aws_vpc_endpoint_service.mpc_nlb_service.service_name
    kubernetes_service_name = kubernetes_service.mpc_nlb.metadata[0].name
    arn                     = aws_vpc_endpoint_service.mpc_nlb_service.arn
    state                   = aws_vpc_endpoint_service.mpc_nlb_service.state
    service_type            = aws_vpc_endpoint_service.mpc_nlb_service.service_type
    nlb_name                = local.nlb_details.display_name
    nlb_arn                 = local.nlb_details.arn
  }
}

output "configuration_for_consumer" {
  description = "Configuration for the consumer to use the VPC endpoint service"
  value = [{
    party_id                  = var.party_id
    name                      = "mpc-node-${var.party_id}"
    partner_name              = var.partner_name
    region                    = data.aws_region.current.region
    vpc_endpoint_service_name = aws_vpc_endpoint_service.mpc_nlb_service.service_name
    s3_bucket_name            = var.sync_bucket.enabled ? local.public_vault_s3_bucket_name : null
    availability_zones        = local.availability_zones
    create_kube_service       = true
    kube_service_config = {
      labels = {
        "partyid"     = var.party_id
        "environment" = var.network_environment
      }
      session_affinity = "None"
    }
  }]
}
