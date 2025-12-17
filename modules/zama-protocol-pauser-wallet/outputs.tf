output "aws_kms_key_id" {
  description = "Summary of the KMS Key for the application"
  value = local.kms_key_id
}