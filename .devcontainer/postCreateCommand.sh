#!/bin/bash

cd /workspace/src

# Get the repository name from git remote URL
REPO_NAME=$(git remote get-url origin | sed 's/.*\///' | sed 's/\.git$//')

# Fallback to directory name if git remote is not available
if [ -z "$REPO_NAME" ]; then
    REPO_NAME=$(basename "$PWD")
fi

# Create symlink in Redmine plugins directory
ln -sf "$PWD" "/workspace/redmine/plugins/$REPO_NAME"

echo "Created symlink: $PWD -> /workspace/redmine/plugins/$REPO_NAME"

cd /workspace/redmine