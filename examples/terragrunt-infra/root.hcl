# Root Terragrunt Configuration
# Shared configuration for all environments

# Remote state configuration - will be customized per environment
remote_state {
  backend = "s3"
  config = {
    bucket         = "zama-terraform-mpc-modules-tfstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
} 