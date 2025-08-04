# Data sources
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_vpc" "cluster_vpc" {
  id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
}

# Security Group for Node Group (optional, for hostPort restrictions)
resource "aws_security_group" "node_group_sg" {
  count = var.create_node_security_group ? 1 : 0

  name        = var.node_security_group_name != "" ? var.node_security_group_name : "${var.name}-nodegroup-sg"
  description = var.node_security_group_description
  vpc_id      = data.aws_vpc.cluster_vpc.id

  # Allow all egress traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  # Allow inbound traffic from cluster security group
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id]
    description     = "Cluster communication"
  }

  # Allow SSH from cluster security group if needed
  //ingress {
  //  from_port       = 0
  //  to_port         = 65535
  //  protocol        = "tcp"
  //  security_groups = [data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id]
  //  description     = "Cluster communication"
  //}

  tags = merge(var.tags, {
    Name = var.node_security_group_name != "" ? var.node_security_group_name : "${var.name}-nodegroup-sg"
    Type = "EKS-NodeGroup-SecurityGroup"
  })
}

# P2P Port rules for trusted peers (CIDR-based)
resource "aws_security_group_rule" "p2p_cidr_rules" {
  for_each = var.create_node_security_group && length(var.allowed_peer_cidrs) > 0 ? {
    for idx, port in var.p2p_ports : "${port.protocol}-${port.from_port}-${idx}" => port
  } : {}

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = var.allowed_peer_cidrs
  description       = "${each.value.description} from trusted CIDRs"
  security_group_id = aws_security_group.node_group_sg[0].id
}

# P2P Port rules for trusted peers (Security Group-based)
resource "aws_security_group_rule" "p2p_sg_rules" {
  for_each = var.create_node_security_group && length(var.allowed_peer_security_groups) > 0 ? {
    for combo in setproduct(var.p2p_ports, var.allowed_peer_security_groups) : 
    "${combo[0].protocol}-${combo[0].from_port}-${combo[1]}" => {
      port = combo[0]
      sg   = combo[1]
    }
  } : {}

  type                     = "ingress"
  from_port                = each.value.port.from_port
  to_port                  = each.value.port.to_port
  protocol                 = each.value.port.protocol
  source_security_group_id = each.value.sg
  description              = "${each.value.port.description} from trusted security group"
  security_group_id        = aws_security_group.node_group_sg[0].id
}

# Additional custom security group rules
resource "aws_security_group_rule" "additional_rules" {
  for_each = var.create_node_security_group ? {
    for idx, rule in var.additional_security_group_rules : "${rule.type}-${rule.protocol}-${rule.from_port}-${idx}" => rule
  } : {}

  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = each.value.cidr_blocks
  source_security_group_id = each.value.source_security_group_id
  description              = each.value.description
  security_group_id        = aws_security_group.node_group_sg[0].id
}