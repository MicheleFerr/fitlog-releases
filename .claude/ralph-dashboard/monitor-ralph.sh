#!/bin/bash

# Real-Time Ralph Loop Monitor
# Monitora output Ralph e aggiorna status.json in tempo reale

set -e

PROJECT_ROOT="/Users/michele/gymbro_flutter_new"
DASHBOARD_DIR="$PROJECT_ROOT/.claude/ralph-dashboard"
STATUS_FILE="$DASHBOARD_DIR/status.json"
LOG_FILE="$DASHBOARD_DIR/ralph-output.log"

cd "$PROJECT_ROOT"

echo "🔄 Real-Time Ralph Monitor Started"
echo "📊 Dashboard: file://$DASHBOARD_DIR/index.html"
echo "📝 Logging to: $LOG_FILE"
echo ""
echo "Press Ctrl+C to stop monitoring"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Initialize status.json
cat > "$STATUS_FILE" << 'EOF'
{
  "lastUpdate": "",
  "iteration": 0,
  "phase": "Starting...",
  "completedTasks": [],
  "inProgressTasks": [],
  "blockedTasks": [],
  "recentActivity": []
}
EOF

# Function to update status
update_status() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local iteration=$1
    local phase="$2"
    local completed="$3"

    # Run checks to get real status
    local icons_status="todo"
    local colors_status="todo"
    local analyze_status="todo"

    # Quick checks
    if ! grep -r "Icons\." lib/features/ --include="*.dart" 2>/dev/null | grep -q .; then
        icons_status="done"
        completed+=",\"check_icons\""
    fi

    if ! grep -r "Colors\." lib/features/ --include="*.dart" 2>/dev/null | grep -q .; then
        colors_status="done"
        completed+=",\"check_colors\""
    fi

    if flutter analyze 2>&1 | grep -q "No issues found"; then
        analyze_status="done"
        completed+=",\"flutter_analyze\""
    fi

    # Update JSON
    cat > "$STATUS_FILE" << EOF
{
  "lastUpdate": "$timestamp",
  "iteration": $iteration,
  "phase": "$phase",
  "completedTasks": [$completed],
  "inProgressTasks": [],
  "blockedTasks": [],
  "stats": {
    "icons_check": "$icons_status",
    "colors_check": "$colors_status",
    "analyze_check": "$analyze_status"
  }
}
EOF
}

# Monitor loop
ITERATION=0
PHASE="Initializing"

while true; do
    ITERATION=$((ITERATION + 1))

    # Check if Ralph is running (look for recent git activity or file changes)
    if [ -d ".git" ]; then
        RECENT_COMMITS=$(git log --oneline --since="5 minutes ago" | wc -l | tr -d ' ')

        if [ "$RECENT_COMMITS" -gt 0 ]; then
            PHASE="Building (Active)"
            LAST_COMMIT=$(git log --oneline -1 --pretty=format:"%s")
            echo "[$ITERATION] 🔨 Ralph active: $LAST_COMMIT"
        else
            PHASE="Idle"
            echo "[$ITERATION] 💤 No recent activity"
        fi
    fi

    # Update status
    update_status "$ITERATION" "$PHASE" '""'

    # Sleep 10 seconds
    sleep 10
done
