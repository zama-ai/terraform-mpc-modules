# ************
# General variables
# ************
variable "tags" {
  type        = map(string)
  description = "The tags for the KMS keys"
}

# ************
# Variables for usage in kms-for-mpc-party.tf
# ************

variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
  default     = null
}

variable "app_name" {
  type        = string
  description = "Name of the role"
  default     = "zama-protocol-pause"
}

variable "k8s_config_map_name" {
  type        = string
  description = "Name of the configmap"
  default     = "zama-protocol-pause"
}

variable "k8s_config_map_create" {
  type        = bool
  description = "Whether to create the configmap for that holds AWS_KMS_KEY_ID"
  default     = true
}

variable "k8s_service_account_name" {
  type        = string
  description = "Name of the service account"
  default     = "zama-protocol-pause"
}

variable "k8s_service_account_create" {
  type        = bool
  description = "Whether to create the service account for the KMS key"
  default     = true
}

variable "k8s_namespace" {
  type        = string
  description = "Namespace of the application"
  default     = "zama-protocol"
}

variable "k8s_create_namespace" {
  description = "Whether to create the namespace if it doesn't exist"
  type        = bool
  default     = false
}

variable "zama_protocol_pauser_iam_assumable_role_enabled" {
  type        = bool
  description = "Whether to enable the IAM assumable role for the application"
  default     = false
}

variable "kms_cross_account_iam_role_arn" {
  type        = string
  description = "ARN of cross-account IAM role allowed for usage of KMS key"
  default     = null
}

variable "kms_key_usage" {
  type        = string
  description = "Key usage for txsender"
  default     = "SIGN_VERIFY"
}

variable "kms_key_spec" {
  description = "Specification for the txsender (e.g., ECC_SECG_P256K1 for Ethereum key signing)"
  type        = string
  default     = "ECC_SECG_P256K1"
}

variable "kms_deletion_window_in_days" {
  type        = number
  description = "Deletion window in days for KMS key"
  default     = 30
}

variable "kms_use_cross_account_kms_key" {
  type        = bool
  description = "Whether a KMS key has been created in a different AWS account"
  default     = false
}

variable "kms_cross_account_kms_key_id" {
  type        = string
  description = "KMS key ID of KMS key created in a different AWS account"
  default     = ""
}
