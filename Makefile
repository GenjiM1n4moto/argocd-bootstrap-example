.PHONY: help setup-git deploy-dev deploy-stage deploy-prod validate

help: ## Show help information
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup-git: ## Setup Git branch protection and hooks
	@echo "🔒 Setting up Git branch protection..."
	@chmod +x scripts/setup-branch-protection.sh
	@./scripts/setup-branch-protection.sh

deploy-dev: ## Deploy to development environment
	kubectl apply -f projects/dev/teama-dev.yaml
	kubectl apply -f apps/dev/hello-nginx.yaml

deploy-stage: ## Deploy to staging environment
	kubectl apply -f projects/stage/teama-stage.yaml
	kubectl apply -f apps/stage/hello-nginx.yaml

deploy-prod: ## Deploy to production environment
	kubectl apply -f projects/prod/teama-prod.yaml
	kubectl apply -f apps/prod/hello-nginx.yaml

deploy-all: ## Deploy to all environments
	$(MAKE) deploy-dev
	$(MAKE) deploy-stage
	$(MAKE) deploy-prod

validate: ## Validate YAML file format
	@echo "Validating Application files..."
	@for file in apps/*/*.yaml; do \
		echo "Checking $$file"; \
		kubectl apply --dry-run=client -f $$file; \
	done
	@echo "Validating Project files..."
	@for file in projects/*/*.yaml; do \
		echo "Checking $$file"; \
		kubectl apply --dry-run=client -f $$file; \
	done

clean: ## Clean all environments (use with caution)
	@echo "⚠️  This will delete all ArgoCD applications and projects"
	@read -p "Confirm to continue? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		kubectl delete -f apps/ --recursive; \
		kubectl delete -f projects/ --recursive; \
	else \
		echo "Operation cancelled"; \
	fi

status: ## View ArgoCD application status
	@echo "📊 ArgoCD Application Status:"
	@kubectl get applications -n argocd
	@echo ""
	@echo "📊 ArgoCD Project Status:"
	@kubectl get appprojects -n argocd

git-status: ## Show Git status and branch information
	@echo "🌿 Git Status:"
	@git status --short
	@echo ""
	@echo "🌿 Current Branch:"
	@git branch --show-current
	@echo ""
	@echo "🌿 Recent Commits:"
	@git log --oneline -5

git-cleanup: ## Clean up merged branches
	@echo "🧹 Cleaning up merged branches..."
	@git branch --merged | grep -v '\*\|main\|master\|develop' | xargs -n 1 git branch -d
	@echo "✅ Cleanup complete"

git-protect: ## Test branch protection (try to push to main)
	@echo "🔒 Testing branch protection..."
	@echo "Current branch: $$(git branch --show-current)"
	@if git branch --show-current | grep -E "^(main|master|prod|production)$$" > /dev/null; then \
		echo "❌ You are on a protected branch!"; \
		echo "Please switch to a feature branch before making changes."; \
		exit 1; \
	else \
		echo "✅ You are on a safe branch"; \
	fi 