# Security Group Outputs
output "node_security_group_id" {
  description = "ID of the dedicated security group for node group"
  value       = var.create_node_security_group ? aws_security_group.node_group_sg[0].id : null
}

output "node_security_group_arn" {
  description = "ARN of the dedicated security group for node group"
  value       = var.create_node_security_group ? aws_security_group.node_group_sg[0].arn : null
}

output "node_security_group_name" {
  description = "Name of the dedicated security group for node group"
  value       = var.create_node_security_group ? aws_security_group.node_group_sg[0].name : null
}

output "node_security_group_vpc_id" {
  description = "VPC ID of the dedicated security group for node group"
  value       = var.create_node_security_group ? aws_security_group.node_group_sg[0].vpc_id : null
}

# Security Group Rules Outputs
output "p2p_security_group_rules" {
  description = "Map of P2P security group rules (CIDR-based)"
  value = {
    cidr_rules = var.create_node_security_group && length(var.allowed_peer_cidrs) > 0 ? {
      for key, rule in aws_security_group_rule.p2p_cidr_rules : key => {
        type        = rule.type
        from_port   = rule.from_port
        to_port     = rule.to_port
        protocol    = rule.protocol
        cidr_blocks = rule.cidr_blocks
        description = rule.description
      }
    } : {}
    
    sg_rules = var.create_node_security_group && length(var.allowed_peer_security_groups) > 0 ? {
      for key, rule in aws_security_group_rule.p2p_sg_rules : key => {
        type                     = rule.type
        from_port                = rule.from_port
        to_port                  = rule.to_port
        protocol                 = rule.protocol
        source_security_group_id = rule.source_security_group_id
        description              = rule.description
      }
    } : {}
  }
}

output "additional_security_group_rules" {
  description = "Map of additional custom security group rules"
  value = var.create_node_security_group ? {
    for key, rule in aws_security_group_rule.additional_rules : key => {
      type                     = rule.type
      from_port                = rule.from_port
      to_port                  = rule.to_port
      protocol                 = rule.protocol
      cidr_blocks              = rule.cidr_blocks
      source_security_group_id = rule.source_security_group_id
      description              = rule.description
    }
  } : {}
}

# Configuration Summary
output "firewall_configuration" {
  description = "Summary of firewall configuration"
  value = {
    node_security_group_created = var.create_node_security_group
    node_security_group_id      = var.create_node_security_group ? aws_security_group.node_group_sg[0].id : null
    p2p_ports                   = var.p2p_ports
    allowed_peer_cidrs          = var.allowed_peer_cidrs
    allowed_peer_security_groups = var.allowed_peer_security_groups
    additional_rules_count       = length(var.additional_security_group_rules)
  }
}
