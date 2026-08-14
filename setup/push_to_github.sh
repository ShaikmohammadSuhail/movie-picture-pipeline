#!/usr/bin/env bash
#
# push_to_github.sh
#
# Prepares the project as a git repository and pushes it to a public GitHub repo.
#
# HOW TO USE (run from the Windows side, e.g. Git Bash or WSL):
#
#   1. Create an empty PUBLIC repository on https://github.com (no README, no
#      .gitignore — this project already has both).
#   2. Copy your repo URL. It should look like:
#        https://github.com/YOUR_GITHUB_USERNAME/movie-picture-pipeline.git
#   3. Run this script and paste your URL when prompted:
#        ./setup/push_to_github.sh
#
# The script will initialize git, commit all project files, add your remote,
# and push to the main branch. The repository must be public for reviewers.
set -euo pipefail

if [[ "$(pwd)" != *movie-picture-pipeline ]]; then
  echo "ERROR: run this script from the PROJECT ROOT (movie-picture-pipeline/)."
  exit 1
fi

if [[ -d .git ]]; then
  echo "Git already initialized in this folder."
else
  echo "Initializing git repository ..."
  git init
fi

git config user.name "Udacity Student"
git config user.email "student@udacity.com"

echo "Staging all project files ..."
git add .

echo "Creating initial commit ..."
git commit -m "Movie Picture Pipeline: CI/CD with GitHub Actions (frontend + backend)" || true

echo
echo "Enter your PUBLIC GitHub repository URL (e.g. https://github.com/user/movie-picture-pipeline.git):"
read -r -p "> " repo_url

if [[ -z "${repo_url}" ]]; then
  echo "No URL provided. Add the remote and push manually with:"
  echo "  git remote add origin <url>"
  echo "  git branch -M main"
  echo "  git push -u origin main"
  exit 1
fi

git remote add origin "${repo_url}" || git remote set-url origin "${repo_url}"
git branch -M main
echo "Pushing to ${repo_url} ..."
git push -u origin main

echo
echo "Done! Your repository is now public at: ${repo_url}"
echo "Next: add your GitHub Actions secrets and run the workflows (see README)."