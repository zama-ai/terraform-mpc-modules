# Terragrunt Infrastructure Management

This directory provides a Terragrunt-based approach to managing multiple environments for the partner-provider module with complete environment isolation and self-contained configurations.

## Directory Structure

```
terragrunt-infra/
├── terragrunt.hcl                    # Root configuration (shared)
├── zws-dev/
│   └── partner-provider/
│       ├── terragrunt.hcl            # Environment config
│       └── terraform.tfvars          # ZWS-Dev specific variables
├── eks-example/
│   └── partner-provider/
│       ├── terragrunt.hcl            # Environment config
│       └── terraform.tfvars          # EKS-Example specific variables
├── README.md
├── Makefile                          # Easy commands
└── .gitignore                        # Terragrunt-specific ignores
```

## Key Features

✅ **Self-Contained Environments** - Each environment owns its complete configuration  
✅ **Different Backend Keys** - Each environment has isolated state:
- ZWS-Dev: `zws-dev/partner-provider/terraform.tfstate`
- EKS-Example: `eks-example/partner-provider/terraform.tfstate`  
✅ **DRY Configuration** - Shared provider and backend configuration via root terragrunt.hcl  
✅ **Local Variables** - No external dependencies, all config in environment directory  
✅ **Standard Terragrunt Pattern** - Follows industry best practices  

## Usage

### Deploy to ZWS-Dev Environment

```bash
cd zws-dev/partner-provider
terragrunt plan
terragrunt apply
terragrunt destroy
```

### Deploy to EKS-Example Environment

```bash
cd eks-example/partner-provider
terragrunt plan
terragrunt apply
terragrunt destroy
```

### Deploy to All Environments

```bash
# From the root terragrunt-infra directory
terragrunt run-all plan
terragrunt run-all apply
terragrunt run-all destroy
```

### Using Makefile (Easier Commands)

```bash
# Quick commands
make help           # Show all available commands
make plan-all       # Plan all environments
make apply-all      # Apply all environments

# Environment-specific
make plan-zws       # Plan only ZWS-Dev
make apply-zws      # Apply only ZWS-Dev
make plan-eks       # Plan only EKS-Example
make apply-eks      # Apply only EKS-Example
```

### Deploy to Specific Environment Type

```bash
# Only ZWS-Dev environments
terragrunt run-all plan --terragrunt-include-dir "**/zws-dev/**"
terragrunt run-all apply --terragrunt-include-dir "**/zws-dev/**"

# Only EKS-Example environments
terragrunt run-all plan --terragrunt-include-dir "**/eks-example/**"
terragrunt run-all apply --terragrunt-include-dir "**/eks-example/**"
```

## Backend Configuration

Each environment uses a different S3 key for state isolation:

| Environment | Backend Key | Configuration File |
|-------------|-------------|-------------------|
| zws-dev | `zws-dev/partner-provider/terraform.tfstate` | `zws-dev/partner-provider/terraform.tfvars` |
| eks-example | `eks-example/partner-provider/terraform.tfstate` | `eks-example/partner-provider/terraform.tfvars` |

## Adding New Environments

1. Create a new directory: `my-env/partner-provider/`
2. Create `terragrunt.hcl` with a unique backend key:

```hcl
include "root" {
  path = find_in_parent_folders()
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "zama-terraform-mpc-modules-tfstate"
    key            = "my-env/partner-provider/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

terraform {
  source = "../../../partner-provider"
}

inputs = {
  # Add any environment-specific overrides here
}
```

3. Create `terraform.tfvars` with environment-specific variables
4. Deploy: `cd my-env/partner-provider && terragrunt apply`

## Environment Configuration

Each environment has its own `terraform.tfvars` file with complete configuration:

- **AWS Configuration**: Region settings and EKS cluster info
- **MPC Services**: Complete node configuration with ports, selectors, annotations
- **VPC Endpoints**: PrivateLink configuration for partner access
- **Kubernetes Auth**: Either kubeconfig context or EKS token authentication
- **Tagging**: Environment-specific resource tags

### Example Environment Differences:

**ZWS-Dev Environment:**
- Uses kubeconfig context authentication
- 3 MPC nodes with full configuration
- Specific cluster: `zama-dev.tp.enix.io-zws-dev`

**EKS-Example Environment:**
- Uses EKS token authentication
- 3 MPC nodes with identical ports but different authentication
- Different cluster: `zama-dev-cluster`

## Advantages Over Previous Setup

1. **Self-Contained** - Each environment is completely independent
2. **No External Dependencies** - No relative path dependencies to break
3. **Team Collaboration** - Teams can work on environments without conflicts
4. **CI/CD Friendly** - Simple directory-based deployment logic
5. **Standard Pattern** - Follows Terragrunt community best practices
6. **Easy Maintenance** - Clear ownership and modification boundaries

## Migration from Original Setup

The tfvars files have been migrated from the original partner-provider directory:
- `terraform-zws-dev.tfvars` → `zws-dev/partner-provider/terraform.tfvars`
- `terraform-eks-example.tfvars` → `eks-example/partner-provider/terraform.tfvars`

Changes made during migration:
- ✅ Removed `storage_backend_config` (Terragrunt handles backend)
- ✅ Added `"ManagedBy" = "terragrunt"` tag
- ✅ Updated comments to reflect Terragrunt management

## Integration with CI/CD

```bash
# Example CI/CD pipeline commands
# Deploy to dev environment first
terragrunt run-all plan --terragrunt-include-dir "**/zws-dev/**"
terragrunt run-all apply --terragrunt-include-dir "**/zws-dev/**"

# Validate and then deploy to other environments
terragrunt run-all plan --terragrunt-include-dir "**/eks-example/**"
terragrunt run-all apply --terragrunt-include-dir "**/eks-example/**"

# Or use make commands
make apply-zws    # Deploy to ZWS-Dev
make apply-eks    # Deploy to EKS-Example
```

## Troubleshooting

### State File Issues
```bash
# Check current state
cd zws-dev/partner-provider
terragrunt state list

# Import existing resources if needed
terragrunt import <resource_type>.<resource_name> <resource_id>
```

### Backend Access Issues
Ensure your AWS credentials have access to:
- S3 bucket: `zama-terraform-mpc-modules-tfstate`
- DynamoDB table: `terraform-locks` (for state locking)

### Module Source Issues
If the relative path doesn't work:
```bash
# Update terraform.source in terragrunt.hcl
source = "/absolute/path/to/partner-provider"
```

### Variable Loading Issues
Terragrunt automatically loads `terraform.tfvars` from the same directory. If variables aren't being picked up:
1. Ensure the file is named exactly `terraform.tfvars`
2. Check for syntax errors in the tfvars file
3. Verify variable names match those in `variables.tf`

## Best Practices

1. **Keep environments self-contained** - All config in the environment directory
2. **Use descriptive backend keys** - Include environment and component names
3. **Consistent naming** - Follow the same pattern for all environments
4. **Document differences** - Note why environments differ in comments
5. **Test changes in dev first** - Use ZWS-Dev for testing before other environments 