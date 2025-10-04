# Partner Consumer Example
# This example demonstrates how to connect to existing MPC services from partners

module "vpc_endpoint_consumer" {
  source = "git::https://github.com/zama-ai/terraform-mpc-modules.git//modules/vpc-endpoint-consumer?ref=v0.1.9"
  #source = "../../modules/vpc-endpoint-consumer"
  # Partner services configuration
  party_services = var.party_services

  # Network configuration - now passed from root-level consumer variables
  cluster_name       = var.cluster_name
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  # VPC Interface Endpoint configuration
  private_dns_enabled = var.private_dns_enabled
  route_table_ids     = []

  # Naming and tagging
  name_prefix = var.name_prefix
  tags        = var.common_tags

  # Timeouts
  endpoint_create_timeout = var.endpoint_create_timeout
  endpoint_delete_timeout = var.endpoint_delete_timeout

  # Kubernetes configuration
  namespace        = var.namespace
  create_namespace = false

  # Custom DNS (optional)
  create_custom_dns_records = var.create_custom_dns_records
  private_zone_id           = var.private_zone_id
  dns_domain                = var.dns_domain
}
