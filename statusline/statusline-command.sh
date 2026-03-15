#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Model name: strip leading "Claude " and keep sentence case, e.g. "Claude Opus 4.6" -> "Opus 4.6"
model_raw=$(echo "$input" | jq -r '.model.display_name // empty')
model_name=$(echo "$model_raw" | sed 's/^[Cc]laude //')

# Get current directory (last component only)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
short_dir=$(basename "$cwd")

# Get git branch
branch_str=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        branch_str="Branch: $branch"
    fi
fi

# Color-coded context used percentage
# Green: used < 50% (remaining > 50%), Yellow: used >= 50% (remaining <= 50%), Red: used >= 70% (remaining <= 30%)
RESET="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"

context_str=""
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
if [ -n "$remaining" ]; then
    remaining_int=$(printf "%.0f" "$remaining")
    used_int=$((100 - remaining_int))
    if [ "$used_int" -ge 70 ]; then
        color="$RED"
    elif [ "$used_int" -ge 50 ]; then
        color="$YELLOW"
    else
        color="$GREEN"
    fi
    context_str=$(printf "${color}Context: %d%%${RESET}" "$used_int")
fi

# Output format: "Model | Context: XX% | Branch: <branch> | Directory: <dir>"
parts=()
[ -n "$model_name" ] && parts+=("$model_name")
[ -n "$context_str" ] && parts+=("$context_str")
[ -n "$branch_str" ] && parts+=("$branch_str")
parts+=("Directory: $short_dir")

# Join parts with " | "
result=""
for part in "${parts[@]}"; do
    if [ -z "$result" ]; then
        result="$part"
    else
        result="${result} | ${part}"
    fi
done

printf "%s" "$result"
