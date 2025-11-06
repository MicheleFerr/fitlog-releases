#!/bin/bash
# 🔧 Install Pre-commit Hook for Memory Leak Prevention
#
# Usage:
# ./scripts/install_pre_commit_hook.sh

set -e

echo "🔧 Installing pre-commit hook..."

# Check if .git directory exists
if [ ! -d ".git" ]; then
  echo "❌ ERROR: .git directory not found"
  echo "   Run this script from the project root"
  exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy hook
cp scripts/pre-commit-hook.sh .git/hooks/pre-commit

# Make executable
chmod +x .git/hooks/pre-commit

echo "✅ Pre-commit hook installed successfully!"
echo ""
echo "📋 The hook will now run automatically before each commit to check for:"
echo "   - Direct Hive.openBox() calls (blocked)"
echo "   - Custom _isDisposed flags (warning)"
echo "   - box.close() without await (warning)"
echo "   - Hardcoded box names (warning)"
echo ""
echo "💡 To bypass the hook (not recommended):"
echo "   git commit --no-verify"
echo ""
echo "🗑️  To uninstall:"
echo "   rm .git/hooks/pre-commit"
