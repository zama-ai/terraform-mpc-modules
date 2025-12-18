<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.23 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_assumable_role_tx_sender"></a> [iam\_assumable\_role\_tx\_sender](#module\_iam\_assumable\_role\_tx\_sender) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 5.48.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.app_kms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kms_alias.tx_sender](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_external_key.tx_sender](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_external_key) | resource |
| [kubernetes_config_map.mpc_party_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_namespace.zama_protocol_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service_account.tx_sender_irsa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_policy_document.tx_sender_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the role | `string` | `"zama-protocol-pause"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster | `string` | `null` | no |
| <a name="input_k8s_config_map_create"></a> [k8s\_config\_map\_create](#input\_k8s\_config\_map\_create) | Whether to create the configmap for that holds AWS\_KMS\_KEY\_ID | `bool` | `true` | no |
| <a name="input_k8s_config_map_name"></a> [k8s\_config\_map\_name](#input\_k8s\_config\_map\_name) | Name of the configmap | `string` | `"zama-protocol-pause"` | no |
| <a name="input_k8s_create_namespace"></a> [k8s\_create\_namespace](#input\_k8s\_create\_namespace) | Whether to create the namespace if it doesn't exist | `bool` | `false` | no |
| <a name="input_k8s_namespace"></a> [k8s\_namespace](#input\_k8s\_namespace) | Namespace of the application | `string` | `"zama-protocol"` | no |
| <a name="input_k8s_service_account_create"></a> [k8s\_service\_account\_create](#input\_k8s\_service\_account\_create) | Whether to create the service account for the KMS key | `bool` | `true` | no |
| <a name="input_k8s_service_account_name"></a> [k8s\_service\_account\_name](#input\_k8s\_service\_account\_name) | Name of the service account | `string` | `"zama-protocol-pause"` | no |
| <a name="input_kms_cross_account_iam_role_arn"></a> [kms\_cross\_account\_iam\_role\_arn](#input\_kms\_cross\_account\_iam\_role\_arn) | ARN of cross-account IAM role allowed for usage of KMS key | `string` | `null` | no |
| <a name="input_kms_cross_account_kms_key_id"></a> [kms\_cross\_account\_kms\_key\_id](#input\_kms\_cross\_account\_kms\_key\_id) | KMS key ID of KMS key created in a different AWS account | `string` | `""` | no |
| <a name="input_kms_deletion_window_in_days"></a> [kms\_deletion\_window\_in\_days](#input\_kms\_deletion\_window\_in\_days) | Deletion window in days for KMS key | `number` | `30` | no |
| <a name="input_kms_key_spec"></a> [kms\_key\_spec](#input\_kms\_key\_spec) | Specification for the txsender (e.g., ECC\_SECG\_P256K1 for Ethereum key signing) | `string` | `"ECC_SECG_P256K1"` | no |
| <a name="input_kms_key_usage"></a> [kms\_key\_usage](#input\_kms\_key\_usage) | Key usage for txsender | `string` | `"SIGN_VERIFY"` | no |
| <a name="input_kms_use_cross_account_kms_key"></a> [kms\_use\_cross\_account\_kms\_key](#input\_kms\_use\_cross\_account\_kms\_key) | Whether a KMS key has been created in a different AWS account | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags for the KMS keys | `map(string)` | n/a | yes |
| <a name="input_zama_protocol_pauser_iam_assumable_role_enabled"></a> [zama\_protocol\_pauser\_iam\_assumable\_role\_enabled](#input\_zama\_protocol\_pauser\_iam\_assumable\_role\_enabled) | Whether to enable the IAM assumable role for the application | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_kms_key_id"></a> [aws\_kms\_key\_id](#output\_aws\_kms\_key\_id) | Summary of the KMS Key for the application |
<!-- END_TF_DOCS -->