# ***************************************
#  Data sources
# ***************************************
data "aws_caller_identity" "current" {}

data "aws_region" "current" {
  lifecycle {
    postcondition {
      condition     = var.enable_region_validation ? contains(local.allowed_regions, self.region) : true
      error_message = "This module supports only ${join(", ", local.allowed_regions)} (got: ${self.region})."
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
  lifecycle {
    postcondition {
      condition     = strcontains(var.nodegroup_ami_release_version, self.version)
      error_message = "The EKS cluster version is not supported. Please use the recommended version that will be supported by the enclavenode group."
    }
  }
}

data "aws_subnet" "cluster_subnets" {
  for_each = toset(data.aws_eks_cluster.cluster.vpc_config[0].subnet_ids)
  id       = each.value
}

# ***************************************
#  Local variables
# ***************************************

resource "random_id" "mpc_party_suffix" {
  byte_length = 4
}

locals {
  allowed_regions = var.network_environment == "testnet" ? var.testnet_supported_regions : var.mainnet_supported_regions
  private_subnet_ids = [
    for subnet_id, subnet in data.aws_subnet.cluster_subnets : subnet_id
    if subnet.map_public_ip_on_launch == false
  ]
  private_subnet_cidr_blocks = [
    for subnet_id, subnet in data.aws_subnet.cluster_subnets : subnet.cidr_block
    if subnet.map_public_ip_on_launch == false
  ]
  node_group_nitro_enclaves_enabled    = var.kms_enabled_nitro_enclaves && var.nodegroup_enable_nitro_enclaves
  node_group_nitro_enclaves_cpu_count  = var.nitro_enclaves_override_cpu_count != null ? var.nitro_enclaves_override_cpu_count : floor(data.aws_ec2_instance_type.this[0].default_vcpus * 0.75)
  node_group_nitro_enclaves_memory_mib = var.nitro_enclaves_override_memory_mib != null ? var.nitro_enclaves_override_memory_mib : floor(data.aws_ec2_instance_type.this[0].memory_size * 0.75)
  private_bucket_name                  = "${var.bucket_prefix}-private-${random_id.mpc_party_suffix.hex}"
  public_bucket_name                   = "${var.bucket_prefix}-public-${random_id.mpc_party_suffix.hex}"

  # Transform EKS node group taints into Kubernetes tolerations
  node_group_tolerations = var.create_nodegroup ? [
    for taint_key, taint_config in module.eks_managed_node_group[0].node_group_taints : {
      key      = taint_config.key
      operator = "Equal"
      value    = taint_config.value
      effect   = taint_config.effect == "NO_SCHEDULE" ? "NoSchedule" : taint_config.effect == "NO_EXECUTE" ? "NoExecute" : "PreferNoSchedule"
    }
  ] : []
}

# Create Kubernetes namespace (optional)
resource "kubernetes_namespace" "mpc_party_namespace" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.k8s_namespace

    labels = merge({
      "app.kubernetes.io/name"       = "mpc-party"
      "app.kubernetes.io/component"  = "storage"
      "app.kubernetes.io/part-of"    = "mpc-cluster"
      "app.kubernetes.io/managed-by" = "terraform"
      "mpc.io/party-name"            = var.party_name
    }, var.namespace_labels)

    annotations = merge({
      "terraform.io/module" = "mpc-party"
      "mpc.io/party-name"   = var.party_name
      "mpc.io/cluster"      = var.cluster_name
    }, var.namespace_annotations)
  }
}

# ***************************************
#  S3 Buckets for Vault Public Storage
# ***************************************
resource "aws_s3_bucket" "vault_public_bucket" {
  bucket        = local.public_bucket_name
  force_destroy = true
  tags = merge(var.common_tags, {
    "Name"    = local.public_bucket_name
    "Type"    = "public-vault"
    "Party"   = var.party_name
    "Purpose" = "mpc-public-storage"
  })
}

resource "aws_s3_bucket_ownership_controls" "vault_public_bucket" {
  bucket = aws_s3_bucket.vault_public_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "vault_public_bucket" {
  bucket = aws_s3_bucket.vault_public_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "vault_public_bucket" {
  bucket = aws_s3_bucket.vault_public_bucket.id

  block_public_policy     = false
  restrict_public_buckets = false
  block_public_acls       = false
  ignore_public_acls      = false
}

resource "aws_s3_bucket_cors_configuration" "vault_public_bucket_cors" {
  bucket = aws_s3_bucket.vault_public_bucket.id

  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["Access-Control-Allow-Origin"]
  }
}

resource "aws_s3_bucket_policy" "vault_public_bucket_policy" {
  bucket = aws_s3_bucket.vault_public_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.vault_public_bucket.id}/*"
      },
      {
        Sid       = "ZamaList"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:ListBucket"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.vault_public_bucket.id}"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.vault_public_bucket]
}

# ***************************************
#  S3 Buckets for Vault Private Storage
# ***************************************
resource "aws_s3_bucket" "vault_private_bucket" {
  force_destroy = true
  bucket        = local.private_bucket_name
  tags = merge(var.common_tags, {
    "Name"    = local.private_bucket_name
    "Type"    = "private-vault"
    "Party"   = var.party_name
    "Purpose" = "mpc-private-storage"
  })
}

resource "aws_s3_bucket_ownership_controls" "vault_private_bucket" {
  bucket = aws_s3_bucket.vault_private_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "vault_private_bucket" {
  bucket = aws_s3_bucket.vault_private_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "vault_private_bucket" {
  bucket                  = aws_s3_bucket.vault_private_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ***************************************
#  IAM Policy for MPC Party
# ***************************************
resource "aws_iam_policy" "mpc_aws" {
  name = "mpc-${var.cluster_name}-${var.party_name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowObjectActions"
        Effect = "Allow"
        Action = "s3:*Object"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.vault_private_bucket.id}/*",
          "arn:aws:s3:::${aws_s3_bucket.vault_public_bucket.id}/*"
        ]
      },
      {
        Sid    = "AllowListBucket"
        Effect = "Allow"
        Action = "s3:ListBucket"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.vault_private_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.vault_public_bucket.id}"
        ]
      }
    ]
  })
}

module "iam_assumable_role_mpc_party" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.48.0"
  provider_url                  = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  create_role                   = true
  role_name                     = "mpc-${var.cluster_name}-${var.party_name}"
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}"]
  role_policy_arns              = [aws_iam_policy.mpc_aws.arn]
  depends_on                    = [aws_s3_bucket.vault_private_bucket, aws_s3_bucket.vault_public_bucket, kubernetes_namespace.mpc_party_namespace]
}

resource "kubernetes_service_account" "mpc_party_service_account" {
  count = var.create_service_account ? 1 : 0
  metadata {
    name      = var.k8s_service_account_name
    namespace = var.k8s_namespace

    labels = merge({
      "app.kubernetes.io/name"       = "mpc-party"
      "app.kubernetes.io/component"  = "service-account"
      "app.kubernetes.io/part-of"    = "mpc-cluster"
      "app.kubernetes.io/managed-by" = "terraform"
      "mpc.io/party-name"            = var.party_name
    }, var.service_account_labels)

    annotations = merge({
      "terraform.io/module"        = "mpc-party"
      "mpc.io/party-name"          = var.party_name
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_mpc_party.iam_role_arn
    }, var.service_account_annotations)
  }
  depends_on = [kubernetes_namespace.mpc_party_namespace, module.iam_assumable_role_mpc_party]
}

# ***************************************
#  aws kms key for mpc party
# ***************************************
resource "aws_kms_key" "mpc_party" {
  count                    = var.kms_enabled_nitro_enclaves ? 1 : 0
  description              = "KMS key for MPC Party"
  key_usage                = var.kms_key_usage
  customer_master_key_spec = var.kms_customer_master_key_spec
  enable_key_rotation      = false
  deletion_window_in_days  = var.kms_deletion_window_in_days
  tags                     = var.tags
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${module.iam_assumable_role_mpc_party.iam_role_name}"
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:GetPublicKey"
        ],
        Resource = "*",
        Condition = {
          StringEqualsIgnoreCase = {
            "kms:RecipientAttestation:ImageSha384" : var.kms_image_attestation_sha
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "mpc_party" {
  count         = var.kms_enabled_nitro_enclaves ? 1 : 0
  name          = "alias/mpc-${var.party_name}"
  target_key_id = aws_kms_key.mpc_party[0].key_id
}

# ***************************************
#  ConfigMap for MPC Party
# ***************************************
resource "kubernetes_config_map" "mpc_party_config" {
  count = var.create_config_map ? 1 : 0

  metadata {
    name      = var.config_map_name != null ? var.config_map_name : "mpc-party-config-${var.party_name}"
    namespace = var.k8s_namespace

    labels = {
      "app.kubernetes.io/name"       = "mpc-party"
      "app.kubernetes.io/component"  = "config"
      "app.kubernetes.io/part-of"    = "mpc-cluster"
      "app.kubernetes.io/managed-by" = "terraform"
      "mpc.io/party-name"            = var.party_name
    }

    annotations = {
      "terraform.io/module" = "mpc-party"
      "mpc.io/party-name"   = var.party_name
    }
  }

  data = {
    "CORE_CLIENT__S3_ENDPOINT"                                  = "https://${aws_s3_bucket.vault_public_bucket.id}.s3.${aws_s3_bucket.vault_public_bucket.region}.amazonaws.com"
    "KMS_CORE__PRIVATE_VAULT__STORAGE__S3__BUCKET"              = aws_s3_bucket.vault_private_bucket.id
    "KMS_CORE__PRIVATE_VAULT__STORAGE__S3__PREFIX"              = ""
    "KMS_CORE__PUBLIC_VAULT__STORAGE__S3__BUCKET"               = aws_s3_bucket.vault_public_bucket.id
    "KMS_CORE__PUBLIC_VAULT__STORAGE__S3__PREFIX"               = ""
    "KMS_CORE__PRIVATE_VAULT__KEYCHAIN__AWS_KMS__ROOT_KEY_ID"   = var.kms_enabled_nitro_enclaves ? aws_kms_key.mpc_party[0].key_id : null
    "KMS_CORE__PRIVATE_VAULT__KEYCHAIN__AWS_KMS__ROOT_KEY_SPEC" = var.kms_enabled_nitro_enclaves ? "symm" : null
  }

  depends_on = [kubernetes_namespace.mpc_party_namespace, aws_s3_bucket.vault_private_bucket, aws_s3_bucket.vault_public_bucket]
}

# ***************************************
#  EKS Managed Node Group
# ***************************************
module "eks_node_group_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = var.nodegroup_security_group_custom_name
  description = "Security group for EKS nodes"
  vpc_id      = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id

  # typical default
  egress_rules = var.nodegroup_security_group_custom_egress_rules

  # ---- Node-to-node (use self as the source) ----
  # CoreDNS (TCP/UDP 53) + TCP ephemeral range 1025–6553
  ingress_with_self = [
    for sg_rule in var.nodegroup_sg_ingress_with_self :
    { for k, v in sg_rule : k => v if v != null }
  ]

  # ---- From Cluster API SG to nodes ----
  ingress_with_source_security_group_id = [
    for sg_rule in var.nodegroup_sg_ingress_with_source_sg : merge(
      sg_rule.rule != null ? { rule = sg_rule.rule } : {},
      sg_rule.from_port != null ? { from_port = sg_rule.from_port } : {},
      sg_rule.to_port != null ? { to_port = sg_rule.to_port } : {},
      sg_rule.protocol != null ? { protocol = sg_rule.protocol } : {},
      sg_rule.description != null ? { description = sg_rule.description } : {},
      { source_security_group_id = data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id }
    )
  ]

  tags = merge(var.tags, {
    "Name" = var.nodegroup_security_group_custom_name
  })
}

data "aws_ec2_instance_type" "this" {
  instance_type = var.nodegroup_instance_types[0]
  count         = var.nodegroup_enable_nitro_enclaves ? 1 : 0
}

module "eks_managed_node_group" {
  count   = var.create_nodegroup ? 1 : 0
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "21.0.6"

  name         = var.nodegroup_name
  cluster_name = var.cluster_name

  kubernetes_version             = data.aws_eks_cluster.cluster.version
  ami_release_version            = var.nodegroup_ami_release_version
  use_latest_ami_release_version = var.nodegroup_use_latest_ami_release_version

  subnet_ids = local.private_subnet_ids

  cluster_primary_security_group_id = data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
  vpc_security_group_ids            = concat(tolist(data.aws_eks_cluster.cluster.vpc_config[0].security_group_ids), var.nodegroup_additional_security_group_ids, [module.eks_node_group_sg.security_group_id])

  # Scaling Configuration
  min_size     = var.nodegroup_min_size
  max_size     = var.nodegroup_max_size
  desired_size = var.nodegroup_desired_size

  # Instance Configuration (only when not using launch template)
  instance_types = var.nodegroup_instance_types
  capacity_type  = var.nodegroup_capacity_type
  ami_type       = var.nodegroup_ami_type

  # Enclave options for Nitro Enclaves
  enclave_options = local.node_group_nitro_enclaves_enabled ? { enabled = true } : null

  # Metadata options for Nitro Enclaves
  metadata_options = local.node_group_nitro_enclaves_enabled ? {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  } : null

  iam_role_additional_policies = merge({
    AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    },
    var.nodegroup_enable_ssm_managed_instance ? {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" # Disable SSM managed instance for mainnet
    } : {}
  )


  # This script configures and launches the Nitro enclave allocator. The
  # CPU_COUNT and MEMORY_MIB variables indicate the resources available to
  # all enclaves running on the node. A rule of thumb for the kms-core is to
  # allocate 75% of the underlying instance capacity.
  cloudinit_pre_nodeadm = local.node_group_nitro_enclaves_enabled ? [{
    content_type = "text/x-shellscript; charset=\"us-ascii\""
    content      = <<-EOT
        #!/usr/bin/env bash

        # Node resources that will be allocated for Nitro Enclaves
        readonly CPU_COUNT=${local.node_group_nitro_enclaves_cpu_count}
        readonly MEMORY_MIB=${local.node_group_nitro_enclaves_memory_mib}

        readonly NE_ALLOCATOR_SPEC_PATH="/etc/nitro_enclaves/allocator.yaml"

        # This step below is needed to install nitro-enclaves-allocator service.
        dnf install aws-nitro-enclaves-cli -y

        # Update enclave's allocator specification: allocator.yaml
        sed -i "s/cpu_count:.*/cpu_count: $CPU_COUNT/g" $NE_ALLOCATOR_SPEC_PATH
        sed -i "s/memory_mib:.*/memory_mib: $MEMORY_MIB/g" $NE_ALLOCATOR_SPEC_PATH

        # Enable the nitro-enclaves-allocator service on boot
        systemctl enable nitro-enclaves-allocator.service

        # Restart the nitro-enclaves-allocator service to take changes effect.
        systemctl restart nitro-enclaves-allocator.service

        echo "NE user data script has finished successfully."
      EOT
  }] : null

  # Cluster service CIDR for user data
  cluster_service_cidr = data.aws_eks_cluster.cluster.kubernetes_network_config[0].service_ipv4_cidr

  # Disk configuration (only when not using launch template)
  disk_size = var.nodegroup_disk_size

  # Remote Access Configuration (only when not using launch template)
  remote_access = var.nodegroup_enable_remote_access ? {
    ec2_ssh_key               = var.nodegroup_ec2_ssh_key
    source_security_group_ids = var.nodegroup_source_security_group_ids
  } : null

  # Labels
  labels = merge(var.nodegroup_labels, local.node_group_nitro_enclaves_enabled ? {
    "node.kubernetes.io/enclave-enabled" = "true"
  } : {})

  taints = local.node_group_nitro_enclaves_enabled ? {
    "aws-nitro-enclaves" = {
      key    = "node.kubernetes.io/enclave-enabled"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  } : {}

  # Tags
  tags = var.tags
}

# ***************************************
#  Deploy Daemonset AWS Nitro Enclaves
# ***************************************
locals {
  nitro_enclaves_daemonset_additional_envs = merge({
    "ENCLAVE_CPU_ADVERTISEMENT" = "TRUE"
  }, var.nodegroup_nitro_enclaves_daemonset_additional_envs)

}
resource "kubernetes_daemon_set_v1" "aws_nitro_enclaves_device_plugin" {
  count = local.node_group_nitro_enclaves_enabled ? 1 : 0

  metadata {
    name      = "aws-nitro-enclaves-k8s-device-plugin"
    namespace = "kube-system"
    labels = {
      name = "aws-nitro-enclaves"
      role = "agent"
    }
  }

  spec {
    selector {
      match_labels = {
        name = "aws-nitro-enclaves"
      }
    }
    strategy {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          name = "aws-nitro-enclaves"
        }
        annotations = {
          "node.kubernetes.io/bootstrap-checkpoint" = "true"
        }
      }

      spec {
        node_selector = {
          "node.kubernetes.io/enclave-enabled" = "true"
        }

        priority_class_name              = "system-node-critical"
        hostname                         = "aws-nitro-enclaves"
        termination_grace_period_seconds = 30

        container {
          name              = "aws-nitro-enclaves"
          image             = "${var.nodegroup_nitro_enclaves_image_repo}:${var.nodegroup_nitro_enclaves_image_tag}"
          image_pull_policy = "IfNotPresent"

          security_context {
            read_only_root_filesystem  = true
            allow_privilege_escalation = false
            capabilities {
              drop = ["ALL"]
            }
          }

          dynamic "env" {
            for_each = local.nitro_enclaves_daemonset_additional_envs
            content {
              name  = env.key
              value = env.value
            }
          }

          resources {
            limits   = var.nodegroup_nitro_enclaves_daemonset_resources.limits
            requests = var.nodegroup_nitro_enclaves_daemonset_resources.requests
          }

          volume_mount {
            name       = "device-plugin"
            mount_path = "/var/lib/kubelet/device-plugins"
          }
          volume_mount {
            name       = "dev-dir"
            mount_path = "/dev"
          }
          volume_mount {
            name       = "sys-dir"
            mount_path = "/sys"
          }
        }

        volume {
          name = "device-plugin"
          host_path { path = "/var/lib/kubelet/device-plugins" }
        }
        volume {
          name = "dev-dir"
          host_path { path = "/dev" }
        }
        volume {
          name = "sys-dir"
          host_path { path = "/sys" }
        }

        dynamic "toleration" {
          for_each = local.node_group_tolerations
          content {
            key      = toleration.value.key
            operator = toleration.value.operator
            value    = toleration.value.value
            effect   = toleration.value.effect
          }
        }
      }
    }
  }
  depends_on = [module.eks_managed_node_group]
}

# ***************************************
#  RDS Instance
# ***************************************
locals {
  external_name = var.rds_db_name != null ? substr(lower(replace("${var.rds_prefix}-${var.network_environment}-${var.rds_db_name}", "/[^a-z0-9-]/", "-")), 0, 63) : "${var.rds_prefix}-${var.network_environment}-rds"
  db_identifier = var.rds_identifier_override != null ? var.rds_identifier_override : local.external_name
}

module "rds_instance" {
  count   = var.enable_rds ? 1 : 0
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.10"

  identifier = local.db_identifier

  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  family         = "postgres${floor(var.rds_engine_version)}"

  instance_class        = var.rds_instance_class
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  multi_az              = var.rds_multi_az
  parameters            = var.rds_parameters

  db_name  = var.rds_db_name
  username = var.rds_username
  port     = var.rds_port

  manage_master_user_password = true

  iam_database_authentication_enabled = false

  maintenance_window      = var.rds_maintenance_window
  backup_retention_period = var.rds_backup_retention_period

  monitoring_interval    = var.rds_monitoring_interval
  create_monitoring_role = var.rds_create_monitoring_role
  monitoring_role_arn    = var.rds_monitoring_role_arn

  create_db_subnet_group = true
  subnet_ids             = local.private_subnet_ids
  vpc_security_group_ids = [module.rds_security_group[0].security_group_id]

  deletion_protection = var.rds_deletion_protection
  tags                = var.tags
}

module "rds_security_group" {
  count   = var.enable_rds ? 1 : 0
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.2"

  name        = var.rds_db_name != null ? var.rds_db_name : "rds-sg"
  description = "Security group for ${var.rds_db_name != null ? var.rds_db_name : "RDS"} RDS Postgres opened port within VPC"
  vpc_id      = var.rds_vpc_id == null ? data.aws_eks_cluster.cluster.vpc_config[0].vpc_id : var.rds_vpc_id
  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = join(",", concat(var.rds_allowed_cidr_blocks, local.private_subnet_cidr_blocks))
    }
  ]
  tags = var.tags
}

resource "kubernetes_service" "externalname" {
  count = var.enable_rds && var.rds_create_externalname_service ? 1 : 0

  metadata {
    name      = var.rds_externalname_service_name
    namespace = var.rds_externalname_service_namespace
  }
  spec {
    type          = "ExternalName"
    external_name = split(":", module.rds_instance[0].db_instance_endpoint)[0]
  }
}
