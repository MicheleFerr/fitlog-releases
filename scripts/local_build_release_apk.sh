#!/bin/zsh

set -euo pipefail

cd /Users/michele/gymbro_flutter_new

export JAVA_HOME=/usr/local/opt/openjdk@17
export PATH="$JAVA_HOME/bin:/Volumes/NVMe/flutter/bin:$PATH"

set -a
source .env
set +a

: "${OPENROUTER_API_KEY:?Missing OPENROUTER_API_KEY in .env}"
: "${REVENUECAT_API_KEY:?Missing REVENUECAT_API_KEY in .env}"

flutter clean
flutter pub get
flutter build apk --release \
  --dart-define=ENV=production \
  --dart-define=OPENROUTER_API_KEY="$OPENROUTER_API_KEY" \
  --dart-define=REVENUECAT_API_KEY="$REVENUECAT_API_KEY"
