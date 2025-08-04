# AWS Configuration
aws_region = "eu-west-1"

# Node Group Configuration
create_nodegroup = true
name = "zama-mpc-decentralized"
cluster_name = "zws-dev"
instance_types = ["t3.large"]
kubernetes_version = "1.31"
ami_type = "AL2023_x86_64_STANDARD"
min_size = 4
max_size = 4
desired_size = 4
disk_size = 30
taints = {
  "dedicated" = {
    key = "kms-decentralized"
    value = "true"
    effect = "NO_SCHEDULE"
  }
}
labels = {
	"nodepool" = "kms-decentralized"
}

# Example configurations for different scenarios:

# Scenario 1: Development environment with IRSA
# party_name  = "dev-party-alice"
# environment = "dev"
# create_irsa = true

# Scenario 2: Production environment with custom naming
# party_name    = "prod-party-bank-a"
# environment   = "prod"
# bucket_prefix = "company-secure-mpc"
# create_irsa   = true

# Scenario 3: Testing without IRSA (use manual AWS credentials)
# party_name  = "test-party"
# environment = "test"
# create_irsa = false 