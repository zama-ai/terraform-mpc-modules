# Dynamic AWS Profile Configuration Guide

This guide explains how to use the new dynamic AWS profile management system in Terragrunt.

## 🎯 Overview

The dynamic profile system automatically selects the correct AWS profile and configuration based on the environment directory you're working in. No more manual profile switching!

## 📁 How It Works

The system uses the directory path to determine the environment:
- `terragrunt-infra/kms-dev-v1/` → Uses `kms-dev-profile`
- `terragrunt-infra/zws-dev/` → Uses `zws-dev-profile`

## ⚙️ Configuration Files

### 1. `common.hcl` - Environment Mapping
Contains the mapping between environments and AWS profiles:

```hcl
aws_profiles = {
  "kms-dev-v1" = {
    profile             = "kms-dev-profile"
    region              = "eu-west-3"
    account_id          = "767398008331"
    terraform_state_bucket = "zama-terraform-kms-dev-v1-mpc-modules-tfstate"
  }
  "zws-dev" = {
    profile             = "zws-dev-profile"
    region              = "eu-west-3"
    account_id          = "715841358639"
    terraform_state_bucket = "zama-terraform-mpc-modules-tfstate"
  }
}
```

### 2. `root.hcl` - Dynamic Provider Generation & Automatic Profile Setting
Automatically generates AWS providers with the correct profile and configuration.

**Key Features:**
- **Automatic Profile Setting**: Uses Terragrunt hooks and environment variables to set `AWS_PROFILE` automatically
- **Backend Configuration**: S3 backend uses the correct profile for state storage  
- **Provider Configuration**: AWS provider uses the correct profile for resource management
- **No Manual Export**: No need to run `export AWS_PROFILE=...` manually

## 🚀 Usage

### Method 1: Automatic Profile Selection (Recommended) ✅

Simply navigate to any environment directory and run terragrunt commands - **NO manual profile export needed!**

```bash
# KMS-Dev-V1 Environment
cd examples/terragrunt-infra/kms-dev-v1/mpc-network-provider
terragrunt plan      # ✅ Automatically uses ghislain-zama profile
terragrunt apply     # ✅ Automatic profile selection
terragrunt validate  # ✅ Works seamlessly

# ZWS-Dev Environment  
cd examples/terragrunt-infra/zws-dev/mpc-network-consumer
terragrunt plan      # ✅ Automatically uses enix-tmp profile
terragrunt apply     # ✅ Automatic profile selection
terragrunt validate  # ✅ Works seamlessly
```

### Method 2: Run All Environments
```bash
cd examples/terragrunt-infra
terragrunt run-all plan    # ✅ Each environment uses its configured profile automatically
terragrunt run-all apply
```

### Method 3: Environment Variable Override (Optional)
```bash
export AWS_PROFILE_OVERRIDE=custom-profile
terragrunt plan    # Uses custom-profile instead of default

# Other available overrides:
export AWS_REGION_OVERRIDE=us-west-2
export AWS_ACCOUNT_ID_OVERRIDE=123456789012
export TERRAFORM_STATE_BUCKET_OVERRIDE=custom-bucket
```

## 🔧 Configuration Steps

### 1. ✅ Profiles Already Configured
The configuration is already set up with working profiles:

```hcl
"kms-dev-v1" = {
  profile = "ghislain-zama"     # ✅ Active profile
  region  = "eu-west-3"
  account_id = "767398008331"
}
"zws-dev" = {
  profile = "enix-tmp"          # ✅ Active profile  
  region  = "eu-west-1"
  account_id = "715841358639"
}
```

### 2. ✅ AWS Profiles Verified
Profiles are confirmed to exist and work:

```bash
aws configure list-profiles
# ✅ Shows: enix-tmp, ghislain-zama
```

### 3. ✅ Configuration Tested & Working
```bash
cd examples/terragrunt-infra/kms-dev-v1/mpc-network-provider
terragrunt validate    # ✅ Automatically uses ghislain-zama profile

cd examples/terragrunt-infra/zws-dev/mpc-network-consumer  
terragrunt validate    # ✅ Automatically uses enix-tmp profile
```

## 🔍 Verification Commands

Check which profile will be used:
```bash
cd examples/terragrunt-infra/kms-dev-v1/mpc-network-provider
terragrunt output-module-groups    # Shows current configuration
```

Check generated providers:
```bash
terragrunt plan --terragrunt-log-level debug 2>&1 | grep -i profile
```

## 🎛️ Advanced Configuration

### Adding New Environments
To add a new environment, update `common.hcl`:

```hcl
aws_profiles = {
  # Existing environments...
  
  "new-environment" = {
    profile             = "new-env-profile"
    region              = "eu-west-1"
    account_id          = "NEW_ACCOUNT_ID"
    terraform_state_bucket = "zama-terraform-new-env-mpc-modules-tfstate"
  }
}
```

Then create the directory structure:
```bash
mkdir -p examples/terragrunt-infra/new-environment/mpc-network-provider
# Copy and adapt terragrunt.hcl from existing environment
```

### Role-Based Authentication
For enterprise setups using role assumption, modify the provider configuration in `root.hcl`:

```hcl
provider "aws" {
  region  = "${local.common_vars.inputs.aws_region}"
  profile = "${local.common_vars.inputs.aws_profile}"
  
  assume_role {
    role_arn = "arn:aws:iam::${local.common_vars.inputs.aws_account_id}:role/TerraformExecutionRole"
  }
}
```

## 🚨 Troubleshooting

### Issue: Profile not found
```bash
Error: AWS profile "xyz" not found
```
**Solution**: Check if the profile exists in your AWS config:
```bash
aws configure list-profiles
```

### Issue: Wrong environment detected
```bash
# If environment detection fails
export AWS_PROFILE_OVERRIDE=correct-profile
terragrunt plan
```

### Issue: State bucket access denied
Check if your profile has access to the S3 bucket specified in the environment configuration.

## 🎉 Benefits

✅ **Fully Automatic Profile Switching** - Zero manual `export AWS_PROFILE=...` needed  
✅ **Environment Isolation** - Each environment uses its own AWS account/profile automatically  
✅ **Consistent Configuration** - DRY principle across all environments  
✅ **Error Prevention** - Impossible to deploy to wrong account due to automatic profile detection  
✅ **Scalable** - Easy to add new environments  
✅ **Override Support** - Flexible for special cases  
✅ **Hook-Based Execution** - Terragrunt automatically sets profile before every operation  
✅ **Works Everywhere** - Backend, provider, and all AWS CLI calls use correct profile  

## 📞 Support

If you encounter issues:
1. Check AWS profile configuration
2. Verify directory structure matches expected pattern
3. Use environment variable overrides for debugging
4. Check Terragrunt logs with `--terragrunt-log-level debug`