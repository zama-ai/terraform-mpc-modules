output "bucket_name" {
  description = "The name of the created S3 bucket"
  value       = aws_s3_bucket.backup_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the created S3 bucket"
  value       = aws_s3_bucket.backup_bucket.arn
}

output "role_name" {
  description = "The name of the IAM role created for accessing the bucket"
  value       = aws_iam_role.mpc_backup_role.name
}

output "role_arn" {
  description = "The ARN of the IAM role created for accessing the bucket"
  value       = aws_iam_role.mpc_backup_role.arn
}

output "replica_bucket_name" {
  description = "The name of the replica S3 bucket (empty when replication is disabled)"
  value       = var.enable_replication ? aws_s3_bucket.replica_bucket[0].id : ""
}

output "replica_bucket_arn" {
  description = "The ARN of the replica S3 bucket (empty when replication is disabled)"
  value       = var.enable_replication ? aws_s3_bucket.replica_bucket[0].arn : ""
}
