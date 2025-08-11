# Provider requirements are defined in versions.tf

# Data source to get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Data source to look up NLBs by arn
data "aws_lb" "nlb_lookup" {
  count = length(var.service_details)
  arn  = var.service_details[count.index].lb_arn
}

# Wait for NLB to be available before creating VPC endpoint service
data "external" "wait_nlb" {
  count = length(data.aws_lb.nlb_lookup)
  program = ["bash", "-c", <<-EOF
    set -e
    aws elbv2 wait load-balancer-available --region ${data.aws_region.current.region} --load-balancer-arns ${data.aws_lb.nlb_lookup[count.index].arn}
    echo '{"ready": "true"}'
  EOF
  ]
  depends_on = [data.aws_lb.nlb_lookup]
}

# Local values for creating VPC endpoint service details
locals {
  # Create a map of NLB arns to their details for easy reference
  nlb_details = {
    for i, svc in var.service_details : svc.lb_arn => {
      arn      = data.aws_lb.nlb_lookup[i].arn
      dns_name = data.aws_lb.nlb_lookup[i].dns_name
      zone_id  = data.aws_lb.nlb_lookup[i].zone_id
      vpc_id   = data.aws_lb.nlb_lookup[i].vpc_id
    }
  }
}

# Create VPC endpoint services to expose NLBs via PrivateLink
resource "aws_vpc_endpoint_service" "mpc_nlb_services" {
  count = length(var.service_details)

  # Associate with the Network Load Balancer
  network_load_balancer_arns = [data.aws_lb.nlb_lookup[count.index].arn]
  
  # Whether manual acceptance is required for connections
  acceptance_required = var.acceptance_required
  
  # Which principals can connect to this service
  allowed_principals = var.allowed_principals
  supported_regions = var.supported_regions

  tags = merge(
    var.tags,
    {
      Name = "${var.service_details[count.index].display_name}-endpoint-service"
      NLB  = var.service_details[count.index].display_name
    }
  )

  # Wait for NLB to be ready before creating VPC endpoint service
  depends_on = [data.external.wait_nlb]
} 