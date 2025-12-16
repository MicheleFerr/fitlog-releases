#!/bin/bash
# FitLog Context Loader
# Gathers project state for session start

set -e

echo ""
echo "=========================================="
echo "   FitLog Copilot - Session Context"
echo "=========================================="
echo ""

# ============================================
# 1. Git Status
# ============================================
echo "Git Status:"
echo "-------------------------------------------"

# Current branch
branch=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "  Branch: $branch"

# Last commit
last_commit=$(git log -1 --format='%h - %s (%cr)' 2>/dev/null || echo "unknown")
echo "  Last commit: $last_commit"

# Uncommitted changes
changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [ "$changes" -gt 0 ]; then
    echo "  Uncommitted changes: $changes files"

    # Show modified files (max 5)
    echo "  Modified files:"
    git status --porcelain 2>/dev/null | head -5 | while read -r line; do
        echo "    $line"
    done
    if [ "$changes" -gt 5 ]; then
        echo "    ... and $((changes - 5)) more"
    fi
else
    echo "  Working tree: clean"
fi

echo ""

# ============================================
# 2. Recent Activity (last 5 commits)
# ============================================
echo "Recent Commits:"
echo "-------------------------------------------"
git log --oneline -5 2>/dev/null | while read -r line; do
    echo "  $line"
done
echo ""

# ============================================
# 3. Recently Modified Files
# ============================================
echo "Recently Modified Files (last 24h):"
echo "-------------------------------------------"
find lib -name "*.dart" -mtime -1 -type f 2>/dev/null | head -10 | while read -r file; do
    echo "  $file"
done
recent_count=$(find lib -name "*.dart" -mtime -1 -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$recent_count" -gt 10 ]; then
    echo "  ... and $((recent_count - 10)) more"
elif [ "$recent_count" -eq 0 ]; then
    echo "  (none)"
fi
echo ""

# ============================================
# 4. TODO/FIXME in recent files
# ============================================
echo "TODOs in recently modified files:"
echo "-------------------------------------------"
todo_count=0
while IFS= read -r file; do
    todos=$(grep -n "TODO\|FIXME" "$file" 2>/dev/null || true)
    if [ -n "$todos" ]; then
        echo "  $file:"
        echo "$todos" | head -3 | while read -r line; do
            echo "    $line"
        done
        todo_count=$((todo_count + 1))
    fi
done < <(find lib -name "*.dart" -mtime -1 -type f 2>/dev/null | head -5)

if [ $todo_count -eq 0 ]; then
    echo "  (none found)"
fi
echo ""

# ============================================
# 5. Check for context file from previous session
# ============================================
if [ -f ".fitlog-context.md" ]; then
    echo "Previous Session Context (.fitlog-context.md):"
    echo "-------------------------------------------"
    head -20 .fitlog-context.md
    lines=$(wc -l < .fitlog-context.md | tr -d ' ')
    if [ "$lines" -gt 20 ]; then
        echo "  ... ($((lines - 20)) more lines)"
    fi
    echo ""
fi

# ============================================
# 6. Quick Health Check (fast version)
# ============================================
echo "Quick Health Check:"
echo "-------------------------------------------"

# Check for stale files
stale=$(find lib -name "*.dart" 2>/dev/null | grep -E "(old_|temp_|deprecated_)" | wc -l | tr -d ' ')
if [ "$stale" -gt 0 ]; then
    echo "  Potential stale files: $stale"
fi

# Check for duplicate names
dups=$(find lib -name "*.dart" -exec basename {} \; 2>/dev/null | sort | uniq -d | wc -l | tr -d ' ')
if [ "$dups" -gt 0 ]; then
    echo "  Duplicate file names: $dups"
fi

if [ "$stale" -eq 0 ] && [ "$dups" -eq 0 ]; then
    echo "  All clear!"
fi

echo ""
echo "=========================================="
echo "   Ready to code!"
echo "=========================================="
echo ""
echo "Tip: Use /fitlog <task> for tool suggestions"
echo ""
