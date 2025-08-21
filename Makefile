
.PHONY: help docs install-terraform-docs fmt

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install-terraform-docs: ## Install terraform-docs tool
	@if which terraform-docs >/dev/null 2>&1; then \
		echo "terraform-docs is already installed"; \
	elif which go >/dev/null 2>&1; then \
		echo "Installing terraform-docs..."; \
		go install github.com/terraform-docs/terraform-docs@v0.20.0; \
		echo "terraform-docs installed successfully!"; \
	else \
		echo "Please install terraform-docs manually: https://terraform-docs.io/user-guide/installation/"; \
		exit 1; \
	fi

docs: ## Generate documentation for all modules
	@echo "Generating documentation for all modules..."
	@terraform-docs --config .terraform-docs.yml .
	@echo "Documentation generated successfully!"

fmt: ## Format all Terraform files
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive .
	@echo "All Terraform files formatted!"
