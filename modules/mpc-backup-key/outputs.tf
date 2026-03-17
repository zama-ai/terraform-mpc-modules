output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.this_backup.arn
}

output "kms_replica_key_arn" {
  description = "The ARN of the replica KMS key, if configured"
  value       = try(aws_kms_replica_key.this_backup[0].arn, null)
}
