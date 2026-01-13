# ***************************************
#  Local variables
# ***************************************
resource "random_id" "mpc_party_suffix" {
  byte_length = 4
}
locals {
  backup_bucket_name = "${var.bucket_prefix}-${var.party_name}-${random_id.mpc_party_suffix.hex}"
}

# ***************************************
#  S3 Buckets for Vault Private Storage
# ***************************************
resource "aws_s3_bucket" "backup_bucket" {
  force_destroy = true
  bucket        = local.backup_bucket_name
  tags = merge(var.tags, {
    "Name"    = local.backup_bucket_name
    "Type"    = "backup-vault"
    "Party"   = var.party_name
    "Purpose" = "mpc-backup-storage"
  })
}

resource "aws_s3_bucket_ownership_controls" "backup_bucket" {
  bucket = aws_s3_bucket.backup_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "backup_bucket" {
  bucket = aws_s3_bucket.backup_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "backup_bucket" {
  bucket                  = aws_s3_bucket.backup_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ***************************************
#  IAM Role & Policy for MPC Backup Vault
# ***************************************

# Trust policy: Allow trusted principals to assume this role
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.trusted_principal_arns
    }
  }
}

resource "aws_iam_role" "mpc_backup_role" {
  name               = "mpc-backup-${var.party_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

# Policy allowing access to the bucket
resource "aws_iam_policy" "mpc_aws" {
  name = "mpc-backup-${var.party_name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowObjectActions"
        Effect = "Allow"
        Action = "s3:*Object"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.backup_bucket.id}/*"
        ]
      },
      {
        Sid    = "AllowListBucket"
        Effect = "Allow"
        Action = "s3:ListBucket"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.backup_bucket.id}"
        ]
      }
    ]
  })
}

# Attach policy to the role
resource "aws_iam_role_policy_attachment" "mpc_backup_attach" {
  role       = aws_iam_role.mpc_backup_role.name
  policy_arn = aws_iam_policy.mpc_aws.arn
}
