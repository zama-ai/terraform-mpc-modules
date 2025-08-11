# Node Group Information
output "node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = module.eks_managed_node_group.node_group_arn
}

output "node_group_id" {
  description = "EKS Node Group name"
  value       = module.eks_managed_node_group.node_group_id
}

output "node_group_status" {
  description = "Status of the EKS Node Group"
  value       = module.eks_managed_node_group.node_group_status
}

output "node_group_resources" {
  description = "Resources associated with the EKS Node Group"
  value       = module.eks_managed_node_group.node_group_resources
}

# Launch Template Information
output "launch_template_id" {
  description = "The ID of the launch template"
  value       = module.eks_managed_node_group.launch_template_id
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = module.eks_managed_node_group.launch_template_arn
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = module.eks_managed_node_group.launch_template_latest_version
}

# Auto Scaling Group Information
output "asg_name" {
  description = "Name of the autoscaling group"
  value       = try(module.eks_managed_node_group.asg_name, null)
}

output "asg_arn" {
  description = "ARN of the autoscaling group"
  value       = try(module.eks_managed_node_group.asg_arn, null)
}

# Security Group Information
output "security_group_arn" {
  description = "Amazon Resource Name (ARN) of the worker node shared security group"
  value       = module.eks_managed_node_group.security_group_arn
}

output "security_group_id" {
  description = "ID of the worker node shared security group"
  value       = module.eks_managed_node_group.security_group_id
}

# IAM Role Information
output "iam_role_name" {
  description = "The name of the IAM role"
  value       = module.eks_managed_node_group.iam_role_name
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.eks_managed_node_group.iam_role_arn
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.eks_managed_node_group.iam_role_unique_id
}
