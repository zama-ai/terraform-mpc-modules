terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
  }
}

# Configure AWS provider
provider "aws" {
  region = var.aws_region
}

# Configure Kubernetes provider
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context

  # Optional: EKS cluster authentication via AWS CLI
  dynamic "exec" {
    for_each = var.use_eks_cluster_authentication ? [1] : []
    content {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.aws_region]
      command     = "aws"
    }
  }
}