terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

  }
} 