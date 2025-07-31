# Provider requirements are defined in versions.tf

# Create namespace if it doesn't exist
resource "kubernetes_namespace" "mpc_namespace" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

# Create LoadBalancer services for MPC nodes
resource "kubernetes_service" "mpc_nlb" {
  count                    = length(var.mpc_services)
  wait_for_load_balancer   = true

  metadata {
    name      = var.mpc_services[count.index].name
    namespace = var.create_namespace ? kubernetes_namespace.mpc_namespace[0].metadata[0].name : var.namespace

    annotations = merge({
      "service.beta.kubernetes.io/aws-load-balancer-type"                              = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-scheme"                            = "internal"
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"                  = "tcp"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                          = "true"
    }, var.mpc_services[count.index].additional_annotations)

    labels = merge({
      "app.kubernetes.io/name"      = var.mpc_services[count.index].name
      "app.kubernetes.io/instance"  = var.mpc_services[count.index].name
      "app.kubernetes.io/component" = "mpc-node"
      "app.kubernetes.io/part-of"   = "mpc-cluster"
    }, var.mpc_services[count.index].labels)
  }

  spec {
    type                        = "LoadBalancer"
    load_balancer_class         = "service.k8s.aws/nlb"
    session_affinity            = var.mpc_services[count.index].session_affinity
    external_traffic_policy     = var.mpc_services[count.index].external_traffic_policy
    internal_traffic_policy     = var.mpc_services[count.index].internal_traffic_policy
    load_balancer_source_ranges = var.mpc_services[count.index].load_balancer_source_ranges

    dynamic "port" {
      for_each = var.mpc_services[count.index].ports
      content {
        name        = port.value.name
        port        = port.value.port
        target_port = port.value.target_port
        protocol    = port.value.protocol
        node_port   = port.value.node_port
      }
    }

    selector = var.mpc_services[count.index].selector
  }

  timeouts {
    create = var.service_create_timeout
  }
}

# Extract Load Balancer names from the Kubernetes service hostnames
locals {
  # First extract the hostname parts for each service
  hostname_parts = [
    for service in kubernetes_service.mpc_nlb :
    split("-", split(".", service.status[0].load_balancer[0].ingress[0].hostname)[0])
  ]
  
  # Extract NLB names by removing the last hyphen-separated segment (random suffix)
  nlb_names = [
    for parts in local.hostname_parts :
    join("-", slice(parts, 0, length(parts) - 1))
  ]
}

# Look up the actual Network Load Balancers using AWS data sources
data "aws_lb" "kubernetes_nlbs" {
  count = length(local.nlb_names)
  name  = local.nlb_names[count.index]
  depends_on = [kubernetes_service.mpc_nlb]
}

# Cleanup security group rules for NLBs made by the native aws load balancer controller
# Remove when migrating to the aws load balancer controller v2
resource "null_resource" "cleanup_sg_rules" {
  # Force this resource to run on every apply/destroy of Terraform
  triggers = {
    nlb_names   = join(",", local.nlb_names)
    always_run  = timestamp()
  }

  provisioner "local-exec" {
    when    = destroy
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
      # Get all NLB names from the trigger (comma-separated)
      NLB_NAMES_COMMA="${self.triggers.nlb_names}"
      echo "NLB_NAMES_COMMA: $NLB_NAMES_COMMA"
      NLB_NAMES=$(echo "$NLB_NAMES_COMMA" | tr ',' ' ')
      echo "NLB_NAMES: $NLB_NAMES"
      
      # Process each NLB name
      for nlb_name in $NLB_NAMES; do
        echo "Looking for security group rules with descriptions containing: $nlb_name"
        
        # Get both rule IDs and group IDs for rules containing NLB name
        RULES_DATA=$(aws ec2 describe-security-group-rules \
          --query "SecurityGroupRules[?IsEgress==\`false\` && Description != null && contains(Description, '$nlb_name')].{RuleId:SecurityGroupRuleId,GroupId:GroupId}" \
          --output text)
        echo "RULES_DATA: $RULES_DATA"

        if [ -n "$RULES_DATA" ]; then
          # Process each rule (format: RuleId GroupId per line)
          echo "$RULES_DATA" | tr '\t' ' ' | while read GROUP_ID RULE_ID; do
            if [ -n "$RULE_ID" ] && [ -n "$GROUP_ID" ]; then
              aws ec2 revoke-security-group-ingress --group-id "$GROUP_ID" --security-group-rule-ids "$RULE_ID" --no-cli-pager 
              echo "Revoked rule $RULE_ID from group $GROUP_ID for $nlb_name"
            fi
          done
        else
          echo "No ingress rules found with description containing: $nlb_name"
        fi
      done
    EOT
  }

  # (Optional) prevent Terraform from complaining that this resource has no actual
  # create-time actions—you can also add a no-op create provisioner if you like.
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [data.aws_lb.kubernetes_nlbs]
}

