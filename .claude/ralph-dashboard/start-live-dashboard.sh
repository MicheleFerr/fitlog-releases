#!/bin/bash

# Start Live Dashboard
# Lancia il monitor real-time e apre la dashboard nel browser

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "🚀 Starting FitLog Production Readiness Live Dashboard"
echo ""

# Make scripts executable
chmod +x "$SCRIPT_DIR/monitor-ralph.sh"
chmod +x "$SCRIPT_DIR/check-status.sh"

# Open dashboard in browser
echo "📊 Opening dashboard in browser..."
open "$SCRIPT_DIR/index.html"

sleep 2

# Start monitor (this blocks, so run in foreground)
echo ""
echo "🔄 Starting real-time monitor..."
echo "   Dashboard will auto-refresh every 10 seconds"
echo "   Press Ctrl+C to stop"
echo ""

"$SCRIPT_DIR/monitor-ralph.sh"
