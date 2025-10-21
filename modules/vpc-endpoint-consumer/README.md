# VPC Endpoint Consumer Module

This module creates VPC interface endpoints to connect to partner MPC services and optionally creates Kubernetes services for easy consumption within an EKS cluster.

## Features

- **VPC Interface Endpoints**: Create VPC endpoints to privately connect to partner services
- **Kubernetes Service Integration**: Automatically create Kubernetes ExternalName services pointing to VPC endpoints
- **Security Group Management**: Option to create a security group with default ingress rules or use existing security groups
- **Custom DNS**: Optional Route53 private hosted zone records for custom DNS names
- **S3 Bucket Sync**: Sync public buckets between partners for data exchange

## Usage

### Basic Usage with Auto-Created Security Group

```terraform
module "vpc_endpoint_consumer" {
  source = "./modules/vpc-endpoint-consumer"

  cluster_name = "my-eks-cluster"

  # Create a security group with default ingress rules
  create_security_group = true
  security_group_name   = "mpc-vpc-endpoint-sg"

  # Default ingress rules allow traffic on gRPC (50100), peer (50001), and metrics (9646) ports
  # You can customize these rules using security_group_ingress_rules variable

  party_services = [
    {
      name                      = "partner-kms-core"
      region                    = "us-east-1"
      party_id                  = "partner1"
      vpc_endpoint_service_name = "com.amazonaws.vpce.us-east-1.vpce-svc-xxxxx"
    }
  ]
}
```

### Using Existing Security Groups

```terraform
module "vpc_endpoint_consumer" {
  source = "./modules/vpc-endpoint-consumer"

  vpc_id             = "vpc-xxxxx"
  subnet_ids         = ["subnet-xxxxx", "subnet-yyyyy"]
  security_group_ids = ["sg-xxxxx"]

  # Don't create a new security group (default behavior)
  create_security_group = false

  party_services = [
    {
      name                      = "partner-kms-core"
      region                    = "us-east-1"
      party_id                  = "partner1"
      vpc_endpoint_service_name = "com.amazonaws.vpce.us-east-1.vpce-svc-xxxxx"
    }
  ]
}
```

## Security Group Configuration

When `create_security_group = true`, the module automatically creates ingress rules based on the `default_mpc_ports` configuration:

- **gRPC Port (50100)**: Created only if `enable_grpc_port = true` (default)
- **Peer Port (50001)**: Always created
- **Metrics Port (9646)**: Always created

The module automatically adds a default egress rule that allows all outbound traffic (0.0.0.0/0).

### Customizing Ingress Rules

You can customize who can access the VPC endpoints using:

- **`security_group_ingress_cidr_blocks`**: List of CIDR blocks to allow (default: `["0.0.0.0/0"]`)
- **`security_group_ingress_source_sg_id`**: Source security group ID (takes precedence over CIDR blocks)

The ports used for ingress rules are automatically derived from `default_mpc_ports`, ensuring consistency between your Kubernetes services and security group rules.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.23 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.23 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.partner_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.party_interface_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_security_group_egress_rule.vpc_endpoint_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
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
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Whether to create a security group for VPC endpoints with default ingress rules | `bool` | `true` | no |
| <a name="input_default_mpc_ports"></a> [default\_mpc\_ports](#input\_default\_mpc\_ports) | Default port configurations for MPC services. These can be overridden per service in party\_services configuration. | <pre>object({<br/>    grpc = object({<br/>      name        = string<br/>      port        = number<br/>      target_port = number<br/>      protocol    = string<br/>    })<br/>    peer = object({<br/>      name        = string<br/>      port        = number<br/>      target_port = number<br/>      protocol    = string<br/>    })<br/>    metrics = object({<br/>      name        = string<br/>      port        = number<br/>      target_port = number<br/>      protocol    = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "grpc": {<br/>    "name": "grpc",<br/>    "port": 50100,<br/>    "protocol": "TCP",<br/>    "target_port": 50100<br/>  },<br/>  "metrics": {<br/>    "name": "metrics",<br/>    "port": 9646,<br/>    "protocol": "TCP",<br/>    "target_port": 9646<br/>  },<br/>  "peer": {<br/>    "name": "peer",<br/>    "port": 50001,<br/>    "protocol": "TCP",<br/>    "target_port": 50001<br/>  }<br/>}</pre> | no |
| <a name="input_dns_domain"></a> [dns\_domain](#input\_dns\_domain) | DNS domain for custom DNS records | `string` | `"mpc-partners.local"` | no |
| <a name="input_enable_grpc_port"></a> [enable\_grpc\_port](#input\_enable\_grpc\_port) | Whether to enable and expose the gRPC port in the load balancer service | `bool` | `true` | no |
| <a name="input_endpoint_create_timeout"></a> [endpoint\_create\_timeout](#input\_endpoint\_create\_timeout) | Timeout for creating VPC interface endpoints | `string` | `"10m"` | no |
| <a name="input_endpoint_delete_timeout"></a> [endpoint\_delete\_timeout](#input\_endpoint\_delete\_timeout) | Timeout for deleting VPC interface endpoints | `string` | `"10m"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for naming VPC interface endpoint resources | `string` | `"mpc-partner"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace where partner services will be created | `string` | `"kms-decentralized"` | no |
| <a name="input_party_services"></a> [party\_services](#input\_party\_services) | List of partner MPC services to connect to via VPC interface endpoints | <pre>list(object({<br/>    name                      = string<br/>    region                    = string<br/>    party_id                  = string<br/>    account_id                = optional(string, null)<br/>    partner_name              = optional(string, null)<br/>    vpc_endpoint_service_name = string<br/>    enable_consumer_sync      = optional(bool, true)<br/>    public_bucket_url         = optional(string, null)<br/>    ports = optional(list(object({<br/>      name        = string<br/>      port        = number<br/>      target_port = number<br/>      protocol    = string<br/>    })), null)<br/>    availability_zones  = optional(list(string), null)<br/>    create_kube_service = optional(bool, true)<br/>    kube_service_config = optional(object({<br/>      additional_annotations = optional(map(string), {})<br/>      labels                 = optional(map(string), {})<br/>      session_affinity       = optional(string, "None")<br/>    }), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_private_dns_enabled"></a> [private\_dns\_enabled](#input\_private\_dns\_enabled) | Whether to enable private DNS for the VPC interface endpoints | `bool` | `false` | no |
| <a name="input_private_zone_id"></a> [private\_zone\_id](#input\_private\_zone\_id) | Route53 private hosted zone ID for custom DNS records | `string` | `""` | no |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids) | List of route table IDs to associate with the VPC interface endpoints | `list(string)` | `[]` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description for the security group | `string` | `"Security group for MPC VPC endpoint consumer"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to associate with the VPC interface endpoints (Mode 2). Required if cluster\_name is not provided and create\_security\_group is false. | `list(string)` | `null` | no |
| <a name="input_security_group_ingress_cidr_blocks"></a> [security\_group\_ingress\_cidr\_blocks](#input\_security\_group\_ingress\_cidr\_blocks) | CIDR blocks to allow ingress traffic from for MPC ports (when create\_security\_group is true) | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_security_group_ingress_source_sg_id"></a> [security\_group\_ingress\_source\_sg\_id](#input\_security\_group\_ingress\_source\_sg\_id) | Source security group ID to allow ingress traffic from for MPC ports (when create\_security\_group is true). If set, this takes precedence over cidr\_blocks. | `string` | `null` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name of the security group to create (if create\_security\_group is true) | `string` | `"mpc-vpc-endpoint-consumer-sg"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs where the VPC interface endpoints will be created (Mode 2). Required if cluster\_name is not provided. | `list(string)` | `null` | no |
| <a name="input_sync_public_bucket"></a> [sync\_public\_bucket](#input\_sync\_public\_bucket) | Sync public bucket between partners | <pre>object({<br/>    enabled        = optional(bool, true)<br/>    configmap_name = optional(string, "mpc-party")<br/>  })</pre> | <pre>{<br/>  "configmap_name": "mpc-party",<br/>  "enabled": true<br/>}</pre> | no |
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
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | ARN of the created security group (if create\_security\_group is true) |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the created security group (if create\_security\_group is true) |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | Name of the created security group (if create\_security\_group is true) |
| <a name="output_vpc_interface_endpoint_dns_names"></a> [vpc\_interface\_endpoint\_dns\_names](#output\_vpc\_interface\_endpoint\_dns\_names) | DNS names of the created VPC interface endpoints |
| <a name="output_vpc_interface_endpoint_hosted_zone_ids"></a> [vpc\_interface\_endpoint\_hosted\_zone\_ids](#output\_vpc\_interface\_endpoint\_hosted\_zone\_ids) | Hosted zone IDs of the created VPC interface endpoints |
| <a name="output_vpc_interface_endpoint_ids"></a> [vpc\_interface\_endpoint\_ids](#output\_vpc\_interface\_endpoint\_ids) | IDs of the created VPC interface endpoints |
| <a name="output_vpc_interface_endpoint_service_names"></a> [vpc\_interface\_endpoint\_service\_names](#output\_vpc\_interface\_endpoint\_service\_names) | Service names of the created VPC interface endpoints |
<!-- END_TF_DOCS -->
