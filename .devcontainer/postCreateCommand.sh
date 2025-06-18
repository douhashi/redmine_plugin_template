#!/bin/bash

cd /workspace/src

# Get the repository name from git remote URL
REPO_NAME=$(git remote get-url origin | sed 's/.*\///' | sed 's/\.git$//')

# Fallback to directory name if git remote is not available
if [ -z "$REPO_NAME" ]; then
    REPO_NAME=$(basename "$PWD")
fi


ln -sf "/workspace/src/Gemfile.local" "/workspace/redmine/Gemfile.local"
echo "Created symlink: /workspace/src/Gemfile.local -> /workspace/redmine/Gemfile.local"

cd /workspace/redmine
bundle install

# Create symlink
ln -sf "/workspace/src" "/workspace/redmine/plugins/$REPO_NAME"
echo "Created symlink: /workspace/src -> /workspace/redmine/plugins/$REPO_NAME"

bin/rails db:setup