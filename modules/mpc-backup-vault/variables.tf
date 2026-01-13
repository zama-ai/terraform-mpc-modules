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
