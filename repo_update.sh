#!/bin/bash

GITHUB_USERNAME="your user name"
GH_TOKEN="your github token"
REPO_PREFIX="your repo prefix"
FILE_PATH="file path"
NEW_CONTENT="your new content"
COMMIT_MESSAGE="your commit message"

# Export the GitHub token for authentication
export GH_TOKEN=$GH_TOKEN

# Fetch all repository names starting with 'Repo_prefix'
repos=$(gh repo list $GITHUB_USERNAME --limit 700 --json name --jq '.[] | select(.name | startswith("'$REPO_PREFIX'")) | .name')

for repo in $repos; do
    echo "Processing $repo"
    
    # Clone the repository using the token for authentication
    git clone "https://$GH_TOKEN@github.com/$GITHUB_USERNAME/$repo.git"
    cd $repo
    
    # Check if the file exists
    if [ -f "$FILE_PATH" ]; then
        # Insert new content after the line containing 'xyz'
        awk -v new_content="$NEW_CONTENT" '/xyz/ {print; print new_content; next}1' "$FILE_PATH" > temp && mv temp "$FILE_PATH"
        
        # Add, commit, and push changes
        git add "$FILE_PATH"
        git commit -m "$COMMIT_MESSAGE"
        git push origin main
    else
        echo "$FILE_PATH does not exist in $repo"
    fi
    
    # Go back to the parent directory and remove the repo directory
    cd ..
    rm -rf $repo
done

echo "Update complete for all repositories."
