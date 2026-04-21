provider "aws" {
  alias  = "replica"
  region = var.replica_region
}

# ***************************************
#  Local variables
# ***************************************
resource "random_id" "mpc_party_suffix" {
  byte_length = 4
}
locals {
  backup_bucket_name  = "${var.bucket_prefix}-${var.party_name}-${random_id.mpc_party_suffix.hex}"
  replica_bucket_name = "${var.replica_bucket_prefix}-${var.party_name}-${random_id.mpc_party_suffix.hex}"
}

# ***************************************
#  S3 Buckets for Vault Private Storage
# ***************************************
resource "aws_s3_bucket" "backup_bucket" {
  bucket = local.backup_bucket_name
  lifecycle {
    prevent_destroy = true
  }
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

resource "aws_s3_bucket_policy" "backup_bucket" {
  bucket = aws_s3_bucket.backup_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountBackup"
        Effect = "Allow"
        Principal = {
          AWS = var.trusted_principal_arns
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.backup_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.backup_bucket.id}/*"
        ]
      }
    ]
  })
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
  name               = var.mpc_backup_role_name != null ? var.mpc_backup_role_name : "mpc-backup-${var.party_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

# Policy allowing access to the bucket
resource "aws_iam_policy" "mpc_aws" {
  name = var.mpc_backup_role_name != null ? var.mpc_backup_role_name : "mpc-backup-${var.party_name}"
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

# ***************************************
#  S3 Replica Bucket (Cross-Region)
# ***************************************
resource "aws_s3_bucket" "replica_bucket" {
  count    = var.enable_replication ? 1 : 0
  provider = aws.replica
  bucket   = local.replica_bucket_name

  lifecycle {
    prevent_destroy = true
    precondition {
      condition     = var.replica_region != null
      error_message = "replica_region must be set when enable_replication is true."
    }
  }

  tags = merge(var.tags, {
    "Name"    = local.replica_bucket_name
    "Type"    = "backup-vault-replica"
    "Party"   = var.party_name
    "Purpose" = "mpc-backup-storage-replica"
  })
}

resource "aws_s3_bucket_versioning" "replica_bucket" {
  count    = var.enable_replication ? 1 : 0
  provider = aws.replica
  bucket   = aws_s3_bucket.replica_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "replica_bucket" {
  count                   = var.enable_replication ? 1 : 0
  provider                = aws.replica
  bucket                  = aws_s3_bucket.replica_bucket[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ***************************************
#  IAM Role & Policy for S3 Replication
# ***************************************
data "aws_iam_policy_document" "replication_assume_role" {
  count = var.enable_replication ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "replication_role" {
  count              = var.enable_replication ? 1 : 0
  name               = var.mpc_backup_replication_role_name != null ? var.mpc_backup_replication_role_name : "mpc-backup-replication-${var.party_name}"
  assume_role_policy = data.aws_iam_policy_document.replication_assume_role[0].json
  tags               = var.tags
}

resource "aws_iam_policy" "replication_policy" {
  count = var.enable_replication ? 1 : 0
  name  = var.mpc_backup_replication_role_name != null ? var.mpc_backup_replication_role_name : "mpc-backup-replication-${var.party_name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSourceBucketReplication"
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.backup_bucket.arn
      },
      {
        Sid    = "AllowSourceObjectRead"
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${aws_s3_bucket.backup_bucket.arn}/*"
      },
      {
        Sid    = "AllowDestinationReplication"
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "${aws_s3_bucket.replica_bucket[0].arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication_attach" {
  count      = var.enable_replication ? 1 : 0
  role       = aws_iam_role.replication_role[0].name
  policy_arn = aws_iam_policy.replication_policy[0].arn
}

# ***************************************
#  S3 Replication Configuration
# ***************************************
resource "aws_s3_bucket_replication_configuration" "backup_bucket" {
  count  = var.enable_replication ? 1 : 0
  bucket = aws_s3_bucket.backup_bucket.id
  role   = aws_iam_role.replication_role[0].arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica_bucket[0].arn
      storage_class = "STANDARD"
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.backup_bucket,
    aws_s3_bucket_versioning.replica_bucket
  ]
}
