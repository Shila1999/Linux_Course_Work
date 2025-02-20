#!/bin/bash

LOG_FILE="commit_log.txt"
CSV_FILE="tasks.csv"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Ensure we're inside a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log "ERROR: This is not a Git repository."
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
log "Current branch: $CURRENT_BRANCH"

# Check if branch exists in CSV file
BUG_DETAILS=$(grep "$CURRENT_BRANCH" "$CSV_FILE")
if [ -z "$BUG_DETAILS" ]; then
    log "ERROR: No matching branch found in $CSV_FILE."
    exit 1
fi

# Extract details from CSV
BUG_ID=$(echo "$BUG_DETAILS" | cut -d',' -f1)
DESCRIPTION=$(echo "$BUG_DETAILS" | cut -d',' -f2)
DEVELOPER=$(echo "$BUG_DETAILS" | cut -d',' -f4)
PRIORITY=$(echo "$BUG_DETAILS" | cut -d',' -f5)

# Get user-supplied commit description
DEV_COMMENT=$1
if [ -z "$DEV_COMMENT" ]; then
    log "ERROR: No developer comment provided."
    exit 1
fi

# Format commit message
CURRENT_DATETIME=$(date '+%Y-%m-%d %H:%M:%S')
COMMIT_MESSAGE="BugID:$BUG_ID DateTime:$CURRENT_DATETIME Branch:$CURRENT_BRANCH Dev:$DEVELOPER Priority:$PRIORITY Desc:$DESCRIPTION DevDesc:$DEV_COMMENT"

log "Commit message: $COMMIT_MESSAGE"

# Stage all changes
git add .
log "Staged all changes."

# Commit changes
git commit -m "$COMMIT_MESSAGE"
log "Committed changes."

# Push to remote
git push origin "$CURRENT_BRANCH"
log "Pushed changes to remote repository."

