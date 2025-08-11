output "iam_role_arn" {
  description = "ARN of the IAM role for IRSA"
  value       = module.iam_assumable_role_mpc_party.iam_role_arn
}

output "iam_role_name" {
  description = "Name of the IAM role for IRSA"
  value       = module.iam_assumable_role_mpc_party.iam_role_name
}