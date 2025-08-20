# Terragrunt Infrastructure Management
# Makefile for easy environment management

.PHONY: help plan-all apply-all destroy-all init-all validate-all output-all clean-cache clean-cache-env plan-all-provider apply-all-provider destroy-all-provider plan-all-consumer apply-all-consumer destroy-all-consumer output-all-provider output-all-consumer cmd output run-on show-output validate plan apply env-info help-examples

# Default target
help:
	@echo "Available commands:"
	@echo "  make plan-all      - Plan all environments"
	@echo "  make apply-all     - Apply all environments"
	@echo "  make destroy-all   - Destroy all environments"
	@echo "  make output-all    - Output all environments"
	@echo "  make init-all      - Initialize all environments"
	@echo "  make validate-all  - Validate all environments"
	@echo "  make clean-cache   - Clean all Terraform/Terragrunt cache"
	@echo ""
	@echo "Provider/Consumer specific commands:"
	@echo "  make plan-all-provider    - Plan all provider modules"
	@echo "  make apply-all-provider   - Apply all provider modules"
	@echo "  make destroy-all-provider - Destroy all provider modules"
	@echo "  make output-all-provider  - Output all provider modules"
	@echo "  make plan-all-consumer    - Plan all consumer modules"
	@echo "  make apply-all-consumer   - Apply all consumer modules"
	@echo "  make destroy-all-consumer - Destroy all consumer modules"
	@echo "  make output-all-consumer  - Output all consumer modules"
	@echo ""
	@echo "Dynamic commands:"
	@echo "  make output ENV=<env>           - Get outputs from specific environment"
	@echo "  make plan ENV=<env>             - Plan specific environment"
	@echo "  make apply ENV=<env>            - Apply specific environment"
	@echo "  make validate ENV=<env>         - Validate specific environment"
	@echo "  make clean-cache-env ENV=<env>  - Clean cache for specific environment"
	@echo ""
	@echo "Module-specific commands:"
	@echo "  make run-on ENV=<env> MODULE=<module> CMD=<cmd>"
	@echo "  make show-output ENV=<env> MODULE=<module>"
	@echo "  make env-info ENV=<env>         - Show environment information"
	@echo ""
	@echo "Examples:"
	@echo "  make help-examples                - Show usage examples"

# All environments
plan-all:
	terragrunt run-all plan

apply-all:
	terragrunt run-all apply

destroy-all:
	terragrunt run-all destroy

init-all:
	terragrunt run-all init -reconfigure

validate-all:
	terragrunt run-all validate

output-all:
	terragrunt run-all output

# Clean cache commands
clean-cache:
	@echo "🧹 Cleaning all Terraform and Terragrunt cache directories..."
	find . -type d -name ".terragrunt-cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@echo "✅ Cache cleanup completed!"

# Clean cache for specific environment
# Usage: make clean-cache-env ENV=<env>
clean-cache-env:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required. Usage: make clean-cache-env ENV=<env>"; exit 1; fi
	@echo "🧹 Cleaning Terraform and Terragrunt cache for $(ENV) environment..."
	find $(ENV) -type d -name ".terragrunt-cache" -exec rm -rf {} + 2>/dev/null || true
	find $(ENV) -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find $(ENV) -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@echo "✅ Cache cleanup completed for $(ENV) environment!"

# plan all provider
plan-all-provider:
	terragrunt run-all plan --terragrunt-include-dir "**/mpc-network-provider"

# apply all provider
apply-all-provider:
	terragrunt run-all apply --terragrunt-include-dir "**/mpc-network-provider"

# destroy all provider
destroy-all-provider:
	terragrunt run-all destroy --terragrunt-include-dir "**/mpc-network-provider"

# plan all consumer
plan-all-consumer:
	terragrunt run-all plan --terragrunt-include-dir "**/mpc-network-consumer"

# apply all consumer
apply-all-consumer:
	terragrunt run-all apply --terragrunt-include-dir "**/mpc-network-consumer"

# destroy all consumer
destroy-all-consumer:
	terragrunt run-all destroy --terragrunt-include-dir "**/mpc-network-consumer"

# output all provider
output-all-provider:
	terragrunt run-all output --terragrunt-include-dir "**/mpc-network-provider"

# output all consumer
output-all-consumer:
	terragrunt run-all output --terragrunt-include-dir "**/mpc-network-consumer/**"





# Dynamic commands - Use variables to target specific environments/modules
# Usage: make cmd ENV=<env> CMD=plan
# Usage: make cmd ENV=<env> CMD=output
cmd:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required. Usage: make cmd ENV=<env> CMD=plan"; exit 1; fi
	@if [ -z "$(CMD)" ]; then echo "Error: CMD variable is required. Usage: make cmd ENV=<env> CMD=plan"; exit 1; fi
	terragrunt run-all $(CMD) --terragrunt-include-dir "**/$(ENV)/**"

# Dynamic output command - Get outputs from specific environment  
# Usage: make output ENV=<env>
output:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required. Usage: make output ENV=<env>"; exit 1; fi
	terragrunt run-all output --terragrunt-include-dir "**/$(ENV)/**"

# Run command on specific module within environment
# Usage: make run-on ENV=<env> MODULE=<module> CMD=<cmd>
run-on:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required"; exit 1; fi
	@if [ -z "$(MODULE)" ]; then echo "Error: MODULE variable is required"; exit 1; fi
	@if [ -z "$(CMD)" ]; then echo "Error: CMD variable is required"; exit 1; fi
	cd $(ENV)/$(MODULE) && terragrunt $(CMD)

# Show outputs for specific module
# Usage: make show-output ENV=<env> MODULE=<module>
show-output:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required"; exit 1; fi
	@if [ -z "$(MODULE)" ]; then echo "Error: MODULE variable is required"; exit 1; fi
	cd $(ENV)/$(MODULE) && terragrunt output

# Validate specific environment
# Usage: make validate ENV=<env>
validate:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required. Usage: make validate ENV=<env>"; exit 1; fi
	terragrunt run-all validate --terragrunt-include-dir "**/$(ENV)/**"

# Plan specific environment  
# Usage: make plan ENV=<env>
plan:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required. Usage: make plan ENV=<env>"; exit 1; fi
	terragrunt run-all plan --terragrunt-include-dir "**/$(ENV)/**"

# Apply specific environment
# Usage: make apply ENV=<env>
apply:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required. Usage: make apply ENV=<env>"; exit 1; fi
	terragrunt run-all apply --terragrunt-include-dir "**/$(ENV)/**"

# Show current environment info
# Usage: make env-info ENV=<env>
env-info:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required. Usage: make env-info ENV=<env>"; exit 1; fi
	@echo "Environment: $(ENV)"
	@echo "Available modules:"
	@find $(ENV) -name "terragrunt.hcl" -not -path "*/.terragrunt-cache/*" -exec dirname {} \; | sed 's|$(ENV)/||' | sort


# Show usage examples
help-examples:
	@echo "🚀 Terragrunt Dynamic Commands - Usage Examples"
	@echo ""
	@echo "📁 Environment Commands:"
	@echo "  make output ENV=<env>             # Get all outputs from specific environment"
	@echo "  make plan ENV=<env>               # Plan specific environment"
	@echo "  make apply ENV=<env>              # Apply specific environment"
	@echo "  make validate ENV=<env>           # Validate specific environment"
	@echo ""
	@echo "🎯 Module-Specific Commands:"
	@echo "  make show-output ENV=<env> MODULE=<module>"
	@echo "  make run-on ENV=<env> MODULE=<module> CMD=<cmd>"
	@echo ""
	@echo "📊 Information Commands:"
	@echo "  make env-info ENV=<env>           # Show available modules in environment"
	@echo ""
	@echo "⚡ Quick Operations:"
	@echo "  make output-all                   # Get outputs from all environments"
	@echo "  make validate-all                 # Validate all environments"
	@echo "  make output-all-provider          # Get outputs from all provider modules"
	@echo "  make output-all-consumer          # Get outputs from all consumer modules"
	@echo "  make clean-cache                  # Clean all Terraform/Terragrunt cache"
	@echo "  make clean-cache-env ENV=<env>    # Clean cache for specific environment"