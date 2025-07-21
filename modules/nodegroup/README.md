# EKS Node Group Module

This Terraform module creates an AWS EKS Managed Node Group for Elastic Kubernetes Service.

## Features

- **Full EKS Managed Node Group support** - Creates and manages EKS worker nodes
- **Flexible instance configuration** - Support for various instance types, capacity types (ON_DEMAND, SPOT)
- **Auto Scaling** - Configurable min, max, and desired size
- **Security** - Configurable security groups and remote access
- **Labels and Taints** - Support for Kubernetes labels and taints
- **Launch Template** - Optional custom launch template or use module-managed template

## Module Modes

This module supports two distinct operating modes:

### 1. **Standard Mode (Default)** - No Launch Template
- Uses standard EKS managed node group functionality
- Simpler configuration with common options
- AWS manages the underlying launch template automatically
- Best for most common use cases
- Default behavior when `create_launch_template = false` (default)

### 2. **Advanced Mode** - Custom Launch Template
- Full control over EC2 launch template configuration
- Support for custom AMIs, advanced networking, custom user data
- More configuration options but more complex
- Required for advanced customizations
- Enabled by setting `create_launch_template = true` or providing `launch_template_id`

**💡 Tip**: Start with Standard Mode for basic node groups, then move to Advanced Mode only when you need custom AMIs, advanced networking, or specific user data configurations.

## Usage

### Basic Node Group (Default Mode - No Launch Template)

```hcl
module "basic_nodegroup" {
  source = "./modules/nodegroup"

  # Required variables
  name                              = "basic-nodegroup"
  cluster_name                      = "my-eks-cluster"
  subnet_ids                        = ["subnet-12345", "subnet-67890"]
  cluster_primary_security_group_id = "sg-12345678"

  # Optional scaling configuration
  min_size     = 1
  max_size     = 5
  desired_size = 2

  # Standard EKS managed node group configuration
  instance_types = ["t3.medium", "t3.large"]
  capacity_type  = "ON_DEMAND"
  ami_type       = "AL2_x86_64"
  disk_size      = 20

  # Optional Kubernetes version (defaults to cluster version)
  kubernetes_version = ["1.28"]

  # Optional SSH access
  enable_remote_access = true
  ec2_ssh_key         = "my-keypair"

  # Optional labels and taints
  labels = {
    Environment = "production"
    Team        = "platform"
  }

  taints = {
    dedicated = {
      key    = "dedicated"
      value  = "critical"
      effect = "NO_SCHEDULE"
    }
  }

  # Optional tags
  tags = {
    Terraform   = "true"
    Environment = "production"
  }
}
```

### Advanced Node Group (With Custom Launch Template)

```hcl
module "custom_nodegroup" {
  source = "./modules/nodegroup"

  # Required variables
  name                              = "custom-nodegroup"
  cluster_name                      = "my-eks-cluster"
  subnet_ids                        = ["subnet-12345", "subnet-67890"]
  cluster_primary_security_group_id = "sg-12345678"

  # Enable custom launch template
  create_launch_template = true

  # Custom instance configuration
  instance_type = "t3.large"
  image_id      = "ami-custom123"
  key_name      = "my-keypair"

  # Custom block device mappings
  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      ebs = {
        volume_size = 50
        volume_type = "gp3"
        encrypted   = true
      }
    }
  ]

  # Custom user data
  pre_bootstrap_user_data = <<-EOT
    #!/bin/bash
    yum install -y htop
  EOT

  # Scaling configuration
  min_size     = 1
  max_size     = 5
  desired_size = 2

  # Optional tags
  tags = {
    Terraform   = "true"
    Environment = "production"
  }
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the EKS managed node group | `string` | n/a | yes |
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| subnet_ids | List of subnet IDs where the node group will be placed | `list(string)` | n/a | yes |
| cluster_primary_security_group_id | The ID of the EKS cluster primary security group | `string` | n/a | yes |
| vpc_security_group_ids | List of security group IDs to associate with the node group | `list(string)` | `[]` | no |
| min_size | Minimum number of instances in the node group | `number` | `1` | no |
| max_size | Maximum number of instances in the node group | `number` | `10` | no |
| desired_size | Desired number of instances in the node group | `number` | `1` | no |
| instance_types | List of instance types for the node group | `list(string)` | `["t3.large"]` | no |
| capacity_type | Type of capacity associated with the EKS Node Group (ON_DEMAND/SPOT) | `string` | `"ON_DEMAND"` | no |
| kubernetes_version | Kubernetes version for the node group | `list(string)` | `[]` | no |

See `variables.tf` for a complete list of all available variables.

## Outputs

| Name | Description |
|------|-------------|
| node_group_arn | Amazon Resource Name (ARN) of the EKS Node Group |
| node_group_id | EKS Node Group name |
| node_group_status | Status of the EKS Node Group |
| launch_template_id | The ID of the launch template |
| asg_name | Name of the autoscaling group |
| security_group_id | ID of the worker node shared security group |
| iam_role_arn | The Amazon Resource Name (ARN) specifying the IAM role |

See `outputs.tf` for a complete list of all available outputs.

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- An existing EKS cluster

## Dependencies

This module uses the official terraform-aws-modules/eks/aws//modules/eks-managed-node-group module.

## Examples

### Basic Node Group (Standard EKS Managed Node Group)

```hcl
module "basic_nodegroup" {
  source = "./modules/nodegroup"

  name                              = "basic-workers"
  cluster_name                      = module.eks_cluster.cluster_name
  subnet_ids                        = module.vpc.private_subnet_ids
  cluster_primary_security_group_id = module.eks_cluster.cluster_primary_security_group_id
  
  # Standard configuration without launch template
  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"
  ami_type       = "AL2_x86_64"
  disk_size      = 20
  
  min_size     = 1
  max_size     = 3
  desired_size = 2
}
```

### Spot Instance Node Group

```hcl
module "spot_nodegroup" {
  source = "./modules/nodegroup"

  name                              = "spot-workers"
  cluster_name                      = module.eks_cluster.cluster_name
  subnet_ids                        = module.vpc.private_subnet_ids
  cluster_primary_security_group_id = module.eks_cluster.cluster_primary_security_group_id
  
  capacity_type = "SPOT"
  min_size      = 0
  max_size      = 20
  desired_size  = 3
  
  instance_types = ["t3.medium", "t3.large", "t3.xlarge"]
}
```

### GPU Node Group

```hcl
module "gpu_nodegroup" {
  source = "./modules/nodegroup"

  name                              = "gpu-workers"
  cluster_name                      = module.eks_cluster.cluster_name
  subnet_ids                        = module.vpc.private_subnet_ids
  cluster_primary_security_group_id = module.eks_cluster.cluster_primary_security_group_id
  
  ami_type       = "AL2_x86_64_GPU"
  instance_types = ["g4dn.xlarge"]
  
  labels = {
    "node-type" = "gpu"
  }
  
  taints = {
    gpu = {
      key    = "nvidia.com/gpu"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  }
}
```

## Launch Template Support

This module supports creating and using custom launch templates for advanced node group customization. This enables features like custom AMIs, security groups, user data, and block device mappings.

### Using Module-Created Launch Template

```hcl
module "custom_nodegroup" {
  source = "./modules/nodegroup"

  name                              = "custom-workers"
  cluster_name                      = module.eks_cluster.cluster_name
  subnet_ids                        = module.vpc.private_subnet_ids
  cluster_primary_security_group_id = module.eks_cluster.cluster_primary_security_group_id
  
  # Enable launch template creation
  create_launch_template = true
  
  # Instance configuration
  instance_type = "t3.large"
  image_id      = "ami-12345678"  # Custom AMI
  key_name      = "my-key-pair"
  
  # Security groups (will be combined with cluster security group)
  security_group_ids = [aws_security_group.custom.id]
  
  # Custom block device mappings
  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 50
        volume_type           = "gp3"
        iops                  = 3000
        throughput            = 150
        encrypted             = true
        delete_on_termination = true
      }
    }
  ]
  
  # Custom user data
  pre_bootstrap_user_data = <<-EOT
    #!/bin/bash
    # Install additional packages
    yum install -y htop
  EOT
  
  post_bootstrap_user_data = <<-EOT
    # Configure custom settings
    echo "Node setup complete"
  EOT
  
  bootstrap_extra_args = "--kubelet-extra-args '--max-pods=110'"
}
```

### Using External Launch Template

```hcl
resource "aws_launch_template" "custom" {
  name_prefix   = "custom-nodegroup-"
  image_id      = "ami-12345678"
  instance_type = "t3.large"
  key_name      = "my-key-pair"
  
  vpc_security_group_ids = [
    module.eks_cluster.cluster_primary_security_group_id,
    aws_security_group.custom.id
  ]
  
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      volume_type = "gp3"
      encrypted   = true
    }
  }
  
  user_data = base64encode(templatefile("custom-userdata.sh", {
    cluster_name = module.eks_cluster.cluster_name
  }))
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "custom-worker"
    }
  }
}

module "external_lt_nodegroup" {
  source = "./modules/nodegroup"

  name                              = "external-lt-workers"
  cluster_name                      = module.eks_cluster.cluster_name
  subnet_ids                        = module.vpc.private_subnet_ids
  cluster_primary_security_group_id = module.eks_cluster.cluster_primary_security_group_id
  
  # Use external launch template
  create_launch_template   = false
  launch_template_id       = aws_launch_template.custom.id
  launch_template_version  = "$Latest"
}
```

### Advanced Launch Template Configuration

```hcl
module "advanced_nodegroup" {
  source = "./modules/nodegroup"

  name                              = "advanced-workers"
  cluster_name                      = module.eks_cluster.cluster_name
  subnet_ids                        = module.vpc.private_subnet_ids
  cluster_primary_security_group_id = module.eks_cluster.cluster_primary_security_group_id
  
  create_launch_template = true
  
  # Instance configuration
  instance_type = "c5.2xlarge"
  image_id      = data.aws_ami.custom.id
  
  # Enhanced networking with custom network interfaces
  network_interfaces = [
    {
      associate_public_ip_address = false
      delete_on_termination       = true
      device_index                = 0
      security_groups             = [aws_security_group.worker_additional.id]
    }
  ]
  
  # CPU optimization
  cpu_options = {
    core_count       = 4
    threads_per_core = 1
  }
  
  # Enhanced monitoring
  monitoring = {
    enabled = true
  }
  
  # Placement configuration
  placement = {
    tenancy = "default"
  }
  
  # Instance metadata configuration
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }
  
  # Tag specifications for created resources
  tag_specifications = [
    {
      resource_type = "instance"
      tags = {
        Environment = "production"
        Owner       = "platform-team"
      }
    },
    {
      resource_type = "volume"
      tags = {
        Environment = "production"
        Backup      = "required"
      }
    }
  ]
}
```

## Launch Template Variables

### Core Launch Template Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_launch_template | Whether to create a launch template for the node group | `bool` | `true` | no |
| launch_template_id | ID of an existing launch template to use | `string` | `null` | no |
| launch_template_version | Launch template version to use | `string` | `null` | no |
| launch_template_name | Name of the launch template | `string` | `null` | no |
| launch_template_description | Description of the launch template | `string` | `"Launch template for EKS managed node group"` | no |

### Instance Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| image_id | AMI ID for the launch template | `string` | `null` | no |
| instance_type | Instance type for the launch template | `string` | `null` | no |
| key_name | Key pair name for SSH access to instances | `string` | `null` | no |
| security_group_ids | List of security group IDs to associate with instances | `list(string)` | `[]` | no |

### Block Device Mappings

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| block_device_mappings | Block device mappings for the launch template | `list(object)` | See variables.tf | no |

### User Data Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| user_data_base64 | Base64-encoded user data for the launch template | `string` | `null` | no |
| enable_bootstrap_user_data | Whether to enable default EKS bootstrap user data | `bool` | `true` | no |
| pre_bootstrap_user_data | User data commands to run before EKS bootstrap script | `string` | `""` | no |
| post_bootstrap_user_data | User data commands to run after EKS bootstrap script | `string` | `""` | no |
| bootstrap_extra_args | Additional arguments to pass to the EKS bootstrap script | `string` | `""` | no |

### Advanced Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| metadata_options | Instance metadata options for the launch template | `object` | See variables.tf | no |
| cpu_options | CPU options for the launch template | `object` | `null` | no |
| credit_specification | Credit specification for burstable performance instances | `object` | `null` | no |
| network_interfaces | Network interfaces for the launch template | `list(object)` | `[]` | no |
| monitoring | Monitoring configuration for instances | `object` | `{enabled = true}` | no |
| placement | Placement configuration for instances | `object` | `null` | no |
| tag_specifications | Tag specifications for resources created by the launch template | `list(object)` | `[]` | no |

## Launch Template Outputs

| Name | Description |
|------|-------------|
| launch_template_id | The ID of the launch template created by this module |
| launch_template_arn | The ARN of the launch template created by this module |
| launch_template_name | The name of the launch template created by this module |
| launch_template_latest_version | The latest version of the launch template |
| launch_template_default_version | The default version of the launch template |
| use_launch_template | Whether the node group is using a launch template |
| effective_launch_template_id | The actual launch template ID being used |
| effective_launch_template_version | The actual launch template version being used |

## Important Notes

### Launch Template Best Practices

1. **Security Groups**: When using custom launch templates, always include the cluster's primary security group along with any custom security groups to ensure proper node-to-cluster communication.

2. **User Data**: The module provides automatic EKS bootstrap user data generation. For custom AMIs, you may need to provide your own bootstrap logic.

3. **Instance Types**: When using launch templates, specify `instance_type` in the launch template rather than `instance_types` in the node group configuration.

4. **Versioning**: Use launch template versioning for zero-downtime updates. The module automatically uses the latest version when creating templates.

5. **Network Interfaces vs Security Groups**: You can either specify security groups directly or use network interface configurations, but not both.

### Compatibility

- Launch templates are compatible with all EKS node group features including labels, taints, and scaling policies
- When using custom launch templates, some node group settings (like `ami_type`, `disk_size`) are ignored in favor of launch template settings
- Custom AMIs must be compatible with the EKS cluster version and include necessary components for node registration