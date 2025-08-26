#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values using jq
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name')

# Get current directory name (basename)
dir_name=$(basename "$current_dir")

# Get git information
git_branch=""
git_dirty=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    git_status=$(git status --porcelain 2>/dev/null | wc -l)
    if [ "$git_status" -gt 0 ]; then
        git_dirty="✎$git_status"
    fi
fi

# Color codes matching Powerlevel10k style
# Using ANSI colors that work well with dimmed terminal
COLOR_DIR="\033[38;5;39m"      # Blue - current directory
COLOR_GIT="\033[38;5;114m"     # Green - git branch  
COLOR_DIRTY="\033[38;5;220m"    # Yellow - git dirty status
COLOR_MODEL="\033[38;5;250m"   # Light gray - model name
COLOR_STYLE="\033[38;5;244m"   # Dark gray - style
COLOR_TOKENS="\033[38;5;208m"  # Orange - token usage
COLOR_RESET="\033[0m"

# Build the status line
status=""

# Current directory
status+="${COLOR_DIR}${dir_name}${COLOR_RESET}"

# Git information
if [ -n "$git_branch" ]; then
    status+=" ${COLOR_GIT}${git_branch}${COLOR_RESET}"
    if [ -n "$git_dirty" ]; then
        status+=" ${COLOR_DIRTY}${git_dirty}${COLOR_RESET}"
    fi
fi

# Model information
status+=" ${COLOR_MODEL}${model_name}${COLOR_RESET}"

# Output style
status+=" ${COLOR_STYLE}(${output_style})${COLOR_RESET}"

# Note: Token usage information is not available in statusLine input
# This is a placeholder for future implementation

# Output the status line
echo -e "$status"