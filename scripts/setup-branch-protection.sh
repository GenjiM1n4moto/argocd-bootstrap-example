#!/bin/bash

# Setup branch protection for Git repository
# This script configures branch protection rules and Git hooks

set -e

echo "🔒 Setting up branch protection..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Please run this script from a git repository root."
    exit 1
fi

# 1. Setup Git configuration
print_status "Setting up Git configuration..."

# Copy .gitconfig to repository
if [ -f .gitconfig ]; then
    cp .gitconfig .git/config.local
    print_status "Git configuration copied"
else
    print_warning ".gitconfig not found, skipping Git configuration"
fi

# 2. Setup pre-push hook
print_status "Setting up pre-push hook..."

if [ -f .git/hooks/pre-push ]; then
    chmod +x .git/hooks/pre-push
    print_status "Pre-push hook is ready"
else
    print_warning "Pre-push hook not found at .git/hooks/pre-push"
fi

# 3. Create branch protection documentation
print_status "Creating branch protection documentation..."

cat > BRANCH_PROTECTION.md << 'EOF'
# Branch Protection Guide

This repository has branch protection rules to ensure code quality and prevent accidental changes to protected branches.

## Protected Branches

The following branches are protected:
- `main` - Production-ready code
- `master` - Alternative main branch name
- `prod` - Production branch
- `production` - Production branch

## Workflow

### For New Features
1. Create a feature branch:
   ```bash
   git new-feature feature-name
   # or
   git checkout -b feature/feature-name
   ```

2. Make your changes and commit:
   ```bash
   git add .
   git commit -m "Add new feature"
   ```

3. Push to feature branch:
   ```bash
   git push origin feature/feature-name
   ```

4. Create a Pull Request to merge into main

### For Hotfixes
1. Create a hotfix branch:
   ```bash
   git new-hotfix hotfix-name
   # or
   git checkout -b hotfix/hotfix-name
   ```

2. Make your changes and commit:
   ```bash
   git add .
   git commit -m "Fix critical issue"
   ```

3. Push to hotfix branch:
   ```bash
   git push origin hotfix/hotfix-name
   ```

4. Create a Pull Request to merge into main

### For Releases
1. Create a release branch:
   ```bash
   git new-release release-name
   # or
   git checkout -b release/release-name
   ```

2. Make release-specific changes and commit:
   ```bash
   git add .
   git commit -m "Prepare release v1.0.0"
   ```

3. Push to release branch:
   ```bash
   git push origin release/release-name
   ```

4. Create a Pull Request to merge into main

## Branch Naming Conventions

- `feature/*` - New features
- `hotfix/*` - Critical bug fixes
- `release/*` - Release preparation
- `bugfix/*` - Non-critical bug fixes
- `chore/*` - Maintenance tasks

## Git Aliases

The following Git aliases are available:

- `git st` - Status
- `git co` - Checkout
- `git br` - Branch
- `git ci` - Commit
- `git cm "message"` - Commit with message
- `git lg` - Pretty log
- `git ll` - Pretty log all branches
- `git cleanup` - Clean up merged branches
- `git new-feature name` - Create feature branch
- `git new-hotfix name` - Create hotfix branch
- `git new-release name` - Create release branch

## Emergency Override

If you absolutely need to push directly to a protected branch:

1. **DO NOT DO THIS UNLESS ABSOLUTELY NECESSARY**
2. Temporarily rename the pre-push hook:
   ```bash
   mv .git/hooks/pre-push .git/hooks/pre-push.disabled
   ```
3. Make your push
4. Re-enable the hook:
   ```bash
   mv .git/hooks/pre-push.disabled .git/hooks/pre-push
   ```

## Troubleshooting

### Hook not working
Make sure the hook is executable:
```bash
chmod +x .git/hooks/pre-push
```

### Hook blocking legitimate pushes
Check if you're on a protected branch:
```bash
git branch
```

### Need to bypass hook temporarily
```bash
git push --no-verify
```
**Warning**: This bypasses all pre-push hooks, not just branch protection.
EOF

print_status "Branch protection documentation created"

# 4. Create .gitignore for sensitive files
print_status "Updating .gitignore..."

cat >> .gitignore << 'EOF'

# Git configuration
.gitconfig.local

# Temporary files
*.tmp
*.temp

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Environment files
.env
.env.local
.env.*.local

# Backup files
*.bak
*.backup
EOF

print_status ".gitignore updated"

# 5. Setup commit message template
print_status "Setting up commit message template..."

cat > .gitmessage << 'EOF'
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>

# Types:
#   feat     (new feature for the user, not a new feature for build script)
#   fix      (bug fix for the user, not a fix to a build script)
#   docs     (changes to the documentation)
#   style    (formatting, missing semi colons, etc; no production code change)
#   refactor (refactoring production code, eg. renaming a variable)
#   test     (adding missing tests, refactoring tests; no production code change)
#   chore    (updating grunt tasks etc; no production code change)

# Scopes:
#   app, web, api, db, etc.

# Subject:
#   - use imperative, present tense: "change" not "changed" nor "changes"
#   - don't capitalize first letter
#   - no dot (.) at the end

# Body:
#   - use imperative, present tense: "change" not "changed" nor "changes"
#   - include motivation for the change and contrast with previous behavior

# Footer:
#   - breaking changes
#   - issues this commit closes, e.g. "Closes #123"
#   - co-authors, e.g. "Co-authored-by: John Doe <john@example.com>"

# Examples:
# feat(api): add user authentication endpoint
#
# Add new POST /auth/login endpoint to handle user authentication.
# Returns JWT token on successful authentication.
#
# Closes #123
# Co-authored-by: Jane Smith <jane@example.com>
EOF

# Set the commit template
git config commit.template .gitmessage

print_status "Commit message template configured"

# 6. Setup remote tracking
print_status "Setting up remote tracking..."

# Get current branch
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# Set upstream for current branch
if [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
    git push --set-upstream origin "$current_branch" 2>/dev/null || print_warning "Could not set upstream for $current_branch"
fi

print_status "Branch protection setup complete!"

echo ""
echo "📋 Summary of what was configured:"
echo "  ✅ Pre-push hook to prevent direct pushes to protected branches"
echo "  ✅ Git configuration with useful aliases"
echo "  ✅ Branch protection documentation"
echo "  ✅ Updated .gitignore"
echo "  ✅ Commit message template"
echo ""
echo "🔒 Protected branches: main, master, prod, production"
echo ""
echo "📖 See BRANCH_PROTECTION.md for detailed workflow instructions" 