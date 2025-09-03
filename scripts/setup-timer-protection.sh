#!/bin/bash
# Setup Timer Architecture Protection

echo "🛡️  Setting up Timer Architecture Protection..."

# Create pre-commit hook that calls our timer guard
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# GymBro Pre-commit Hook with Timer Protection

# Run timer architecture guard
if [ -f ".githooks/timer-architecture-guard" ]; then
    ./.githooks/timer-architecture-guard
    if [ $? -ne 0 ]; then
        exit 1
    fi
fi

# Run existing pre-commit validations if they exist
if [ -f "Makefile" ] && grep -q "pre-commit" Makefile; then
    echo "🧪 Running pre-commit validations..."
    make pre-commit
fi
EOF

# Make pre-commit hook executable
chmod +x .git/hooks/pre-commit

echo "✅ Timer protection enabled!"
echo ""
echo "📋 What's protected:"
echo "• No new timer providers (max 3 allowed)"
echo "• No new iOS timer managers (max 1 allowed)" 
echo "• No new platform channels"
echo "• No timer class duplications"
echo ""
echo "🎯 To test: try committing a file named 'new_timer_provider.dart'"
echo "💡 See CLAUDE.md 'TIMER DEVELOPMENT RULES' for guidelines"