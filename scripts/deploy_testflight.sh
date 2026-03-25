#!/bin/bash

# 🚀 Deploy GymBro TrackLog to TestFlight
# Usage: ./scripts/deploy_testflight.sh [apple_id] [app_password] [team_id]
#    or APPLE_ID=... APP_PASSWORD=... APPLE_TEAM_ID=... ./scripts/deploy_testflight.sh

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/.env"

# Credenziali Apple da env o parametri CLI.
APPLE_ID="${APPLE_ID:-}"
APP_PASSWORD="${APP_PASSWORD:-}"
TEAM_ID="${APPLE_TEAM_ID:-${TEAM_ID:-}}"

load_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${YELLOW}⚠️ .env non trovato in $ENV_FILE - userò solo le variabili già esportate${NC}"
        return
    fi

    echo -e "${BLUE}🔐 Loading environment from .env...${NC}"
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
}

append_dart_define() {
    local key="$1"
    local value="$2"
    if [ -n "$value" ]; then
        DART_DEFINE_ARGS+=("--dart-define=${key}=${value}")
    fi
}

validate_required_release_env() {
    if [ -z "${REVENUECAT_API_KEY:-}" ]; then
        echo -e "${RED}❌ Missing REVENUECAT_API_KEY for release build.${NC}"
        echo -e "${YELLOW}   Add it to .env or export it before running this script.${NC}"
        exit 1
    fi
}

load_env_file

# Opzionale: usa parametri se forniti (override delle credenziali da env)
if [ "$#" -ge 3 ]; then
    APPLE_ID="$1"
    APP_PASSWORD="$2"
    TEAM_ID="$3"
    echo -e "${YELLOW}🔧 Using provided credentials...${NC}"
else
    echo -e "${YELLOW}🔧 Using Apple credentials from environment...${NC}"
fi

if [ -z "$APPLE_ID" ] || [ -z "$APP_PASSWORD" ] || [ -z "$TEAM_ID" ]; then
    echo -e "${RED}❌ Missing Apple credentials.${NC}"
    echo -e "${YELLOW}   Provide [apple_id] [app_password] [team_id] or export APPLE_ID, APP_PASSWORD, APPLE_TEAM_ID.${NC}"
    exit 1
fi

echo -e "${BLUE}🔥 Starting TestFlight deployment for GymBro TrackLog...${NC}"
echo -e "${YELLOW}📋 Using Apple ID: $APPLE_ID${NC}"
echo -e "${YELLOW}🏢 Using Team ID: $TEAM_ID${NC}"

ENVIRONMENT="${ENV:-production}"
if [ "$ENVIRONMENT" != "production" ]; then
    echo -e "${YELLOW}⚠️ ENV is '$ENVIRONMENT'. Overriding to production for TestFlight release.${NC}"
    ENVIRONMENT="production"
fi

validate_required_release_env

DART_DEFINE_ARGS=()
append_dart_define "ENV" "$ENVIRONMENT"
append_dart_define "GOOGLE_SERVER_CLIENT_ID" "${GOOGLE_SERVER_CLIENT_ID:-}"
append_dart_define "OPENROUTER_API_KEY" "${OPENROUTER_API_KEY:-}"
append_dart_define "REVENUECAT_API_KEY" "${REVENUECAT_API_KEY:-}"
append_dart_define "FIREBASE_API_KEY_IOS" "${FIREBASE_API_KEY_IOS:-}"
append_dart_define "FIREBASE_APP_ID_IOS" "${FIREBASE_APP_ID_IOS:-}"
append_dart_define "FIREBASE_MESSAGING_SENDER_ID_IOS" "${FIREBASE_MESSAGING_SENDER_ID_IOS:-}"
append_dart_define "FIREBASE_PROJECT_ID_IOS" "${FIREBASE_PROJECT_ID_IOS:-}"
append_dart_define "FIREBASE_STORAGE_BUCKET_IOS" "${FIREBASE_STORAGE_BUCKET_IOS:-}"

# 1. Clean and prepare
echo -e "\n${BLUE}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# 2. Update exportOptions.plist with provided Team ID
echo -e "\n${BLUE}📝 Updating export options...${NC}"
cd ios
sed -i '' "s/YOUR_TEAM_ID/$TEAM_ID/g" exportOptions.plist

# 3. Build iOS release
echo -e "\n${BLUE}📱 Building iOS release...${NC}"
cd ..
flutter build ios --release --no-codesign "${DART_DEFINE_ARGS[@]}"

# 4. Build and archive with xcodebuild
echo -e "\n${BLUE}📦 Creating archive...${NC}"
cd ios

# Set build number automatically (timestamp)
BUILD_NUMBER=$(date +%Y%m%d%H%M)
echo -e "${YELLOW}📊 Build number: $BUILD_NUMBER${NC}"

# Clean up old archives
rm -rf "$HOME/Desktop/GymBro.xcarchive"
rm -rf "$HOME/Desktop/GymBro_Export"

# Archive
echo -e "${BLUE}🔨 Building archive...${NC}"
xcodebuild -workspace Runner.xcworkspace \
           -scheme Runner \
           -configuration Release \
           -destination generic/platform=iOS \
           -archivePath "$HOME/Desktop/GymBro.xcarchive" \
           archive \
           FLUTTER_BUILD_NUMBER=$BUILD_NUMBER \
           DEVELOPMENT_TEAM=$TEAM_ID

# 5. Export for App Store
echo -e "\n${BLUE}🚀 Exporting for App Store...${NC}"
xcodebuild -exportArchive \
           -archivePath "$HOME/Desktop/GymBro.xcarchive" \
           -exportPath "$HOME/Desktop/GymBro_Export" \
           -exportOptionsPlist exportOptions.plist

# 6. Upload to TestFlight using xcrun altool
echo -e "\n${BLUE}⬆️ Uploading to TestFlight...${NC}"
echo -e "${YELLOW}📤 This may take several minutes...${NC}"

# Use notarytool for newer Xcode versions, fallback to altool
if xcrun notarytool --help >/dev/null 2>&1; then
    echo -e "${BLUE}🔧 Using notarytool (recommended)...${NC}"
    xcrun notarytool submit "$HOME/Desktop/GymBro_Export/Runner.ipa" \
                    --apple-id "$APPLE_ID" \
                    --password "$APP_PASSWORD" \
                    --team-id "$TEAM_ID" \
                    --wait
else
    echo -e "${BLUE}🔧 Using altool (legacy)...${NC}"
    xcrun altool --upload-app \
                 --type ios \
                 --file "$HOME/Desktop/GymBro_Export/Runner.ipa" \
                 --username "$APPLE_ID" \
                 --password "$APP_PASSWORD" \
                 --verbose
fi

# 7. Cleanup
echo -e "\n${BLUE}🧹 Cleaning up temporary files...${NC}"
rm -rf "$HOME/Desktop/GymBro.xcarchive"
rm -rf "$HOME/Desktop/GymBro_Export"

# Reset exportOptions.plist
sed -i '' "s/$TEAM_ID/YOUR_TEAM_ID/g" exportOptions.plist

echo -e "\n${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${GREEN}📧 Check your email for processing notification from Apple${NC}"
echo -e "${GREEN}🔗 Visit https://appstoreconnect.apple.com to manage TestFlight${NC}"
echo -e "${YELLOW}⏰ Processing usually takes 10-60 minutes${NC}"

cd ..
