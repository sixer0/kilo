---
task: github-repo-creation
date: 2026-05-16
agent: data-analyst-free
type: implementation-plan
confidence: HIGH
task_file: output/analysis/2026-05-16_github-repo-creation.md
---

# Implementation Plan: Create GitHub Repository 'kilo-workflow'

## Overview

Create a new GitHub repository named `kilo-workflow` and push initial files to it. The workflow involves installing the GitHub CLI (`gh`) via `winget`, authenticating with GitHub, creating the repository on GitHub, and publishing a local directory with a README.

---

## Preconditions

| Item | Status | Notes |
|------|--------|-------|
| `git` installed | ✅ Verified | Already installed |
| `gh` CLI installed | ❌ Missing | Will be installed via `winget` |
| `winget` installed | ✅ Verified | Already installed |
| GitHub account access | ⚠️ Assumed | User confirmed VSCode is connected to GitHub |
| Internet connectivity | ⚠️ Assumed | Required for all steps |

---

## Step-by-Step Implementation Plan

### Phase 1 — Install `gh` CLI via `winget`

**Commands:**

```powershell
# Search for the GitHub CLI package to confirm the exact package name
winget search GitHub.cli

# Install the GitHub CLI
winget install GitHub.cli --accept-package-agreements --accept-source-agreements

# Verify installation
gh --version
```

**Expected output of `gh --version`:**
```
gh version 2.x.x ...
```

**If installation succeeds:** Proceed to Phase 2.
**If installation fails:** Run `winget upgrade GitHub.cli` or retry `winget install GitHub.cli`.

---

### Phase 2 — Authenticate with GitHub (`gh auth login`)

Authentication is **interactive** by default, but can be made non-interactive using a Personal Access Token (PAT). Two authentication paths are planned below.

#### Path A — Interactive (Preferred if running in a terminal session):

```powershell
gh auth login
```

Follow the prompts:
1. **What account do you want to log into?** → `GitHub.com`
2. **What is your preferred protocol for Git operations?** → `HTTPS`
3. **Authenticate Git with your GitHub credentials?** → `Yes`
4. **How would you like to authenticate?** → `Paste an authentication token` (recommended for VSCode-connected accounts — generates a PAT on GitHub)

#### Path B — Non-Interactive (Preferred for agent/scripted execution):

```powershell
# Set a GitHub Personal Access Token (PAT) with 'repo' scope
# Obtain token from: https://github.com/settings/tokens
$env:GH_TOKEN = "ghp_<your_personal_access_token_here>"

# Authenticate using the token
echo $env:GH_TOKEN | gh auth login --with-token

# Verify authentication
gh auth status
```

**Required PAT scopes:** `repo` (full control of private repositories)

**Expected output of `gh auth status`:**
```
github.com
  ✓ Logged in to github.com as <USERNAME> (OAuth)
  - Token: <TOKEN_PREFIX>...
  - Token scopes: repo, workflow, etc.
```

---

### Phase 3 — Create the Repository `kilo-workflow` on GitHub

```powershell
# Create the repository under the authenticated user's account
gh repo create kilo-workflow --public --description "Kilo workflow tools and configurations" --source=. --remote

# Flags explained:
#   --public          : Creates a public repository (use --private for private)
#   --description     : Repository description
#   --source=.        : Use current directory as source (will init git if needed)
#   --remote          : Adds the remote 'origin' automatically
```

**Expected output:**
```
✓ Created repository <USERNAME>/kilo-workflow on GitHub
✓ Added remote https://github.com/<USERNAME>/kilo-workflow.git
```

**Verify repository creation:**
```powershell
gh repo view kilo-workflow --web  # Opens in browser
gh repo list                     # Lists all user repositories
```

---

### Phase 4 — Initialize Local Directory and Push

If a local directory for the project does not exist, create one. Then initialize git, create a README, commit, and push.

```powershell
# Create and navigate to the working directory
mkdir ~/kilo-workflow
cd ~/kilo-workflow

# Initialise the git repository
git init

# Create a README file
@"
# kilo-workflow

This repository contains workflow tools and configurations for the Kilo project management system.

## Contents

- Workflow automation scripts
- Configuration templates
- Documentation

---
*Generated: 2026-05-16*
"@ | Set-Content -Path "README.md" -Encoding UTF8

# Configure git user (if not already set globally)
git config user.name "<GITHUB_USERNAME>"
git config user.email "<GITHUB_EMAIL>"

# Stage and commit the README
git add README.md
git commit -m "Initial commit: add README"

# Add the GitHub repository as the remote 'origin'
git remote add origin https://github.com/<GITHUB_USERNAME>/kilo-workflow.git

# Rename the default branch to 'main' (GitHub standard)
git branch -M main

# Push to GitHub
git push -u origin main
```

---

## Verification Steps

After all phases complete, run the following verification commands:

```powershell
# 1. Verify gh CLI is installed
gh --version
# Expected: gh version 2.x.x ...

# 2. Verify authentication
gh auth status
# Expected: ✓ Logged in to github.com as <USERNAME>

# 3. Verify repository exists on GitHub
gh repo view kilo-workflow
# Expected: Full repository info displayed

# 4. Verify local repo is linked correctly
git remote -v
# Expected: origin  https://github.com/<USERNAME>/kilo-workflow.git (fetch)
#            origin  https://github.com/<USERNAME>/kilo-workflow.git (push)

# 5. Verify the push succeeded
git log --oneline
# Expected: At least one commit (the initial README commit)

# 6. Open the repository in a browser
gh repo view kilo-workflow --web
# Expected: https://github.com/<USERNAME>/kilo-workflow opens in default browser
```

---

## Failure Handling

| Scenario | Detection | Recovery |
|----------|-----------|----------|
| `winget install` fails | `gh --version` not found | Retry with admin PowerShell or download `gh` manually from GitHub releases |
| `gh auth login` fails | `gh auth status` shows not logged in | Verify PAT has `repo` scope; regenerate and retry |
| Repository already exists | `gh repo create` errors with `name already exists` | Use `gh repo create kilo-workflow --private --confirm` or pick a new name |
| `git push` is rejected | Remote contains work not in local | Run `git pull --rebase origin main` then retry `git push` |
| Network error during push | `git push` times out | Check internet, retry; GitHub may be temporarily unavailable |

---

## Agent Delegation Summary

| Phase | Responsibility | Deliverable |
|-------|---------------|-------------|
| Phase 1 | Installer Agent | `gh` CLI installed and verified |
| Phase 2 | Auth Agent | GitHub authentication confirmed via `gh auth status` |
| Phase 3 | GitHub Agent | Repository `kilo-workflow` created on GitHub |
| Phase 4 | Dev Agent | Local directory initialized, README created, files pushed to GitHub |
| Verify | All agents | All verification commands return success |

---

## Notes for Executing Agent

- Replace `<GITHUB_USERNAME>`, `<GITHUB_EMAIL>`, and `<TOKEN>` placeholders with actual values.
- If the user is connected to VSCode with GitHub SSO, check for existing GitHub credentials before attempting `gh auth login`:
  ```powershell
  # Check for existing GitHub-credential helper tokens
  git credential-manager-core get
  ```
- The `--with-token` path is **strongly preferred** over interactive login to avoid blocking on interactive prompts.
- The repository should be created under the **authenticated user's personal account**, not an organization, unless specified otherwise.
