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
  default     = "RSA_4096"
}

variable "aws_region" {
  type        = string
  description = <<-EOT
  AWS region where module resources are deployed. If null, the default provider region is used.

  Preferred regions by operator:
  - eu-central-1: LayerZero
  - eu-west-1: Zama 1
  - ca-central-1: OpenZeppelin
  - us-west-2: StakeCapital
  - us-east-1: Omakase
  - eu-west-2: Figment
  - eu-north-1: Fireblocks
  - eu-west-3: Unit410 (Zama for the moment)
  - eu-south-1: Infstones
  - ap-southeast-2: Dfns
  - ap-northeast-1: Luganodes
  - ap-southeast-1: Etherscan - p2p
  - ap-northeast-3: Conduit
  EOT
  default     = null
}
