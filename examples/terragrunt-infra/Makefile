# Terragrunt Infrastructure Management
# Makefile for easy environment management

.PHONY: help plan-all apply-all destroy-all plan-zws apply-zws destroy-zws plan-kms apply-kms destroy-kms output-all output-zws output-kms cmd output run-on show-output validate plan apply env-info help-examples quick-outputs

# Default target
help:
	@echo "Available commands:"
	@echo "  make plan-all      - Plan all environments"
	@echo "  make apply-all     - Apply all environments"
	@echo "  make destroy-all   - Destroy all environments"
	@echo "  make output-all    - Output all environments"
	@echo ""
	@echo "  make plan-zws      - Plan ZWS-Dev environment"
	@echo "  make apply-zws     - Apply ZWS-Dev environment"
	@echo "  make destroy-zws   - Destroy ZWS-Dev environment"
	@echo "  make output-zws    - Output ZWS-Dev environment"
	@echo ""
	@echo "  make plan-kms      - Plan KMS-Dev-V1 environment"
	@echo "  make apply-kms     - Apply KMS-Dev-V1 environment"
	@echo "  make destroy-kms   - Destroy KMS-Dev-V1 environment"
	@echo "  make output-kms    - Output KMS-Dev-V1 environment"
	@echo ""
	@echo "  make init-all      - Initialize all environments"
	@echo "  make validate-all  - Validate all environments"
	@echo ""
	@echo "Dynamic commands:"
	@echo "  make output ENV=zws-dev           - Get outputs from specific environment"
	@echo "  make plan ENV=kms-dev-v1          - Plan specific environment"
	@echo "  make apply ENV=zws-dev            - Apply specific environment"
	@echo "  make validate ENV=kms-dev-v1      - Validate specific environment"
	@echo ""
	@echo "Module-specific commands:"
	@echo "  make run-on ENV=zws-dev MODULE=mpc-network-provider CMD=output"
	@echo "  make show-output ENV=kms-dev-v1 MODULE=mpc-network-consumer"
	@echo "  make env-info ENV=zws-dev         - Show environment information"
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
	terragrunt run-all init

validate-all:
	terragrunt run-all validate

output-all:
	terragrunt run-all output

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

# ZWS-Dev environment
plan-zws:
	terragrunt run-all plan --terragrunt-include-dir "**/zws-dev/**"

apply-zws:
	terragrunt run-all apply --terragrunt-include-dir "**/zws-dev/**"

destroy-zws:
	terragrunt run-all destroy --terragrunt-include-dir "**/zws-dev/**"

output-zws:
	terragrunt run-all output --terragrunt-include-dir "**/zws-dev/**"

# KMS-Dev-V1 environment
plan-kms:
	terragrunt run-all plan --terragrunt-include-dir "**/kms-dev-v1/**"

apply-kms:
	terragrunt run-all apply --terragrunt-include-dir "**/kms-dev-v1/**"

destroy-kms:
	terragrunt run-all destroy --terragrunt-include-dir "**/kms-dev-v1/**"

output-kms:
	terragrunt run-all output --terragrunt-include-dir "**/kms-dev-v1/**"

# Individual environment targets
zws-dev-plan:
	cd zws-dev/partner-provider && terragrunt plan

zws-dev-apply:
	cd zws-dev/partner-provider && terragrunt apply

zws-dev-destroy:
	cd zws-dev/partner-provider && terragrunt destroy

eks-example-plan:
	cd eks-example/partner-provider && terragrunt plan

eks-example-apply:
	cd eks-example/partner-provider && terragrunt apply

eks-example-destroy:
	cd eks-example/partner-provider && terragrunt destroy

# Dynamic commands - Use variables to target specific environments/modules
# Usage: make cmd ENV=zws-dev CMD=plan
# Usage: make cmd ENV=kms-dev-v1 CMD=output
cmd:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required. Usage: make cmd ENV=zws-dev CMD=plan"; exit 1; fi
	@if [ -z "$(CMD)" ]; then echo "Error: CMD variable is required. Usage: make cmd ENV=zws-dev CMD=plan"; exit 1; fi
	terragrunt run-all $(CMD) --terragrunt-include-dir "**/$(ENV)/**"

# Dynamic output command - Get outputs from specific environment  
# Usage: make output ENV=zws-dev
# Usage: make output ENV=kms-dev-v1
output:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required. Usage: make output ENV=zws-dev"; exit 1; fi
	terragrunt run-all output --terragrunt-include-dir "**/$(ENV)/**"

# Run command on specific module within environment
# Usage: make run-on ENV=zws-dev MODULE=mpc-network-provider CMD=output
# Usage: make run-on ENV=kms-dev-v1 MODULE=mpc-network-consumer CMD=plan
run-on:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required"; exit 1; fi
	@if [ -z "$(MODULE)" ]; then echo "Error: MODULE variable is required"; exit 1; fi
	@if [ -z "$(CMD)" ]; then echo "Error: CMD variable is required"; exit 1; fi
	cd $(ENV)/$(MODULE) && terragrunt $(CMD)

# Show outputs for specific module
# Usage: make show-output ENV=zws-dev MODULE=mpc-network-provider
show-output:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required"; exit 1; fi
	@if [ -z "$(MODULE)" ]; then echo "Error: MODULE variable is required"; exit 1; fi
	cd $(ENV)/$(MODULE) && terragrunt output

# Validate specific environment
# Usage: make validate ENV=zws-dev
validate:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required. Usage: make validate ENV=zws-dev"; exit 1; fi
	terragrunt run-all validate --terragrunt-include-dir "**/$(ENV)/**"

# Plan specific environment  
# Usage: make plan ENV=zws-dev
plan:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required. Usage: make plan ENV=zws-dev"; exit 1; fi
	terragrunt run-all plan --terragrunt-include-dir "**/$(ENV)/**"

# Apply specific environment
# Usage: make apply ENV=zws-dev
apply:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required. Usage: make apply ENV=zws-dev"; exit 1; fi
	terragrunt run-all apply --terragrunt-include-dir "**/$(ENV)/**"

# Show current environment info
# Usage: make env-info ENV=zws-dev
env-info:
	@if [ -z "$(ENV)" ]; then echo "Error: ENV variable is required. Usage: make env-info ENV=zws-dev"; exit 1; fi
	@echo "Environment: $(ENV)"
	@echo "Available modules:"
	@find $(ENV) -name "terragrunt.hcl" -not -path "*/.terragrunt-cache/*" -exec dirname {} \; | sed 's|$(ENV)/||' | sort

# Show usage examples
help-examples:
	@echo "🚀 Terragrunt Dynamic Commands - Usage Examples"
	@echo ""
	@echo "📁 Environment Commands (automatically uses correct AWS profile):"
	@echo "  make output ENV=zws-dev           # Get all outputs from zws-dev environment"
	@echo "  make output ENV=kms-dev-v1        # Get all outputs from kms-dev-v1 environment"
	@echo "  make plan ENV=zws-dev             # Plan zws-dev environment (uses enix-tmp profile)"
	@echo "  make plan ENV=kms-dev-v1          # Plan kms-dev-v1 environment (uses ghislain-zama profile)"
	@echo "  make validate ENV=zws-dev         # Validate zws-dev environment"
	@echo ""
	@echo "🎯 Module-Specific Commands:"
	@echo "  make show-output ENV=zws-dev MODULE=mpc-network-provider"
	@echo "  make show-output ENV=kms-dev-v1 MODULE=mpc-network-consumer"  
	@echo "  make run-on ENV=zws-dev MODULE=mpc-network-provider CMD=plan"
	@echo "  make run-on ENV=kms-dev-v1 MODULE=mpc-network-consumer CMD=validate"
	@echo ""
	@echo "📊 Information Commands:"
	@echo "  make env-info ENV=zws-dev         # Show available modules in environment"
	@echo "  make env-info ENV=kms-dev-v1      # Show available modules in environment"
	@echo ""
	@echo "⚡ Quick Operations:"
	@echo "  make output-all                   # Get outputs from all environments"
	@echo "  make validate-all                 # Validate all environments"
	@echo "  make output-all-provider          # Get outputs from all provider modules"
	@echo "  make output-all-consumer          # Get outputs from all consumer modules"
	@echo ""
	@echo "✅ All commands automatically use the correct AWS profile based on environment!"

# Quick output commands for common scenarios
quick-outputs:
	@echo "🎯 Quick Outputs - All Environments"
	@echo ""
	@echo "ZWS-Dev Environment (enix-tmp profile):"
	@make output ENV=zws-dev 2>/dev/null || echo "  No outputs available or environment not initialized"
	@echo ""
	@echo "KMS-Dev-V1 Environment (ghislain-zama profile):"
	@make output ENV=kms-dev-v1 2>/dev/null || echo "  No outputs available or environment not initialized" 