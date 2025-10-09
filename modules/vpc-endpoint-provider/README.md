# VPC Endpoint Provider Module

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.10 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >= 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.10 |
| <a name="provider_external"></a> [external](#provider\_external) | >= 2.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.23 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_vpc_endpoint_service.mpc_nlb_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service) | resource |
| [kubernetes_namespace.mpc_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service.mpc_nlb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [aws_availability_zones.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_lb.kubernetes_nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [external_external.nlb_availability_zones](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.wait_nlb](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [kubernetes_config_map_v1.mpc_party_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/config_map_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acceptance_required"></a> [acceptance\_required](#input\_acceptance\_required) | Whether or not VPC endpoint connection requests to the service must be accepted by the service owner | `bool` | `false` | no |
| <a name="input_allowed_principals"></a> [allowed\_principals](#input\_allowed\_principals) | List of AWS principal ARNs allowed to discover and connect to the endpoint service. Use ['*'] to allow all principals | `list(string)` | `[]` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Whether to create the namespace if it doesn't exist | `bool` | `true` | no |
| <a name="input_default_mpc_ports"></a> [default\_mpc\_ports](#input\_default\_mpc\_ports) | Default port configurations for MPC services. These can be overridden per service in mpc\_services configuration. | <pre>object({<br/>    grpc = object({<br/>      name        = string<br/>      port        = number<br/>      target_port = any<br/>      protocol    = string<br/>    })<br/>    peer = object({<br/>      name        = string<br/>      port        = number<br/>      target_port = any<br/>      protocol    = string<br/>    })<br/>    metrics = object({<br/>      name        = string<br/>      port        = number<br/>      target_port = any<br/>      protocol    = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "grpc": {<br/>    "name": "grpc",<br/>    "port": 50100,<br/>    "protocol": "TCP",<br/>    "target_port": 50100<br/>  },<br/>  "metrics": {<br/>    "name": "metrics",<br/>    "port": 9646,<br/>    "protocol": "TCP",<br/>    "target_port": 9646<br/>  },<br/>  "peer": {<br/>    "name": "peer",<br/>    "port": 50001,<br/>    "protocol": "TCP",<br/>    "target_port": 50001<br/>  }<br/>}</pre> | no |
| <a name="input_enable_grpc_port"></a> [enable\_grpc\_port](#input\_enable\_grpc\_port) | Whether to enable and expose the gRPC port in the load balancer service | `bool` | `true` | no |
| <a name="input_enable_region_validation"></a> [enable\_region\_validation](#input\_enable\_region\_validation) | Whether to enable region validation | `bool` | `true` | no |
| <a name="input_kubernetes_nlb_extra_labels"></a> [kubernetes\_nlb\_extra\_labels](#input\_kubernetes\_nlb\_extra\_labels) | Extra labels to add to the Kubernetes NLB | `map(string)` | `{}` | no |
| <a name="input_mainnet_supported_regions"></a> [mainnet\_supported\_regions](#input\_mainnet\_supported\_regions) | AWS regions supported by the VPC endpoint service for mainnet | `list(string)` | <pre>[<br/>  "eu-west-1"<br/>]</pre> | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace where MPC services will be deployed | `string` | `"kms-decentralized"` | no |
| <a name="input_network_environment"></a> [network\_environment](#input\_network\_environment) | MPC network environment that determines region constraints | `string` | `"testnet"` | no |
| <a name="input_partner_name"></a> [partner\_name](#input\_partner\_name) | Partner name for the MPC service | `string` | n/a | yes |
| <a name="input_party_id"></a> [party\_id](#input\_party\_id) | Party ID for the MPC service | `string` | n/a | yes |
| <a name="input_service_create_timeout"></a> [service\_create\_timeout](#input\_service\_create\_timeout) | Timeout for creating Kubernetes services | `string` | `"10m"` | no |
| <a name="input_supported_regions"></a> [supported\_regions](#input\_supported\_regions) | List of AWS regions supported by the VPC endpoint service | `list(string)` | `[]` | no |
| <a name="input_sync_public_bucket"></a> [sync\_public\_bucket](#input\_sync\_public\_bucket) | Sync public bucket between partners | <pre>object({<br/>    enabled        = optional(bool, true)<br/>    configmap_name = optional(string, "mpc-party")<br/>  })</pre> | <pre>{<br/>  "configmap_name": "mpc-party",<br/>  "enabled": true<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the VPC endpoint services | `map(string)` | `{}` | no |
| <a name="input_testnet_supported_regions"></a> [testnet\_supported\_regions](#input\_testnet\_supported\_regions) | AWS regions supported by the VPC endpoint service for testnet | `list(string)` | <pre>[<br/>  "eu-west-1"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configuration_for_consumer"></a> [configuration\_for\_consumer](#output\_configuration\_for\_consumer) | Configuration for the consumer to use the VPC endpoint service |
| <a name="output_nlb_details"></a> [nlb\_details](#output\_nlb\_details) | Detailed information about the looked up NLBs |
| <a name="output_service_details"></a> [service\_details](#output\_service\_details) | Detailed information about the created VPC endpoint services |
| <a name="output_vpc_endpoint_service_arn"></a> [vpc\_endpoint\_service\_arn](#output\_vpc\_endpoint\_service\_arn) | ARNs of the created VPC endpoint services |
| <a name="output_vpc_endpoint_service_id"></a> [vpc\_endpoint\_service\_id](#output\_vpc\_endpoint\_service\_id) | IDs of the created VPC endpoint services |
| <a name="output_vpc_endpoint_service_name"></a> [vpc\_endpoint\_service\_name](#output\_vpc\_endpoint\_service\_name) | Service names of the created VPC endpoint services (what consumers use to connect) |
<!-- END_TF_DOCS -->
