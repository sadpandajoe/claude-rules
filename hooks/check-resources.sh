#!/bin/bash
#
# check-resources.sh — Claude Code PreToolUse hook
#
# Warns when test runners are invoked with constrained resources.
# Advisory only: always exits 0 (never blocks).
#
# Exit codes:
#   0 — always (warnings go to stderr as model context)
#

set -euo pipefail

# Always allow — this hook only warns
trap 'exit 0' ERR

# Read JSON from stdin
INPUT=$(cat)

# Extract command (fail silently if jq unavailable)
if ! command -v jq &>/dev/null; then
    exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0

# Skip if worker limit already specified
if echo "$COMMAND" | grep -qE '\-\-maxWorkers|\-n [0-9]|\-w [0-9]|--workers'; then
    exit 0
fi

# Check Docker container count (bounded probe — avoid hanging on wedged daemon)
DOCKER_COUNT=0
if command -v docker &>/dev/null; then
    if command -v gtimeout &>/dev/null; then
        DOCKER_COUNT=$(gtimeout 2 docker ps -q 2>/dev/null | wc -l | tr -d ' ') || DOCKER_COUNT=0
    elif command -v timeout &>/dev/null; then
        DOCKER_COUNT=$(timeout 2 docker ps -q 2>/dev/null | wc -l | tr -d ' ') || DOCKER_COUNT=0
    else
        # No timeout utility — run in background with manual kill to avoid hanging
        docker ps -q > /tmp/.cc_docker_count 2>/dev/null &
        DOCKER_PID=$!
        ( sleep 2 && kill $DOCKER_PID 2>/dev/null ) &
        wait $DOCKER_PID 2>/dev/null
        DOCKER_COUNT=$(wc -l < /tmp/.cc_docker_count 2>/dev/null | tr -d ' ') || DOCKER_COUNT=0
        rm -f /tmp/.cc_docker_count
    fi
fi

# Warn if Docker is heavy
if [[ "$DOCKER_COUNT" -gt 2 ]]; then
    echo "Warning: $DOCKER_COUNT Docker containers running. Consider adding --maxWorkers=2 to prevent OOM." >&2
fi

exit 0
