#!/bin/bash
# 🔐 Secure Debug Run Script
#
# This script loads environment variables from .env and passes them
# to Flutter via --dart-define flags, avoiding bundling secrets in the app.
#
# Usage:
#   ./scripts/run_debug.sh           # Run on default device
#   ./scripts/run_debug.sh -d all    # Run on all devices
#   ./scripts/run_debug.sh --release # Build release with secrets
#
# SECURITY: This approach ensures .env is NEVER bundled in the app binary.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/.env"

# Check if .env exists
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: .env file not found at $ENV_FILE"
    echo ""
    echo "Create .env from .env.example:"
    echo "  cp .env.example .env"
    echo "  # Then fill in your Firebase credentials"
    exit 1
fi

# Load environment variables from .env
echo "🔐 Loading environment from .env..."
export $(grep -v '^#' "$ENV_FILE" | xargs)

# Build dart-define flags
DART_DEFINES=""

# Firebase iOS
[ -n "$FIREBASE_API_KEY_IOS" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_API_KEY_IOS=$FIREBASE_API_KEY_IOS"
[ -n "$FIREBASE_APP_ID_IOS" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_APP_ID_IOS=$FIREBASE_APP_ID_IOS"
[ -n "$FIREBASE_MESSAGING_SENDER_ID_IOS" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_MESSAGING_SENDER_ID_IOS=$FIREBASE_MESSAGING_SENDER_ID_IOS"
[ -n "$FIREBASE_PROJECT_ID_IOS" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_PROJECT_ID_IOS=$FIREBASE_PROJECT_ID_IOS"
[ -n "$FIREBASE_STORAGE_BUCKET_IOS" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_STORAGE_BUCKET_IOS=$FIREBASE_STORAGE_BUCKET_IOS"

# Firebase Android
[ -n "$FIREBASE_API_KEY_ANDROID" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_API_KEY_ANDROID=$FIREBASE_API_KEY_ANDROID"
[ -n "$FIREBASE_APP_ID_ANDROID" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_APP_ID_ANDROID=$FIREBASE_APP_ID_ANDROID"
[ -n "$FIREBASE_MESSAGING_SENDER_ID_ANDROID" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_MESSAGING_SENDER_ID_ANDROID=$FIREBASE_MESSAGING_SENDER_ID_ANDROID"
[ -n "$FIREBASE_PROJECT_ID_ANDROID" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_PROJECT_ID_ANDROID=$FIREBASE_PROJECT_ID_ANDROID"
[ -n "$FIREBASE_STORAGE_BUCKET_ANDROID" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_STORAGE_BUCKET_ANDROID=$FIREBASE_STORAGE_BUCKET_ANDROID"

# Firebase Web (optional)
[ -n "$FIREBASE_API_KEY_WEB" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_API_KEY_WEB=$FIREBASE_API_KEY_WEB"
[ -n "$FIREBASE_APP_ID_WEB" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_APP_ID_WEB=$FIREBASE_APP_ID_WEB"
[ -n "$FIREBASE_MESSAGING_SENDER_ID_WEB" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_MESSAGING_SENDER_ID_WEB=$FIREBASE_MESSAGING_SENDER_ID_WEB"
[ -n "$FIREBASE_PROJECT_ID_WEB" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_PROJECT_ID_WEB=$FIREBASE_PROJECT_ID_WEB"
[ -n "$FIREBASE_STORAGE_BUCKET_WEB" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_STORAGE_BUCKET_WEB=$FIREBASE_STORAGE_BUCKET_WEB"
[ -n "$FIREBASE_MEASUREMENT_ID_WEB" ] && DART_DEFINES="$DART_DEFINES --dart-define=FIREBASE_MEASUREMENT_ID_WEB=$FIREBASE_MEASUREMENT_ID_WEB"

# Environment
[ -n "$ENV" ] && DART_DEFINES="$DART_DEFINES --dart-define=ENV=$ENV"

# Third-party (optional)
[ -n "$OPENAI_API_KEY" ] && DART_DEFINES="$DART_DEFINES --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY"
[ -n "$STRIPE_PUBLISHABLE_KEY" ] && DART_DEFINES="$DART_DEFINES --dart-define=STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY"

echo "✅ Environment loaded"
echo ""
echo "📱 Running Flutter with secure environment injection..."
echo ""

# Run Flutter with all arguments passed through
cd "$PROJECT_ROOT"
flutter run $DART_DEFINES "$@"
