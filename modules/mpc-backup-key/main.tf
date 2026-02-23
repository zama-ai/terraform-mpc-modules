# ************
# Data Sources
# ************
data "aws_caller_identity" "current" {}

# ************
#  ASYMMETRIC KMS Key Backup for MPC Party
# ************
resource "aws_kms_key" "this_backup" {
  description              = var.mpc_party_kms_backup_description
  key_usage                = var.mpc_party_kms_backup_vault_key_usage
  customer_master_key_spec = var.mpc_party_kms_backup_vault_customer_master_key_spec
  enable_key_rotation      = false
  deletion_window_in_days  = var.mpc_party_kms_deletion_window_in_days
  tags                     = var.tags

  policy = jsonencode({
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
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      },
      {
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
        Effect = "Allow",
        Principal = {
          AWS = var.mpc_party_cross_account_iam_role_arn
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
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

resource "aws_kms_alias" "this_backup" {
  name          = "${var.mpc_party_kms_alias}-backup"
  target_key_id = aws_kms_key.this_backup.key_id
}
