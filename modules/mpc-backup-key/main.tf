# ************
# Data Sources
# ************
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  kms_backup_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow access for Key Administrators", # https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:ReplicateKey"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow MPC party to read the backup public key",
        Effect = "Allow",
        Principal = {
          AWS = var.mpc_party_cross_account_iam_role_arn
        },
        Action = [
          "kms:GetPublicKey",
          "kms:DescribeKey",
        ],
        Resource = "*"
      },
      {
        # GenerateDataKey is not granted: it is not supported on asymmetric keys, and backups are
        # encrypted locally under the public key.
        Sid    = "Allow attested MPC party enclave to decrypt backups",
        Effect = "Allow",
        Principal = {
          AWS = var.mpc_party_cross_account_iam_role_arn
        },
        Action = [
          "kms:Decrypt",
        ],
        Resource = "*",
        Condition = {
          StringEqualsIgnoreCase = {
            "kms:RecipientAttestation:ImageSha384" : var.mpc_party_kms_image_attestation_sha
          }
        }
      },
    ]
  })
}

# ************
#  ASYMMETRIC KMS Key Backup for MPC Party
# ************
resource "aws_kms_key" "this_backup" {
  description              = var.mpc_party_kms_backup_description
  key_usage                = var.mpc_party_kms_backup_vault_key_usage
  customer_master_key_spec = var.mpc_party_kms_backup_vault_customer_master_key_spec
  multi_region             = true
  enable_key_rotation      = false
  deletion_window_in_days  = var.mpc_party_kms_deletion_window_in_days
  tags                     = var.tags

  policy = local.kms_backup_policy
}

resource "aws_kms_alias" "this_backup" {
  name          = "${var.mpc_party_kms_alias}-backup"
  target_key_id = aws_kms_key.this_backup.key_id
}

# The replica uses the caller's provider with a per-resource region (AWS provider >= 6.0), so it
# is created with the same credentials and in the same account as the primary key.
resource "aws_kms_replica_key" "this_backup" {
  count = var.mpc_party_kms_backup_replica_region == null ? 0 : 1

  region                  = var.mpc_party_kms_backup_replica_region
  description             = "${var.mpc_party_kms_backup_description} (replica)"
  deletion_window_in_days = var.mpc_party_kms_deletion_window_in_days
  primary_key_arn         = aws_kms_key.this_backup.arn
  policy                  = local.kms_backup_policy
  tags                    = var.tags

  lifecycle {
    precondition {
      condition     = var.mpc_party_kms_backup_replica_region != data.aws_region.current.region
      error_message = "mpc_party_kms_backup_replica_region must differ from the primary key region."
    }
  }
}

resource "aws_kms_alias" "this_backup_replica" {
  count = var.mpc_party_kms_backup_replica_region == null ? 0 : 1

  region        = var.mpc_party_kms_backup_replica_region
  name          = "${var.mpc_party_kms_alias}-backup"
  target_key_id = aws_kms_replica_key.this_backup[0].key_id
}
