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
  nullable    = false

  validation {
    condition     = can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:role/.+$", var.mpc_party_cross_account_iam_role_arn))
    error_message = "mpc_party_cross_account_iam_role_arn must be an IAM role ARN."
  }
}

variable "mpc_party_kms_image_attestation_sha" {
  type        = string
  description = "Attestation SHA for KMS image"
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F]{96}$", var.mpc_party_kms_image_attestation_sha))
    error_message = "mpc_party_kms_image_attestation_sha must be a SHA-384 digest (96 hex characters)."
  }
}

variable "mpc_party_kms_alias" {
  type        = string
  description = "Alias for the KMS key, suffixed with -backup"
  nullable    = false

  validation {
    condition     = startswith(var.mpc_party_kms_alias, "alias/") && !startswith(var.mpc_party_kms_alias, "alias/aws/")
    error_message = "mpc_party_kms_alias must start with alias/ and must not start with alias/aws/."
  }
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
  default     = "RSA_4096"
}

variable "mpc_party_kms_backup_replica_region" {
  type        = string
  description = "AWS region for the optional multi-Region KMS replica key"
  default     = null
}
