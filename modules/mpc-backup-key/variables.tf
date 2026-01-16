# ************
# General variables
# ************
# Tagging
variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource"
  default = {
    "terraform" = "true"
    "module"    = "mpc-party-backup"
  }
}

# ************
# Variables for usage in main.tf
# ************

variable "mpc_party_cross_account_iam_role_arn" {
  type        = string
  description = "ARN of cross-account IAM role allowed for usage of KMS key"
  default     = null
}

variable "mpc_party_kms_image_attestation_sha" {
  type        = string
  description = "Attestation SHA for KMS image"
  default     = null
}

variable "mpc_party_kms_alias" {
  type        = string
  description = "Alias for the KMS key"
  default     = null
}

variable "mpc_party_kms_deletion_window_in_days" {
  type        = number
  description = "Deletion window in days for KMS key"
  default     = 30
}

variable "mpc_party_kms_backup_description" {
  type        = string
  description = "Description of KMS Key"
  default     = "Asymmetric KMS key backup for MPC Party"
}

variable "mpc_party_kms_backup_vault_key_usage" {
  type        = string
  description = "Key usage for the backup vault"
  default     = "ENCRYPT_DECRYPT"
}

variable "mpc_party_kms_backup_vault_customer_master_key_spec" {
  type        = string
  description = "Key spec for the backup vault"
  default     = "ASYMMETRIC_DEFAULT"
}
