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
