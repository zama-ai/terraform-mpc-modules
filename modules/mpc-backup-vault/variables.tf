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

variable "bucket_cross_account_id" {
  type        = string
  description = "ID of the AWS account that can access the backup bucket."
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
