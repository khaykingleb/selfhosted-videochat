.DEFAULT_GOAL = help

##=============================================================================
##@ Initialization
##=============================================================================

init-asdf: ## Initialize asdf
	@echo "Installing asdf plugins."
	@asdf install
.PHONY: init-asdf

init-pre-commit: ## Initialize pre-commit hooks
	@echo "Installing pre-commit hooks."
	@pre-commit install --hook-type pre-commit --hook-type commit-msg
.PHONY: init-pre-commit

init-terraform: ## Initialize terraform
	@echo "Installing terraform plugins."
	@cd terraform && terraform init -upgrade
.PHONY: init-terraform

init: init-asdf init-pre-commit init-terraform ## Initialize repository
.PHONY: init

##=============================================================================
##@ Pre-commit
##=============================================================================

pre-commit-autoupdate: ## Update pre-commit hooks
	@pre-commit autoupdate
.PHONY: pre-commit-autoupdate

pre-commit-run-all: ## Run pre-commit hooks on all files
	@pre-commit run --all-files
.PHONY: pre-commit-run-all

##=============================================================================
##@ Secrets
##=============================================================================

secrets-create-baseline: ## Create a baseline for secrets
	@uv run --with detect-secrets detect-secrets scan > .secrets.baseline
.PHONY: secrets-create-baseline

secrets-scan: ## Scan for secrets
	@uv run --with detect-secrets detect-secrets scan --update .secrets.baseline
.PHONY: secrets-scan

##=============================================================================
##@ Misc
##=============================================================================

ssh: ## SSH into the droplet
	@cd terraform && ssh \
		-i ssh/id_digitalocean_droplet_rsa \
		root@$$(terraform output -raw droplet_ip)
.PHONY: ssh

##=============================================================================
##@ Helper
##=============================================================================

help: ## Display help
	@awk 'BEGIN {FS = ":.*##"; \
		printf "\nUsage:\n  make \033[36m<target>\033[0m\n\n"} \
		/^[a-zA-Z0-9_-]+%?:.*?##/ { \
			printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 \
		} \
		/^##@/ { \
			printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
		}' $(MAKEFILE_LIST)
.PHONY: help
