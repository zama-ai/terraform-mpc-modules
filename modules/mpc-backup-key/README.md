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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.this_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_mpc_party_cross_account_iam_role_arn"></a> [mpc\_party\_cross\_account\_iam\_role\_arn](#input\_mpc\_party\_cross\_account\_iam\_role\_arn) | ARN of cross-account IAM role allowed for usage of KMS key | `string` | `null` | no |
| <a name="input_mpc_party_kms_alias"></a> [mpc\_party\_kms\_alias](#input\_mpc\_party\_kms\_alias) | Alias for the KMS key | `string` | `null` | no |
| <a name="input_mpc_party_kms_backup_description"></a> [mpc\_party\_kms\_backup\_description](#input\_mpc\_party\_kms\_backup\_description) | Description of KMS Key | `string` | `"Asymmetric KMS key backup for MPC Party"` | no |
| <a name="input_mpc_party_kms_backup_vault_customer_master_key_spec"></a> [mpc\_party\_kms\_backup\_vault\_customer\_master\_key\_spec](#input\_mpc\_party\_kms\_backup\_vault\_customer\_master\_key\_spec) | Key spec for the backup vault | `string` | `"ASYMMETRIC_DEFAULT"` | no |
| <a name="input_mpc_party_kms_backup_vault_key_usage"></a> [mpc\_party\_kms\_backup\_vault\_key\_usage](#input\_mpc\_party\_kms\_backup\_vault\_key\_usage) | Key usage for the backup vault | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_mpc_party_kms_deletion_window_in_days"></a> [mpc\_party\_kms\_deletion\_window\_in\_days](#input\_mpc\_party\_kms\_deletion\_window\_in\_days) | Deletion window in days for KMS key | `number` | `30` | no |
| <a name="input_mpc_party_kms_image_attestation_sha"></a> [mpc\_party\_kms\_image\_attestation\_sha](#input\_mpc\_party\_kms\_image\_attestation\_sha) | Attestation SHA for KMS image | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | <pre>{<br/>  "module": "mpc-party-backup",<br/>  "terraform": "true"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The ARN of the KMS key |
<!-- END_TF_DOCS -->
