#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Colors
RESET="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
DIM="\033[2m"

# --- Helpers ---

# make_bar <percentage 0-100> <width> → "████░░░░"
make_bar() {
    local pct=$1
    local width=${2:-8}
    # clamp
    (( pct < 0 )) && pct=0
    (( pct > 100 )) && pct=100
    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    echo "$bar"
}

# color_for_pct <percentage> <yellow_threshold> <red_threshold>
color_for_pct() {
    local pct=$1 yellow=$2 red=$3
    if [ "$pct" -ge "$red" ]; then
        echo "$RED"
    elif [ "$pct" -ge "$yellow" ]; then
        echo "$YELLOW"
    else
        echo "$GREEN"
    fi
}

# --- Data extraction ---

# Model name: strip leading "Claude "
model_raw=$(echo "$input" | jq -r '.model.display_name // empty')
model_name=$(echo "$model_raw" | sed 's/^[Cc]laude //')

# Effort level
effort_str=""
settings_file="$HOME/.claude/settings.json"
if [ -f "$settings_file" ]; then
    effort=$(jq -r '.effortLevel // empty' "$settings_file" 2>/dev/null)
    if [ -n "$effort" ]; then
        case "$effort" in
            max)  effort_str=$(printf "${RED}%s${RESET}" "$effort") ;;
            high) effort_str=$(printf "${YELLOW}%s${RESET}" "$effort") ;;
            *)    effort_str=$(printf "${DIM}%s${RESET}" "$effort") ;;
        esac
    fi
fi

# Message count
msg_str=""
transcript=$(echo "$input" | jq -r '.transcript_path // empty')
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
    msg_count=$(wc -l < "$transcript" 2>/dev/null | tr -d ' ')
    if [ -n "$msg_count" ] && [ "$msg_count" -gt 0 ]; then
        if [ "$msg_count" -ge 100 ]; then
            msg_color="$RED"
        elif [ "$msg_count" -ge 50 ]; then
            msg_color="$YELLOW"
        else
            msg_color="$GREEN"
        fi
        msg_str=$(printf "${msg_color}%d msgs${RESET}" "$msg_count")
    fi
fi

# Session cost
cost_str=""
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost_usd" ]; then
    cost_cents=$(printf "%.0f" "$(echo "$cost_usd * 100" | bc 2>/dev/null || echo 0)")
    if [ "$cost_cents" -ge 800 ]; then
        cost_color="$RED"
    elif [ "$cost_cents" -ge 300 ]; then
        cost_color="$YELLOW"
    else
        cost_color="$GREEN"
    fi
    cost_str=$(printf "${cost_color}\$%.2f${RESET}" "$cost_usd")
fi

# Git branch
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Repo name
short_dir=$(basename "$cwd")

# Context used percentage
ctx_pct=""
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
if [ -n "$remaining" ]; then
    remaining_int=$(printf "%.0f" "$remaining")
    ctx_pct=$((100 - remaining_int))
fi

# Rate limits
five_hr_pct=""
five_hr=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$five_hr" ]; then
    five_hr_pct=$(printf "%.0f" "$five_hr")
fi

seven_day_pct=""
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$seven_day" ]; then
    seven_day_pct=$(printf "%.0f" "$seven_day")
fi

# --- Line 1: model effort | msgs | $cost | branch | repo ---
line1_parts=()
if [ -n "$model_name" ] && [ -n "$effort_str" ]; then
    line1_parts+=("$(printf "%s %s" "$model_name" "$effort_str")")
elif [ -n "$model_name" ]; then
    line1_parts+=("$model_name")
fi
[ -n "$msg_str" ] && line1_parts+=("$msg_str")
[ -n "$cost_str" ] && line1_parts+=("$cost_str")
[ -n "$branch" ] && line1_parts+=("$branch")
line1_parts+=("$short_dir")

line1=""
for part in "${line1_parts[@]}"; do
    if [ -z "$line1" ]; then
        line1="$part"
    else
        line1="${line1} | ${part}"
    fi
done

# --- Line 2: resource bars — Ctx, 5h, 7d ---
BAR_WIDTH=8
line2_parts=()

if [ -n "$ctx_pct" ]; then
    bar=$(make_bar "$ctx_pct" "$BAR_WIDTH")
    color=$(color_for_pct "$ctx_pct" 50 70)
    line2_parts+=("$(printf "Context ${color}%s${RESET}" "$bar")")
fi

if [ -n "$five_hr_pct" ]; then
    bar=$(make_bar "$five_hr_pct" "$BAR_WIDTH")
    color=$(color_for_pct "$five_hr_pct" 50 80)
    line2_parts+=("$(printf "5h ${color}%s${RESET}" "$bar")")
fi

if [ -n "$seven_day_pct" ]; then
    bar=$(make_bar "$seven_day_pct" "$BAR_WIDTH")
    color=$(color_for_pct "$seven_day_pct" 50 80)
    line2_parts+=("$(printf "7d ${color}%s${RESET}" "$bar")")
fi

line2=""
for part in "${line2_parts[@]}"; do
    if [ -z "$line2" ]; then
        line2="$part"
    else
        line2="${line2} | ${part}"
    fi
done

# Output both lines
if [ -n "$line2" ]; then
    printf "%s\n%s" "$line1" "$line2"
else
    printf "%s" "$line1"
fi
