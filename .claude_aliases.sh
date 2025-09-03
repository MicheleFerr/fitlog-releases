#!/bin/bash
# Claude Code Productivity Aliases for GymBro
# Add to your shell: source .claude_aliases.sh

# Quick validation
alias gym-check="flutter analyze && ./scripts/find_hardcoded_strings.sh"
alias gym-fix="dart fix --apply && flutter gen-l10n"
alias gym-test="flutter test"
alias gym-commit="make pre-commit"

# iOS specific
alias gym-ios="cd ios && pod install && cd .. && flutter build ios --no-codesign"
alias gym-ios-clean="cd ios && rm -rf Pods build && pod install && cd .."

# Firebase
alias gym-firebase-deploy="firebase deploy --only firestore:rules"
alias gym-firebase-test="npm run test:firestore"

# Quick navigation
alias gym-workout="cd lib/features/workout"
alias gym-timer="cd lib/features/timer"
alias gym-shared="cd lib/shared"

# Development
alias gym-watch="flutter run --hot"
alias gym-profile="flutter run --profile"
alias gym-release="flutter run --release"

# Cleanup
alias gym-clean="flutter clean && cd ios && pod install && cd .."
alias gym-deep-clean="flutter clean && rm -rf ios/Pods ios/build build .dart_tool"

echo "✅ GymBro aliases loaded! Type 'gym-' and tab to see all commands"