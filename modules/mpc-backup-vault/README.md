# MPC Key backup modules

This module creates an S3 bucket for MPC key backup storage, with optional cross-region replication for disaster recovery.

The KMS backup keys are handled by the mpc-backup-key module.

## Usage

### Without replication (default)

```hcl
module "mpc_backup_vault" {
  source = "git::https://github.com/zama-ai/terraform-mpc-modules.git//modules/mpc-backup-vault?ref=v0.x.x"

  party_name              = "my-party"
  bucket_cross_account_id = "123456789012"
  trusted_principal_arns  = ["arn:aws:iam::123456789012:role/my-role"]
}
```

### With cross-region replication

```hcl
module "mpc_backup_vault" {
  source = "git::https://github.com/zama-ai/terraform-mpc-modules.git//modules/mpc-backup-vault?ref=v0.x.x"

  party_name              = "my-party"
  bucket_cross_account_id = "123456789012"
  trusted_principal_arns  = ["arn:aws:iam::123456789012:role/my-role"]

  enable_replication    = true
  replica_region        = "eu-west-1"
  replica_bucket_prefix = "mpc-backup-vault-replica"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |
| <a name="provider_aws.replica"></a> [aws.replica](#provider\_aws.replica) | >= 6.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.mpc_aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.replication_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.mpc_backup_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.replication_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.mpc_backup_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.replication_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.backup_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.replica_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_ownership_controls.backup_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.backup_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.backup_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.replica_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.backup_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_versioning.backup_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.replica_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [random_id.mpc_party_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.replication_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | The prefix for the S3 bucket names | `string` | `"mpc-backup-vault"` | no |
| <a name="input_enable_replication"></a> [enable\_replication](#input\_enable\_replication) | Enable cross-region replication for the backup bucket. | `bool` | `false` | no |
| <a name="input_mpc_backup_replication_role_name"></a> [mpc\_backup\_replication\_role\_name](#input\_mpc\_backup\_replication\_role\_name) | The name of the MPC backup replication role. | `string` | `null` | no |
| <a name="input_mpc_backup_role_name"></a> [mpc\_backup\_role\_name](#input\_mpc\_backup\_role\_name) | The name of the MPC backup role. | `string` | `null` | no |
| <a name="input_party_name"></a> [party\_name](#input\_party\_name) | The name of the MPC party (used for resource naming and tagging) | `string` | n/a | yes |
| <a name="input_replica_bucket_prefix"></a> [replica\_bucket\_prefix](#input\_replica\_bucket\_prefix) | The prefix for the replica S3 bucket name. | `string` | `"mpc-backup-vault-replica"` | no |
| <a name="input_replica_region"></a> [replica\_region](#input\_replica\_region) | AWS region for the replica bucket. Required when enable\_replication is true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | <pre>{<br/>  "module": "mpc-party",<br/>  "terraform": "true"<br/>}</pre> | no |
| <a name="input_trusted_principal_arns"></a> [trusted\_principal\_arns](#input\_trusted\_principal\_arns) | List of ARNs (users, roles, or root accounts) that can assume the backup role. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the created S3 bucket |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name of the created S3 bucket |
| <a name="output_replica_bucket_arn"></a> [replica\_bucket\_arn](#output\_replica\_bucket\_arn) | The ARN of the replica S3 bucket (empty when replication is disabled) |
| <a name="output_replica_bucket_name"></a> [replica\_bucket\_name](#output\_replica\_bucket\_name) | The name of the replica S3 bucket (empty when replication is disabled) |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role created for accessing the bucket |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the IAM role created for accessing the bucket |
<!-- END_TF_DOCS -->
