# AWS Configuration
aws_region               = "eu-west-1"
aws_profile              =  "zama-mpc-testnet-user"
#enable_region_validation = false

# Network Environment Configuration
#network_environment = "testnet"

# Cluster Configuration
cluster_name = "zama-mpc-testnet-eks"
#environment  = "dev"
#owner        = "etherscan-p2p-lab"

# Kubernetes Provider Configuration
# IMPORTANT: Update these values for each consumer node
kubeconfig_path    = "~/.kube/config"
kubeconfig_context = "arn:aws:eks:eu-west-1:455309426926:cluster/zama-mpc-testnet-eks"  # Set to specific context or null to use current
# If you are using EKS cluster authentication, set this to true
use_eks_cluster_authentication = true

# Partner Services Namespace
namespace        = "kms-decentralized"

# Optional: the following lines if using EKS cluster lookup
# vpc_id                = "vpc-07bff50640cc2dde5"
# subnet_ids           =  [
#   "subnet-0288fe1f3b475d90d",
#   "subnet-051e97122373614c7",
#   "subnet-054a87e337596757a",
# ]

security_group_ids   = ["sg-0467456f28a762f18"]

# Partner Services Configuration
# IMPORTANT: Update these for each consumer node
party_services = [
  # Example partner service configuration using default ports
  {
    "availability_zones" = [
      "euw1-az3",
      "euw1-az2",
      "euw1-az1",
    ]
    "create_kube_service" = true
    "kube_service_config" = {
      "labels" = {
        "environment" = "testnet"
        "partyid" = "1"
      }
      "session_affinity" = "None"
    }
    "name" = "mpc-node-1"
    "partner_name" = "zama"
    "party_id" = "1"
    "region" = "eu-west-1"
    "vpc_endpoint_service_name" = "com.amazonaws.vpce.eu-west-1.vpce-svc-021b85d8e9c37d55d"
  },
  {
      "create_kube_service" = true
      "kube_service_config" = {
        "labels" = {
          "environment" = "testnet"
          "partyid" = "2"
        }
        "session_affinity" = "None"
      }
      "name" = "mpc-node-2"
      "partner_name" = "dfns"
      "party_id" = "2"
      "region" = "eu-west-1"
      "vpc_endpoint_service_name" = "com.amazonaws.vpce.eu-west-1.vpce-svc-03f1619cd9da8453b"
  },
  {
    "create_kube_service" = true
    "kube_service_config" = {
      "labels" = {
        "environment" = "testnet"
        "partyid" = "3"
      }
      "session_affinity" = "None"
    }
    "name" = "mpc-node-3"
    "availability_zones" = [
      "euw1-az3",
      "euw1-az2",
      "euw1-az1",
    ]
    "partner_name" = "figment"
    "party_id" = "3"
    "region" = "eu-west-1"
    "vpc_endpoint_service_name" = "com.amazonaws.vpce.eu-west-1.vpce-svc-04b5e780940f247a7"
  },
  {
    "create_kube_service" = true
    "kube_service_config" = {
      "labels" = {
        "environment" = "testnet"
        "partyid" = "4"
      }
      "session_affinity" = "None"
    }
    "name" = "mpc-node-4"
    "partner_name" = "fireblocks"
    "party_id" = "4"
    "region" = "eu-west-1"
    "vpc_endpoint_service_name" = "com.amazonaws.vpce.eu-west-1.vpce-svc-0327c4ffead6ab766"
  },
  {
    party_id                  = "5"
    name                      = "mpc-node-5"
    region                    = "eu-west-1"
    account_id                = "954455479205"
    partner_name              = "InfStones"
    vpc_endpoint_service_name = "com.amazonaws.vpce.eu-west-1.vpce-svc-027c5cfd24cb53edd"
    create_kube_service       = true
    availability_zones = [
      "euw1-az1",
      "euw1-az2",
      "euw1-az3",
    ]
    kube_service_config = {
      labels = {
        "party-id" = "5"
        "partner-name" = "InfStones"
        "environment"  = "testnet"
      }
      session_affinity = "None"
    }
  },
  # {
  #   "availability_zones" = [
  #     "euw1-az1",
  #     "euw1-az2",
  #     "euw1-az3",
  #   ]
  #   "create_kube_service" = true
  #   "kube_service_config" = {
  #     "labels" = {
  #       "environment" = "testnet"
  #       "partyid" = "6"
  #     }
  #     "session_affinity" = "None"
  #   }
  #   "name" = "mpc-node-6"
  #   "partner_name" = "kiln"
  #   "party_id" = "6"
  #   "region" = "eu-west-1"
  #   "vpc_endpoint_service_name" = "com.amazonaws.vpce.eu-west-1.vpce-svc-03a510bc4920e4415"
  # },
  {
    "create_kube_service" = true
    "kube_service_config" = {
      "labels" = {
        "environment" = "testnet"
        "partyid" = "7"
      }
      "session_affinity" = "None"
    }
    "name" = "mpc-node-7"
    "availability_zones" = [
      "euw1-az3",
      "euw1-az2",
      "euw1-az1",
    ]
    "partner_name" = "layerzerolabs.org"
    "party_id" = "7"
    "region" = "eu-west-1"
    "vpc_endpoint_service_name" = "com.amazonaws.vpce.eu-west-1.vpce-svc-0e5fdfd2139f77e7f"
  },
  {
      "create_kube_service" = true
       "availability_zones" = ["euw1-az1","euw1-az3"]
      "kube_service_config" = {
        "labels" = {
          "environment" = "testnet"
          "partyid" = "9"
        }
        "session_affinity" = "None"
      }
      "name" = "mpc-node-9"
      "partner_name" = "omakase"
      "party_id" = "9"
      "region" = "eu-west-1"
      "vpc_endpoint_service_name" = "com.amazonaws.vpce.eu-west-1.vpce-svc-08c7bac1776c40b91"
  },
  {
      "create_kube_service" = true
      "kube_service_config" = {
        "labels" = {
          "environment" = "testnet"
          "partyid" = "10"
        }
        "session_affinity" = "None"
      }
      "name" = "mpc-node-10"
      "partner_name" = "StakeCapital"
      "party_id" = "10"
      "region" = "eu-west-1"
      "vpc_endpoint_service_name" = "com.amazonaws.vpce.eu-west-1.vpce-svc-0823eff8b9e9b52c0"
  },
  {
     "availability_zones" = [
        "euw1-az3",
        "euw1-az2",
        "euw1-az1",
      ],
     "create_kube_service" = true
     "kube_service_config" = {
       "labels" = {
         "environment" = "testnet"
         "partyid" = "11"
       }
       "session_affinity" = "None"
     }
     "name" = "mpc-node-11"
     "partner_name" = "openzeppelin"
     "party_id" = "11"
     "region" = "eu-west-1"
     "vpc_endpoint_service_name" = "com.amazonaws.vpce.eu-west-1.vpce-svc-02a3d2fd26d694453"
},
  # {
  #     "availability_zones" = [
  #       "eu-west-1b",
  #       "eu-west-1c",
  #       "eu-west-1a",
  #     ]
  #     "create_kube_service" = true
  #     "kube_service_config" = {
  #       "labels" = {
  #         "environment" = "testnet"
  #         "partyid" = "12"
  #       }
  #       "session_affinity" = "None"
  #     }
  #     "name" = "mpc-node-12"
  #     "partner_name" = "etherscan-p2p-lab"
  #     "party_id" = "12"
  #     "region" = "eu-west-1"
  #     "vpc_endpoint_service_name" = "com.amazonaws.vpce.eu-west-1.vpce-svc-052ecc49741d8e66b"
  #   }
  {
    "availability_zones" = [
      "euw1-az3",
      "euw1-az2",
      "euw1-az1",
    ]
    "create_kube_service" = true
    "kube_service_config" = {
      "labels" = {
        "environment" = "testnet"
        "partyid" = "13"
      }
      "session_affinity" = "None"
    }
    "name" = "mpc-node-13"
    "partner_name" = "zama-13"
    "party_id" = "13"
    "region" = "eu-west-1"
    "vpc_endpoint_service_name" = "com.amazonaws.vpce.eu-west-1.vpce-svc-0c4dae6e486eb302b"
  }
]

# VPC Endpoint Configuration
private_dns_enabled = false
name_prefix         = "mpc-partner"

# Timeouts
endpoint_create_timeout = "15m"
endpoint_delete_timeout = "10m"

# Custom DNS (optional)
create_custom_dns_records = false
private_zone_id           = ""

# Tagging
common_tags = {
  "terraform"   = "true"
  "module"      = "partner-consumer-direct"
  "environment" = "dev"
}

# additional_tags = {
#   "Project"     = "mpc-connectivity"
# }