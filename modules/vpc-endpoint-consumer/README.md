# VPC Endpoint Consumer Module

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.23 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.partner_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_vpc_endpoint.party_interface_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [kubernetes_namespace.partner_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service.party_services](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [null_resource.sync_s3_bucket](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_eks_cluster.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.cluster_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [kubernetes_config_map_v1.mpc_party_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/config_map_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster to lookup VPC, subnet, and security group details (Mode 1). If provided, vpc\_id, subnet\_ids, and security\_group\_ids will be ignored. | `string` | `null` | no |
| <a name="input_create_custom_dns_records"></a> [create\_custom\_dns\_records](#input\_create\_custom\_dns\_records) | Whether to create custom DNS records for the VPC interface endpoints | `bool` | `false` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Whether to create the namespace if it doesn't exist | `bool` | `false` | no |
| <a name="input_default_mpc_ports"></a> [default\_mpc\_ports](#input\_default\_mpc\_ports) | Default port configurations for MPC services. These can be overridden per service in party\_services configuration. | <pre>object({<br/>    grpc = object({<br/>      name        = string<br/>      port        = number<br/>      target_port = number<br/>      protocol    = string<br/>    })<br/>    peer = object({<br/>      name        = string<br/>      port        = number<br/>      target_port = number<br/>      protocol    = string<br/>    })<br/>    metrics = object({<br/>      name        = string<br/>      port        = number<br/>      target_port = number<br/>      protocol    = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "grpc": {<br/>    "name": "grpc",<br/>    "port": 50100,<br/>    "protocol": "TCP",<br/>    "target_port": 50100<br/>  },<br/>  "metrics": {<br/>    "name": "metrics",<br/>    "port": 9646,<br/>    "protocol": "TCP",<br/>    "target_port": 9646<br/>  },<br/>  "peer": {<br/>    "name": "peer",<br/>    "port": 50001,<br/>    "protocol": "TCP",<br/>    "target_port": 50001<br/>  }<br/>}</pre> | no |
| <a name="input_dns_domain"></a> [dns\_domain](#input\_dns\_domain) | DNS domain for custom DNS records | `string` | `"mpc-partners.local"` | no |
| <a name="input_enable_grpc_port"></a> [enable\_grpc\_port](#input\_enable\_grpc\_port) | Whether to enable and expose the gRPC port in the load balancer service | `bool` | `true` | no |
| <a name="input_endpoint_create_timeout"></a> [endpoint\_create\_timeout](#input\_endpoint\_create\_timeout) | Timeout for creating VPC interface endpoints | `string` | `"10m"` | no |
| <a name="input_endpoint_delete_timeout"></a> [endpoint\_delete\_timeout](#input\_endpoint\_delete\_timeout) | Timeout for deleting VPC interface endpoints | `string` | `"10m"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for naming VPC interface endpoint resources | `string` | `"mpc-partner"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace where partner services will be created | `string` | `"kms-decentralized"` | no |
| <a name="input_party_services"></a> [party\_services](#input\_party\_services) | List of partner MPC services to connect to via VPC interface endpoints | <pre>list(object({<br/>    name                      = string<br/>    region                    = string<br/>    party_id                  = string<br/>    account_id                = optional(string, null)<br/>    partner_name              = optional(string, null)<br/>    vpc_endpoint_service_name = string<br/>    public_bucket_url            = optional(string, null)<br/>    ports = optional(list(object({<br/>      name        = string<br/>      port        = number<br/>      target_port = number<br/>      protocol    = string<br/>    })), null)<br/>    availability_zones  = optional(list(string), null)<br/>    create_kube_service = optional(bool, true)<br/>    kube_service_config = optional(object({<br/>      additional_annotations = optional(map(string), {})<br/>      labels                 = optional(map(string), {})<br/>      session_affinity       = optional(string, "None")<br/>    }), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_private_dns_enabled"></a> [private\_dns\_enabled](#input\_private\_dns\_enabled) | Whether to enable private DNS for the VPC interface endpoints | `bool` | `false` | no |
| <a name="input_private_zone_id"></a> [private\_zone\_id](#input\_private\_zone\_id) | Route53 private hosted zone ID for custom DNS records | `string` | `""` | no |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids) | List of route table IDs to associate with the VPC interface endpoints | `list(string)` | `[]` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to associate with the VPC interface endpoints (Mode 2). Required if cluster\_name is not provided. | `list(string)` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs where the VPC interface endpoints will be created (Mode 2). Required if cluster\_name is not provided. | `list(string)` | `null` | no |
| <a name="input_sync_bucket"></a> [sync\_bucket](#input\_sync\_bucket) | Sync bucket for the MPC service | <pre>object({<br/>    enabled        = optional(bool, false)<br/>    configmap_name = optional(string, "mpc-party")<br/>  })</pre> | <pre>{<br/>  "configmap_name": "mpc-party",<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to VPC interface endpoint resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the VPC interface endpoints will be created (Mode 2). Required if cluster\_name is not provided. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_summary"></a> [connection\_summary](#output\_connection\_summary) | Summary of partner connections for easy reference |
| <a name="output_custom_dns_records"></a> [custom\_dns\_records](#output\_custom\_dns\_records) | Custom DNS records created for the VPC interface endpoints (if enabled) |
| <a name="output_kubernetes_service_external_names"></a> [kubernetes\_service\_external\_names](#output\_kubernetes\_service\_external\_names) | External names (VPC interface endpoint DNS) used by the Kubernetes services |
| <a name="output_kubernetes_service_names"></a> [kubernetes\_service\_names](#output\_kubernetes\_service\_names) | Names of the created Kubernetes services for partner connections |
| <a name="output_kubernetes_service_namespaces"></a> [kubernetes\_service\_namespaces](#output\_kubernetes\_service\_namespaces) | Namespaces of the created Kubernetes services for partner connections |
| <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name) | Name of the namespace where partner services are deployed |
| <a name="output_partner_connection_endpoints"></a> [partner\_connection\_endpoints](#output\_partner\_connection\_endpoints) | Connection endpoints for applications to use when connecting to partner services |
| <a name="output_partner_service_details"></a> [partner\_service\_details](#output\_partner\_service\_details) | Detailed information about the partner services and their connections |
| <a name="output_vpc_interface_endpoint_dns_names"></a> [vpc\_interface\_endpoint\_dns\_names](#output\_vpc\_interface\_endpoint\_dns\_names) | DNS names of the created VPC interface endpoints |
| <a name="output_vpc_interface_endpoint_hosted_zone_ids"></a> [vpc\_interface\_endpoint\_hosted\_zone\_ids](#output\_vpc\_interface\_endpoint\_hosted\_zone\_ids) | Hosted zone IDs of the created VPC interface endpoints |
| <a name="output_vpc_interface_endpoint_ids"></a> [vpc\_interface\_endpoint\_ids](#output\_vpc\_interface\_endpoint\_ids) | IDs of the created VPC interface endpoints |
| <a name="output_vpc_interface_endpoint_service_names"></a> [vpc\_interface\_endpoint\_service\_names](#output\_vpc\_interface\_endpoint\_service\_names) | Service names of the created VPC interface endpoints |
<!-- END_TF_DOCS -->
