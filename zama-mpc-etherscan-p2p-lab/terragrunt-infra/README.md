# Terragrunt Infrastructure Management

Terragrunt setup for managing **MPC (Multi-Party Computation) infrastructure** across multiple environments.

## Modules

- **🏭 mpc-party**: Core MPC infrastructure (EKS, S3, IAM, RDS)
- **🌉 mpc-network-provider**: Expose services via AWS PrivateLink  
- **🔌 mpc-network-consumer**: Connect to external MPC parties

## Environments

- **zws-dev**: Uses `token-zws-dev` profile → `zama-terraform-mpc-modules-tfstate` bucket
- **kms-dev-v1**: Uses `token-kms-dev` profile → `zama-terraform-kms-dev-v1-mpc-modules-tfstate` bucket  

## Usage

```bash
# Setup AWS profiles
aws configure --profile token-zws-dev
aws configure --profile token-kms-dev

# MFA (if required)
./aws-mfa-auth.sh token-zws-dev

# Common commands
make help           # Show all commands

# Dynamic commands
make run-on ENV=zws-dev MODULE=mpc-party CMD=plan  # Plan specific module
make run-on ENV=zws-dev MODULE=mpc-party CMD=apply  # Apply specific module
make run-on ENV=zws-dev MODULE=mpc-network-provider CMD="init -reconfigure"  # Reconfigure specific module
```

## Provider Version Management

This infrastructure uses a centralized version management system through `version.hcl` files:

### Version Hierarchy

1. **Root Level** (`version.hcl`): Default provider versions for all environments
2. **Environment Level** (`{environment}/version.hcl`): Environment-specific overrides

### How It Works

The system ensures  **provider versions** are parameterized through dedicated `version.hcl` files. The `root.hcl` configuration automatically detects and loads the appropriate `version.hcl` file for each environment, with environment-specific versions taking precedence over root defaults. All provider configurations are then generated dynamically using these version specifications within `root.hcl`.

## Adding New Environment

1. **Update `common.hcl`**:
```hcl
aws_profiles = {
  "my-env" = {
    profile = "my-aws-profile"
    region  = "eu-west-1"
    account_id = "123456789012"
    terraform_state_bucket = "my-state-bucket"
  }
}
```

2. **Create directory structure**:
```bash
mkdir -p my-env/{mpc-party,mpc-network-provider,mpc-network-consumer}
```

3. **Copy configurations from existing environment**:
```bash
cp -r zws-dev/mpc-party/* my-env/mpc-party/
# Edit terraform.tfvars as needed
```

4. **Create environment-specific version.hcl** (optional):
```bash
cp zws-dev/version.hcl my-env/version.hcl
# Edit version overrides as needed
```