# VPC Endpoint Provider Module

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_vpc_endpoint_service.mpc_nlb_services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service) | resource |
| [kubernetes_namespace.mpc_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service.mpc_nlb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [null_resource.cleanup_sg_rules](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_lb.kubernetes_nlbs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [external_external.wait_nlb](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acceptance_required"></a> [acceptance\_required](#input\_acceptance\_required) | Whether or not VPC endpoint connection requests to the service must be accepted by the service owner | `bool` | `false` | no |
| <a name="input_allowed_principals"></a> [allowed\_principals](#input\_allowed\_principals) | List of AWS principal ARNs allowed to discover and connect to the endpoint service. Use ['*'] to allow all principals | `list(string)` | `[]` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_cleanup_sg_rules_v1"></a> [cleanup\_sg\_rules\_v1](#input\_cleanup\_sg\_rules\_v1) | Whether to cleanup security group rules for NLBs made by the native aws load balancer controller v1 | `bool` | `false` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Whether to create the namespace if it doesn't exist | `bool` | `true` | no |
| <a name="input_default_mpc_ports"></a> [default\_mpc\_ports](#input\_default\_mpc\_ports) | Default port configurations for MPC services. These can be overridden per service in mpc\_services configuration. | <pre>object({<br/>    grpc = object({<br/>      name        = string<br/>      port        = number<br/>      target_port = any<br/>      protocol    = string<br/>    })<br/>    peer = object({<br/>      name        = string<br/>      port        = number<br/>      target_port = any<br/>      protocol    = string<br/>    })<br/>    metrics = object({<br/>      name        = string<br/>      port        = number<br/>      target_port = any<br/>      protocol    = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "grpc": {<br/>    "name": "grpc",<br/>    "port": 50100,<br/>    "protocol": "TCP",<br/>    "target_port": 50100<br/>  },<br/>  "metrics": {<br/>    "name": "metrics",<br/>    "port": 9646,<br/>    "protocol": "TCP",<br/>    "target_port": 9646<br/>  },<br/>  "peer": {<br/>    "name": "peer",<br/>    "port": 50001,<br/>    "protocol": "TCP",<br/>    "target_port": 50001<br/>  }<br/>}</pre> | no |
| <a name="input_load_balancer_controller_version"></a> [load\_balancer\_controller\_version](#input\_load\_balancer\_controller\_version) | Version of the load balancer controller to use | `string` | `"v2"` | no |
| <a name="input_mpc_services"></a> [mpc\_services](#input\_mpc\_services) | List of MPC services to create with their configurations | <pre>list(object({<br/>    name = string<br/>    display_nlb_name = optional(string, null)<br/>    ports = optional(list(object({<br/>      name        = string<br/>      port        = number<br/>      target_port = any<br/>      protocol    = string<br/>      node_port   = optional(number)<br/>    })), null)<br/>    selector                    = map(string)<br/>    additional_annotations      = optional(map(string), {})<br/>    labels                      = optional(map(string), {})<br/>    session_affinity            = optional(string, "None")<br/>    external_traffic_policy     = optional(string, "Cluster")<br/>    internal_traffic_policy     = optional(string, "Cluster")<br/>    load_balancer_source_ranges = optional(list(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace where MPC services will be deployed | `string` | `"mpc-cluster"` | no |
| <a name="input_service_create_timeout"></a> [service\_create\_timeout](#input\_service\_create\_timeout) | Timeout for creating Kubernetes services | `string` | `"10m"` | no |
| <a name="input_supported_regions"></a> [supported\_regions](#input\_supported\_regions) | List of AWS regions supported by the VPC endpoint service | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the VPC endpoint services | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nlb_details"></a> [nlb\_details](#output\_nlb\_details) | Detailed information about the looked up NLBs |
| <a name="output_service_details"></a> [service\_details](#output\_service\_details) | Detailed information about the created VPC endpoint services |
| <a name="output_vpc_endpoint_service_arns"></a> [vpc\_endpoint\_service\_arns](#output\_vpc\_endpoint\_service\_arns) | ARNs of the created VPC endpoint services |
| <a name="output_vpc_endpoint_service_ids"></a> [vpc\_endpoint\_service\_ids](#output\_vpc\_endpoint\_service\_ids) | IDs of the created VPC endpoint services |
| <a name="output_vpc_endpoint_service_names"></a> [vpc\_endpoint\_service\_names](#output\_vpc\_endpoint\_service\_names) | Service names of the created VPC endpoint services (what consumers use to connect) |
<!-- END_TF_DOCS -->
