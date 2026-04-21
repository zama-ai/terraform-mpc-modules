# Tagging
variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource"
  default = {
    "terraform" = "true"
    "module"    = "mpc-party"
  }
}

variable "bucket_prefix" {
  type        = string
  description = "The prefix for the S3 bucket names"
  default     = "mpc-backup-vault"
}

# MPC Party Configuration
variable "party_name" {
  type        = string
  description = "The name of the MPC party (used for resource naming and tagging)"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.party_name))
    error_message = "Party name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "trusted_principal_arns" {
  type        = list(string)
  description = "List of ARNs (users, roles, or root accounts) that can assume the backup role."
  default     = []
}

# Replication Configuration
variable "enable_replication" {
  type        = bool
  description = "Enable cross-region replication for the backup bucket."
  default     = false
}

variable "replica_region" {
  type        = string
  description = "AWS region for the replica bucket. Required when enable_replication is true."
  default     = null
}

variable "replica_bucket_prefix" {
  type        = string
  description = "The prefix for the replica S3 bucket name."
  default     = "mpc-backup-vault-replica"
}

variable "mpc_backup_role_name" {
  type        = string
  description = "The name of the MPC backup role."
  default     = null
}

variable "mpc_backup_replication_role_name" {
  type        = string
  description = "The name of the MPC backup replication role."
  default     = null
}
