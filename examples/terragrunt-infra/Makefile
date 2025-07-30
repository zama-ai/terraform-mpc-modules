# Terragrunt Infrastructure Management
# Makefile for easy environment management

.PHONY: help plan-all apply-all destroy-all plan-zws apply-zws destroy-zws plan-eks apply-eks destroy-eks

# Default target
help:
	@echo "Available commands:"
	@echo "  make plan-all      - Plan all environments"
	@echo "  make apply-all     - Apply all environments"
	@echo "  make destroy-all   - Destroy all environments"
	@echo ""
	@echo "  make plan-zws      - Plan ZWS-Dev environment"
	@echo "  make apply-zws     - Apply ZWS-Dev environment"
	@echo "  make destroy-zws   - Destroy ZWS-Dev environment"
	@echo ""
	@echo "  make plan-eks      - Plan EKS-Example environment"
	@echo "  make apply-eks     - Apply EKS-Example environment"
	@echo "  make destroy-eks   - Destroy EKS-Example environment"
	@echo ""
	@echo "  make init-all      - Initialize all environments"
	@echo "  make validate-all  - Validate all environments"

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

# ZWS-Dev environment
plan-zws:
	terragrunt run-all plan --terragrunt-include-dir "**/zws-dev/**"

apply-zws:
	terragrunt run-all apply --terragrunt-include-dir "**/zws-dev/**"

destroy-zws:
	terragrunt run-all destroy --terragrunt-include-dir "**/zws-dev/**"

# EKS-Example environment
plan-eks:
	terragrunt run-all plan --terragrunt-include-dir "**/eks-example/**"

apply-eks:
	terragrunt run-all apply --terragrunt-include-dir "**/eks-example/**"

destroy-eks:
	terragrunt run-all destroy --terragrunt-include-dir "**/eks-example/**"

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