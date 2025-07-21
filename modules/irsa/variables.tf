variable "party_name" {
  type        = string
  description = "The name of the party"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "k8s_namespace" {
  type        = string
  description = "The namespace of the service account"
}

variable "k8s_service_account_name" {
  type        = string
  description = "The name of the service account"
}

variable "policy" {
  type        = string
  description = "The policy for the role"
}

variable "name" {
  type        = string
  description = "The name of the role"
}