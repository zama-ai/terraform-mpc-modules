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
  backend "s3" {
    bucket         = "zama-mpc-testnet-terraform-states"
    key            = "zama-mpc-network-consumer-testnet/terraform.tfstate"
    region         = "eu-west-1"
    # For old Terraform (< 1.9)
    dynamodb_table = "zama-terraform-locks"

    # For new Terraform (>= 1.9)
    use_lockfile   = true
    encrypt        = true
  }
}

# Configure providers
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_eks_cluster" "this_provider" {
  count = var.use_eks_cluster_authentication ? 1 : 0
  name  = var.cluster_name
}

provider "kubernetes" {
  config_path            = var.use_eks_cluster_authentication ? null : var.kubeconfig_path
  config_context         = var.use_eks_cluster_authentication ? null : var.kubeconfig_context
  host                   = var.use_eks_cluster_authentication ? data.aws_eks_cluster.this_provider[0].endpoint : null
  cluster_ca_certificate = var.use_eks_cluster_authentication ? base64decode(data.aws_eks_cluster.this_provider[0].certificate_authority[0].data) : null

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.aws_region]
    command     = "aws"
  }
}