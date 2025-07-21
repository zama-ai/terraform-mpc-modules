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
      #"service.beta.kubernetes.io/aws-load-balancer-healthcheck-protocol"              = "tcp"
      #"service.beta.kubernetes.io/aws-load-balancer-healthcheck-port"                  = "traffic-port"
      #"service.beta.kubernetes.io/aws-load-balancer-healthcheck-interval"              = "10"
      #"service.beta.kubernetes.io/aws-load-balancer-healthcheck-timeout"               = "6"
      #"service.beta.kubernetes.io/aws-load-balancer-healthy-threshold"                 = "2"
      #"service.beta.kubernetes.io/aws-load-balancer-unhealthy-threshold"               = "2"
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
  # Extract NLB names from the DNS hostnames
  nlb_names = [
    for service in kubernetes_service.mpc_nlb :
    split("-", split(".", service.status[0].load_balancer[0].ingress[0].hostname)[0])[0]
  ]
}

# Look up the actual Network Load Balancers using AWS data sources
data "aws_lb" "kubernetes_nlbs" {
  count = length(local.nlb_names)
  name  = local.nlb_names[count.index]
  depends_on = [kubernetes_service.mpc_nlb]
}