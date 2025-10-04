# Network Environment Configuration
network_environment = "testnet"

# AWS Configuration
aws_region         = "eu-west-1"
enable_region_validation = false
aws_profile              =  "zama-mpc-testnet-user"

cluster_name = "zama-mpc-testnet-eks"
namespace    = "kms-decentralized"
environment  = "dev"

# Party Configuration
party_id = "12"
partner_name = "etherscan-p2p-lab"

# Kubernetes Provider Configuration
# Option 1: Using kubeconfig context (current method)
kubeconfig_path    = "~/.kube/config"
kubeconfig_context = "arn:aws:eks:eu-west-1:455309426926:cluster/zama-mpc-testnet-eks"
# If you are using EKS cluster authentication, set this to true
use_eks_cluster_authentication = true

# VPC Endpoint Services Configuration
# Indicate all aws accounts and regions from which the partner services will be consumed
# By default, the terraform module will add the current region to the supported regions list
allowed_vpc_endpoint_principals  = ["arn:aws:iam::156692459989:root", #Zama 1 13
                                    "arn:aws:iam::864456252326:root", #Dfns 2
                                    "arn:aws:iam::192990274904:root", #Figment 3
                                    "arn:aws:iam::813007935465:root", #Fireblocks 4
                                    "arn:aws:iam::954455479205:root", #InfStones 5
                                    "arn:aws:iam::145491114753:root", #Kiln 6
                                    "arn:aws:iam::003460570947:root", #LayerZero 7
                                    #"arn:aws:iam::xxxx:root",        #Ledger 8
                                    "arn:aws:iam::287540661763:root", #Omakase 9
                                    "arn:aws:iam::748699405583:root", #Stake Capital 10
                                    "arn:aws:iam::093827727269:root", #OpenZeppelin 11
                                    "arn:aws:iam::455309426926:root"] #etherscan-p2p-lab 12 
vpc_endpoint_supported_regions   = ["eu-west-1"]


vpc_endpoint_acceptance_required = false

# Tagging
common_tags = {
  "terraform"   = "true"
  "module"      = "mpc-cluster-partner-provider"
  "environment" = "dev"
  "Project"     = "mpc-cluster"
  "Example"     = "partner-provider"
  "Mode"        = "provider"
  "ManagedBy"   = "terragrunt"
}