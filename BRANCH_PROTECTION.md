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
