# Publishing Remaining Tasks - Action Plan

**Generated**: 2025-11-22 17:00
**Source**: task-master.dev (WebFetch) - Compliance-focused revision
**Complexity Score**: MEDIUM
**Reason**: Only remaining 20% of work (80% already complete)
**Total Tasks**: 11
**Estimated Time**: ~8.5h (505 minutes)
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: 3.16.0
- App Version: 1.0.0+49
- Current Readiness: 80% (from compliance analysis)
- Target Platforms: iOS 14+ (iOS 17 target), Android API 26-35
- Related PRs/Issues: None
- Parent Milestone: None
- Last Commit: a376b365 fix(l10n): File 25/25 - daily_login_bonus_widget.dart

---

## 📋 Original Request

> Crea un taskmaster con tutto quello che ci sarebbe da fare

**Context**: After full compliance analysis showed 80% readiness, user requested focused task list for REMAINING 20% of work needed for App Store/Play Store submission.

**Key Constraint**: Keep iOS Bundle ID (`com.michele.gymbro.flutter`) to avoid breaking Live Activities, HealthKit, and Firebase integration.

---

## ✅ Already Completed (80% - NOT in this plan)

These items are DONE and verified by compliance analysis:

- ✅ **Privacy Policy & Terms of Service** (EN/IT) - 23K+ chars, GDPR compliant
- ✅ **iOS Permissions** (Info.plist) - 6 permission keys with user-friendly descriptions
- ✅ **Android Permissions** (AndroidManifest.xml) - 29 permissions properly declared
- ✅ **Localization** - 8,763 translation keys (EN/IT), 98% complete
- ✅ **App Icons** - Android mipmap + iOS launch images configured
- ✅ **Splash Screen** - iOS storyboard + Android theme configured
- ✅ **Firebase Integration** - Analytics, Auth, Firestore, Messaging, App Check
- ✅ **Versioning** - 1.0.0+49 synced across iOS/Android
- ✅ **Android Code Obfuscation** - ProGuard/R8 enabled in build.gradle.kts

---

## 🎯 Remaining Tasks Breakdown (20% to complete)

### BUILD CONFIGURATION (4 tasks)

#### Task 1.1: Android Production Signing Setup
- **Layer**: Build Configuration (Android)
- **Files**: `android/fitlog_prod.keystore`, `android/key.properties`, `android/app/build.gradle.kts`
- **Dependencies**: None (BLOCKER for Task 1.4, 4.2)
- **Est. Time**: 45 min
- **Blocking**: Yes (cannot submit AAB without signing)
- **Priority**: 🔴 CRITICAL
- **Verification**:
  - ✓ Keystore file created: `android/fitlog_prod.keystore`
  - ✓ `key.properties` configured with credentials (NOT in git)
  - ✓ `build.gradle.kts` references production keystore for release
  - ✓ AAB builds successfully: `flutter build appbundle --release`
  - ✓ Signing certificate matches production keystore
- **Code Prompt**:
  ```bash
  # Step 1: Generate production keystore
  keytool -genkey -v -keystore android/fitlog_prod.keystore \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias fitlog-release

  # Step 2: Create android/key.properties (add to .gitignore)
  storePassword=<your-password>
  keyPassword=<your-password>
  keyAlias=fitlog-release
  storeFile=fitlog_prod.keystore

  # Step 3: Update android/app/build.gradle.kts
  # Replace debug signing config with:
  signingConfigs {
      release {
          storeFile = file(keystoreProperties['storeFile'])
          storePassword = keystoreProperties['storePassword']
          keyAlias = keystoreProperties['keyAlias']
          keyPassword = keystoreProperties['keyPassword']
      }
  }
  buildTypes {
      release {
          signingConfig = signingConfigs.getByName("release")
      }
  }

  # Step 4: Add to .gitignore
  echo "android/key.properties" >> .gitignore
  echo "android/*.keystore" >> .gitignore

  # Step 5: Test build
  flutter build appbundle --release
  ```

---

#### Task 1.2: Disable AdMob Test Mode
- **Layer**: Configuration
- **Files**: `lib/core/config/admob_config.dart`
- **Dependencies**: None
- **Est. Time**: 15 min
- **Blocking**: Yes (blocks production ad revenue)
- **Priority**: 🔴 CRITICAL
- **Verification**:
  - ✓ `_forceTestAds = false` in admob_config.dart
  - ✓ Production Ad Unit IDs confirmed correct
  - ✓ Test device registrations removed (if any)
  - ✓ Build & test: Production ads display in debug build
- **Code Prompt**:
  ```dart
  // lib/core/config/admob_config.dart

  class AdMobConfig {
    // CHANGE THIS LINE:
    static const bool _forceTestAds = false; // ← Set to false for production

    // Verify production Ad Unit IDs are correct:
    static const String iOSAppId = 'ca-app-pub-5716120224398761~6339854350';
    static const String androidAppId = 'ca-app-pub-5716120224398761~4072675862';

    // Remove any test device IDs if present
    static List<String> get testDeviceIds => []; // ← Empty for production
  }
  ```

---

#### Task 1.3: iOS Code Obfuscation Documentation
- **Layer**: Build Configuration (iOS)
- **Files**: `scripts/build_release_ios.sh`, `README.md`
- **Dependencies**: None
- **Est. Time**: 30 min
- **Blocking**: No (optimization, not required)
- **Priority**: 🟡 HIGH
- **Verification**:
  - ✓ Build script created: `scripts/build_release_ios.sh`
  - ✓ Script includes `--obfuscate --split-debug-info` flags
  - ✓ Documentation in README explains symbol upload
  - ✓ IPA builds successfully with obfuscation
- **Code Prompt**:
  ```bash
  # Create scripts/build_release_ios.sh

  #!/bin/bash
  # FitLog Pro - iOS Release Build Script
  # Builds IPA with code obfuscation for App Store submission

  set -e

  echo "🔨 Building iOS release with obfuscation..."

  flutter build ipa \
    --release \
    --obfuscate \
    --split-debug-info=build/ios/symbols \
    --build-number=$(($(git rev-list --count HEAD) + 1))

  echo "✅ IPA built successfully!"
  echo "📦 Location: build/ios/ipa/FitLog Pro.ipa"
  echo "🔑 Debug symbols: build/ios/symbols/ (upload to Firebase Crashlytics)"
  ```

  Add to README.md:
  ```markdown
  ## iOS Release Build

  Build production IPA with code obfuscation:

  ```bash
  chmod +x scripts/build_release_ios.sh
  ./scripts/build_release_ios.sh
  ```

  **Important**: Upload debug symbols to Firebase Crashlytics for crash reporting:
  ```bash
  firebase crashlytics:symbols:upload --app=<iOS_APP_ID> build/ios/symbols
  ```
  ```

---

#### Task 1.4: Build & Test Release Artifacts
- **Layer**: Testing
- **Files**: Release IPA, Release AAB
- **Dependencies**: Tasks 1.1, 1.2, 1.3
- **Est. Time**: 90 min
- **Blocking**: Yes (blocks submission)
- **Priority**: 🟡 MEDIUM
- **Verification**:
  - ✓ iOS IPA built: `flutter build ipa --release`
  - ✓ Android AAB built: `flutter build appbundle --release`
  - ✓ Tested on iOS device (iPhone 13+): Zero crashes, all features work
  - ✓ Tested on Android device (API 26+): Zero crashes, all features work
  - ✓ Dark/light themes functional
  - ✓ EN/IT locales display correctly
  - ✓ Permissions prompts show user-friendly text
  - ✓ Obfuscation doesn't break runtime (Live Activities, HealthKit)
- **Code Prompt**:
  ```bash
  # Build iOS Release
  flutter build ipa --release --obfuscate --split-debug-info=build/ios/symbols

  # Build Android Release
  flutter build appbundle --release

  # Test checklist (physical devices):
  # iOS (iPhone 13+, iOS 14+):
  - [ ] Launch app, navigate all screens
  - [ ] Start workout, log sets, complete workout
  - [ ] View analytics charts
  - [ ] Test Live Activity (timer on lock screen)
  - [ ] Test HealthKit integration
  - [ ] Switch dark/light theme
  - [ ] Change language (EN ↔ IT)
  - [ ] Test notifications
  - [ ] No crashes for 10 minutes

  # Android (Pixel 7, API 26+):
  - [ ] Same checklist as iOS
  - [ ] Test Health Connect integration
  - [ ] Test foreground service (timer)
  - [ ] Verify ProGuard didn't break reflection-based code
  ```

---

### STORE SETUP (3 tasks)

#### Task 2.1: App Store Connect Setup
- **Layer**: Platform Configuration (iOS)
- **Files**: App Store Connect portal
- **Dependencies**: None
- **Est. Time**: 20 min
- **Blocking**: Yes (blocks iOS submission)
- **Priority**: 🟡 MEDIUM
- **Verification**:
  - ✓ App created in App Store Connect
  - ✓ Bundle ID: `com.michele.gymbro.flutter` (existing, DO NOT CHANGE)
  - ✓ App name set: "FitLog Pro"
  - ✓ Primary language: English
  - ✓ Category: Health & Fitness
  - ✓ Ready to receive IPA upload
- **Code Prompt**:
  ```
  Steps in App Store Connect (https://appstoreconnect.apple.com):

  1. Click "+" → "New App"
  2. Platform: iOS
  3. Name: "FitLog Pro"
  4. Primary Language: English (U.S.)
  5. Bundle ID: Select "com.michele.gymbro.flutter" (already registered)
     ⚠️ CRITICAL: Use existing Bundle ID to preserve Live Activities + HealthKit
  6. SKU: fitlog-pro-ios (unique identifier)
  7. User Access: Full Access

  8. Navigate to "App Information":
     - Category: Health & Fitness → Workout Tracking
     - Age Rating: 4+ (no objectionable content)

  9. Create Version 1.0:
     - What's New: Initial release
     - Screenshots: (to be added in Task 3.1)
     - Description: (to be added in Task 3.1)
  ```

---

#### Task 2.2: Google Play Console Setup
- **Layer**: Platform Configuration (Android)
- **Files**: Google Play Console
- **Dependencies**: None
- **Est. Time**: 20 min
- **Blocking**: Yes (blocks Android submission)
- **Priority**: 🟡 MEDIUM
- **Verification**:
  - ✓ App created in Play Console
  - ✓ Package name: `com.micheleferrero93.GymProgressAppNew` (from namespace)
  - ✓ App name: "FitLog Pro"
  - ✓ Default language: English
  - ✓ Category: Health & Fitness
  - ✓ Internal testing track created
- **Code Prompt**:
  ```
  Steps in Google Play Console (https://play.google.com/console):

  1. Click "Create app"
  2. App name: "FitLog Pro"
  3. Default language: English (United States)
  4. App or game: App
  5. Free or paid: Free

  6. Setup wizard:
     - App access: All functionality available without restrictions
     - Ads: Yes (AdMob integrated)
     - Content rating: Everyone (IARC questionnaire)
     - Target audience: Ages 13+ (general audience)

  7. Store presence → Main store listing:
     - Short description: (to be added in Task 3.1)
     - Full description: (to be added in Task 3.1)
     - App category: Health & Fitness → Workout Tracking

  8. Release → Testing → Internal testing:
     - Create new release
     - Add testers: your-email@gmail.com
     - Ready to receive AAB upload
  ```

---

#### Task 2.3: Complete Data Safety & Financial Declarations (Android)
- **Layer**: Compliance (Android)
- **Files**: Google Play Console forms
- **Dependencies**: Task 2.2 (Play Console setup)
- **Est. Time**: 30 min
- **Blocking**: Yes (blocks Play Store publish)
- **Priority**: 🟡 HIGH
- **Verification**:
  - ✓ Data Safety form 100% complete
  - ✓ Financial Features declaration submitted
  - ✓ No blocking warnings in Console
  - ✓ Privacy Policy URL provided
- **Code Prompt**:
  ```
  In Play Console → App content → Data safety:

  1. Data collection and security:
     [X] App collects data

     Data types collected:
     - Personal info: Email address, User ID
     - Health & fitness: Workout logs, exercise data, body metrics
     - App activity: In-app actions, other user-generated content
     - Device identifiers: Analytics identifiers

  2. Data sharing:
     [X] App shares data
     - Firebase Analytics (usage analytics)
     - Firebase Crashlytics (crash reports)
     - AdMob (ad personalization)

  3. Data security:
     [X] Data encrypted in transit (HTTPS/SSL)
     [X] Data encrypted at rest (Firebase encryption)
     [X] Users can request data deletion
     [X] Users can request data export

  4. Privacy policy URL:
     https://github.com/michele/gymbro_flutter_new/docs/legal/PRIVACY_POLICY_EN.md
     (or hosted public URL if available)

  In Play Console → Monetization → Financial features:

  1. In-app purchases:
     [ ] None (app is free, no IAP implemented)

  2. Paid features:
     [ ] None

  3. Digital content subscriptions:
     [ ] None

  ⚠️ This declaration is MANDATORY even if all answers are "None"
  ```

---

### CONTENT CREATION (4 tasks)

#### Task 3.1: Create Store Marketing Assets
- **Layer**: Content
- **Files**: Screenshots (10-16 images), descriptions, feature graphic
- **Dependencies**: None (can parallelize)
- **Est. Time**: 120 min
- **Blocking**: Yes (blocks store listing)
- **Priority**: 🔴 CRITICAL
- **Verification**:
  - ✓ Screenshots created: 5-8 per platform, correct dimensions
  - ✓ Descriptions written: EN + IT, within character limits
  - ✓ Google Play feature graphic: 1024×500px
  - ✓ Both locales present for all assets
- **Code Prompt**:
  ```
  SCREENSHOTS STRATEGY:

  iOS Requirements (1080×1920px - 9:16 aspect ratio):
  1. Workout Tracking Screen (active workout, timer visible)
  2. Analytics Dashboard (charts, PRs, volume progression)
  3. Template Library (preset workouts, custom templates)
  4. Exercise Database (search, exercise details, muscle groups)
  5. Live Activity (lock screen timer - iOS specific)

  Android Requirements (1080×1920px):
  1-4. Same as iOS
  5. Foreground Service Notification (timer running)

  BOTH: Capture in dark + light theme, EN + IT locales
  Total: 8 screenshots per platform (5 unique × 2 locales, mix themes)

  DESCRIPTIONS:

  Short Description (EN - 80 chars):
  "Advanced workout tracker with analytics, templates, and smart timers"

  Short Description (IT - 80 chars):
  "Tracker allenamenti avanzato con analisi, modelli e timer intelligenti"

  Full Description (EN - 4000 chars):
  "FitLog Pro: Your Complete Fitness Companion

  🏋️ SMART WORKOUT TRACKING
  - Log exercises with sets, reps, weight, RPE
  - Rest timer with iOS Live Activities (lock screen)
  - Custom workout templates & preset programs
  - Superset, dropset, rest-pause support

  📊 ADVANCED ANALYTICS
  - Volume progression charts
  - Personal records (PRs) timeline
  - Muscle balance radar charts
  - Workout heatmap calendar
  - 1RM estimations & strength standards

  🤖 INTELLIGENT FEATURES
  - AI-powered workout suggestions
  - Exercise database (500+ exercises)
  - Routine planner with custom patterns
  - Community workout sharing

  ⚡ PERFORMANCE & PRIVACY
  - Offline-first (works without internet)
  - Firebase sync across devices
  - GDPR compliant, privacy-first design
  - Available in English & Italian

  🍎 iOS EXCLUSIVE
  - Live Activities (Dynamic Island support)
  - HealthKit integration
  - Apple Watch companion (coming soon)

  🤖 ANDROID EXCLUSIVE
  - Health Connect integration
  - Material You adaptive theming

  Free to use, no hidden fees. Built with Flutter for smooth performance."

  Full Description (IT - 4000 chars):
  [Translate above to Italian - similar structure]

  GOOGLE PLAY FEATURE GRAPHIC (1024×500px):
  - Showcase app icon + key feature: "Track. Analyze. Improve."
  - Brand colors: Blue (#2196F3) + secondary colors from theme
  - Include workout chart visual + timer UI element
  ```

---

#### Task 3.2: Verify & Complete Privacy Policy
- **Layer**: Legal
- **Files**: `docs/legal/PRIVACY_POLICY_EN.md`, `docs/legal/PRIVACY_POLICY_IT.md`
- **Dependencies**: None
- **Est. Time**: 45 min
- **Blocking**: No (already 95% complete)
- **Priority**: 🟡 HIGH
- **Verification**:
  - ✓ No placeholder text `[Developer Name]` remaining
  - ✓ Support email `support@fitlogpro.app` verified monitored
  - ✓ Privacy Policy hosted on public URL (optional)
  - ✓ Policy covers all Firebase services used
- **Code Prompt**:
  ```bash
  # Step 1: Replace placeholders
  find docs/legal -name "*.md" -exec sed -i '' 's/\[Developer Name\]/Michele Ferrero/g' {} +

  # Step 2: Verify support email
  # Test: Send email to support@fitlogpro.app
  # Verify: Response within 24 hours

  # Step 3 (Optional): Host on GitHub Pages
  # Create gh-pages branch
  git checkout --orphan gh-pages
  mkdir privacy
  cp docs/legal/PRIVACY_POLICY_EN.md privacy/index.md
  cp docs/legal/PRIVACY_POLICY_IT.md privacy/it.md
  git add privacy/
  git commit -m "Add privacy policy"
  git push origin gh-pages

  # Access: https://michele.github.io/gymbro_flutter_new/privacy/
  # (or configure custom domain)

  # Step 4: Update Privacy Policy URL in:
  # - App Store Connect → App Information → Privacy Policy URL
  # - Play Console → Store presence → Privacy policy
  # - In-app link in settings screen (already configured via LegalDocumentScreen)
  ```

---

#### Task 3.3: Create Demo Account (iOS)
- **Layer**: Testing (iOS)
- **Files**: Firebase Auth, demo account documentation
- **Dependencies**: None
- **Est. Time**: 30 min
- **Blocking**: Yes (blocks iOS submission)
- **Priority**: 🟡 HIGH
- **Verification**:
  - ✓ Account created: `reviewer@fitlogpro.app` or similar
  - ✓ Pre-populated with sample data (5+ workouts, analytics)
  - ✓ Credentials documented for App Store reviewer notes
  - ✓ Account accessible from reviewer devices
- **Code Prompt**:
  ```dart
  // Step 1: Create account in Firebase Auth (via app or console)
  // Email: reviewer@fitlogpro.app
  // Password: AppReview2025! (document securely)

  // Step 2: Pre-populate data (run once in debug mode):

  Future<void> populateDemoAccount() async {
    final userId = 'demo-reviewer-account-id'; // Get from Firebase Auth

    // Create 5 workout templates
    await _createTemplate(userId, 'Push Day', exercises: [
      'Bench Press', 'Overhead Press', 'Tricep Dips'
    ]);
    await _createTemplate(userId, 'Pull Day', exercises: [
      'Deadlift', 'Pull-ups', 'Barbell Rows'
    ]);
    await _createTemplate(userId, 'Leg Day', exercises: [
      'Squats', 'Leg Press', 'Leg Curls'
    ]);

    // Create 10 completed workouts (last 30 days)
    for (int i = 0; i < 10; i++) {
      final date = DateTime.now().subtract(Duration(days: i * 3));
      await _createCompletedWorkout(userId, date, randomTemplate());
    }

    // Ensure analytics data visible:
    // - Volume progression chart (30-day data)
    // - PRs recorded (bench press 100kg, squat 120kg)
    // - Workout heatmap (green cells for workout days)
  }

  // Step 3: Document credentials for App Store reviewer notes:
  """
  Demo Account Credentials:
  Email: reviewer@fitlogpro.app
  Password: AppReview2025!

  Account includes:
  - 5 workout templates (Push/Pull/Legs split)
  - 10 completed workouts (last 30 days)
  - Analytics dashboards populated with data
  - Social features: 2 followed users, 5 liked workouts

  To test Live Activities (iOS):
  1. Start any workout from templates
  2. Begin rest timer (60 seconds)
  3. Lock screen → Live Activity appears in Dynamic Island
  """
  ```

---

#### Task 3.4: Complete Pre-Flight Compliance Checklist
- **Layer**: Testing
- **Files**: Compliance checklist document
- **Dependencies**: Tasks 1.1-1.4, 2.1-2.3, 3.1-3.3 (ALL previous tasks)
- **Est. Time**: 60 min
- **Blocking**: Yes (blocks submission)
- **Priority**: 🟡 MEDIUM
- **Verification**:
  - ✓ All checklist items verified and documented
  - ✓ Screenshot evidence of completed items
  - ✓ No critical issues outstanding
- **Code Prompt**:
  ```markdown
  # FitLog Pro - Pre-Flight Compliance Checklist

  Date: YYYY-MM-DD
  Version: 1.0.0+49
  Platforms: iOS 14+ / Android API 26+

  ## Build & Configuration
  - [ ] Release IPA built successfully (iOS)
  - [ ] Release AAB built successfully (Android)
  - [ ] iOS code obfuscation enabled (--obfuscate flag)
  - [ ] Android ProGuard/R8 enabled (isMinifyEnabled = true)
  - [ ] AdMob test mode disabled (_forceTestAds = false)
  - [ ] Production Ad Unit IDs configured
  - [ ] Version 1.0.0 set in both stores
  - [ ] Build numbers synced (iOS: 49, Android: 49)

  ## Store Setup
  - [ ] App created in App Store Connect
  - [ ] App created in Google Play Console
  - [ ] Bundle ID correct (com.michele.gymbro.flutter)
  - [ ] Package name correct (com.micheleferrero93.GymProgressAppNew)
  - [ ] Data Safety form complete (Android)
  - [ ] Financial Features declaration complete (Android)

  ## Content & Assets
  - [ ] Screenshots uploaded (5-8 per platform)
  - [ ] App descriptions written (EN + IT)
  - [ ] Google Play feature graphic uploaded (1024×500px)
  - [ ] Privacy Policy URL provided
  - [ ] Support contact verified (support@fitlogpro.app)
  - [ ] Keywords/tags optimized

  ## Testing - iOS (Physical Device)
  - [ ] Tested on iPhone 13+ (iOS 14+)
  - [ ] Zero crashes during 10-minute walkthrough
  - [ ] Dark/light themes functional
  - [ ] EN/IT locales display correctly
  - [ ] All permission prompts show user-friendly text
  - [ ] Live Activity works (lock screen timer)
  - [ ] HealthKit integration functional
  - [ ] Firebase Analytics events logging

  ## Testing - Android (Physical Device)
  - [ ] Tested on Pixel 7 (API 26+)
  - [ ] Zero crashes during 10-minute walkthrough
  - [ ] Dark/light themes functional
  - [ ] EN/IT locales display correctly
  - [ ] All permission prompts show user-friendly text
  - [ ] Foreground service works (timer)
  - [ ] Health Connect integration functional
  - [ ] Firebase Analytics events logging

  ## Legal & Privacy
  - [ ] Privacy Policy finalized (no placeholders)
  - [ ] Terms of Service finalized
  - [ ] Support email monitored (24h response SLA)
  - [ ] All external links tested (privacy, support, social)
  - [ ] GDPR compliance verified
  - [ ] Demo account created (iOS: reviewer@fitlogpro.app)

  ## Final Checks
  - [ ] No placeholder content visible
  - [ ] All features accessible without crashes
  - [ ] Obfuscation doesn't break runtime
  - [ ] Firebase services initialized correctly
  - [ ] Ads display properly (production mode)
  - [ ] Analytics tracking verified

  ---

  Completed by: ___________________
  Date: ___________________
  Approved for submission: [ ] YES [ ] NO
  ```

---

## 📊 Implementation Order

### ⚡ PHASE 1: Build Configuration (Week 1, Days 1-2)
**Blocking tasks that must be done first:**

→ **Task 1.1**: Android Production Signing (45 min) - CRITICAL BLOCKER
→ **Task 1.2**: Disable AdMob Test Mode (15 min) - CRITICAL BLOCKER
→ **Task 1.3**: iOS Obfuscation Docs (30 min) - HIGH
→ **Task 1.4**: Build & Test Release (90 min) - MEDIUM

**Subtotal**: ~3 hours
**Milestone**: Release builds ready for upload

---

### 🔄 PHASE 2: Store Setup (Week 1, Days 3-4)
**Platform configuration (can parallelize):**

→ **Task 2.1**: App Store Connect Setup (20 min) - MEDIUM
→ **Task 2.2**: Play Console Setup (20 min) - MEDIUM
→ **Task 2.3**: Data Safety & Financial Forms (30 min) - HIGH

**Subtotal**: ~1.2 hours
**Milestone**: Both stores ready to receive uploads

---

### ✅ PHASE 3: Content Creation (Week 2, Days 1-3)
**Marketing assets (longest phase):**

→ **Task 3.1**: Marketing Assets (120 min) - CRITICAL
→ **Task 3.2**: Privacy Policy Finalize (45 min) - HIGH
→ **Task 3.3**: Demo Account (30 min) - HIGH

**Subtotal**: ~3.25 hours
**Milestone**: Store listings complete, ready for review

---

### 🎯 PHASE 4: Final Validation (Week 2, Days 4-5)
**Pre-submission checks:**

→ **Task 3.4**: Pre-Flight Checklist (60 min) - MEDIUM

**Subtotal**: ~1 hour
**Milestone**: Ready for App Store/Play Store submission

---

**Total Timeline**: 2 weeks (8.5 hours work, rest is waiting/testing)

---

## 🔗 Cross-Task Dependencies

```
CRITICAL PATH (Sequential):

Task 1.1 (Android Signing) BLOCKS:
  → 1.4 (Build Release AAB)
  → 2.2 (Play Console needs AAB upload)

Task 1.2 (Disable Test Ads) BLOCKS:
  → 1.4 (Build must have production ads)
  → 3.4 (Pre-flight testing with production ads)

Task 2.1 (App Store Connect) BLOCKS:
  → 3.4 (Need IPA upload target)

Task 2.2 (Play Console) BLOCKS:
  → 2.3 (Data Safety forms in Console)
  → 3.4 (Need AAB upload target)

Task 3.1 (Marketing Assets) BLOCKS:
  → 2.1 (Upload screenshots to App Store Connect)
  → 2.2 (Upload screenshots to Play Console)
  → 3.4 (Pre-flight includes visual checks)

Task 3.3 (Demo Account) BLOCKS:
  → 3.4 (Pre-flight requires testing demo account)

All Tasks BLOCK:
  → Final Submission (cannot submit until all tasks complete)
```

**Parallel Opportunities**:
- Tasks 2.1, 2.2 can run in parallel (different platforms)
- Tasks 3.1, 3.2, 3.3 can run in parallel (independent content creation)

---

## ⏰ Critical Deadlines

| Deadline | Task | Severity | Notes |
|----------|------|----------|-------|
| **Week 1, Day 2** | Task 1.1: Android Signing | 🔴 CRITICAL | Blocks AAB submission |
| **Week 1, Day 2** | Task 1.2: Disable Test Ads | 🔴 CRITICAL | Production ads required |
| **Week 1, Day 5** | Task 2.3: Data Safety | 🔴 CRITICAL | Mandatory for Play Store |
| **Week 2, Day 3** | Task 3.1: Marketing Assets | 🔴 CRITICAL | Blocks store listings |
| **Week 2, Day 3** | Task 3.3: Demo Account | 🟡 HIGH | Required for iOS review |
| **Week 2, Day 5** | Task 3.4: Pre-Flight Checklist | 🟡 MEDIUM | Final validation |
| **August 31, 2025** | N/A - Already compliant | ✅ | Target SDK 35 already configured |

---

## ✅ Success Criteria (All Must Pass)

- [ ] Android release AAB builds with production signing
- [ ] iOS release IPA builds with code obfuscation
- [ ] Zero crashes on physical devices (iOS 14+ / Android API 26+)
- [ ] AdMob shows production ads (no test banners)
- [ ] App Store Connect ready to receive IPA upload
- [ ] Google Play Console ready to receive AAB upload
- [ ] Data Safety & Financial declarations submitted (Android)
- [ ] 5-8 screenshots uploaded per platform (EN + IT)
- [ ] App descriptions complete (EN + IT, within char limits)
- [ ] Privacy Policy finalized (no placeholders, hosted URL)
- [ ] Demo account functional (iOS: reviewer@fitlogpro.app)
- [ ] Pre-flight checklist 100% complete (all boxes checked)
- [ ] Both EN/IT locales tested on devices
- [ ] Dark/light themes verified functional
- [ ] All external links tested (privacy, support)

---

## 📝 Notes & Decisions

**Design Decisions**:
- **Keep iOS Bundle ID** (`com.michele.gymbro.flutter`) to avoid breaking Live Activities, HealthKit, Firebase
- **Android namespace** (`com.micheleferrero93.GymProgressAppNew`) stays unchanged for same reason
- **AdMob test mode**: Disable immediately after Task 1.2 (no gradual rollout)
- **Screenshots**: Capture from actual app (not mock-ups) to show real data
- **Privacy Policy**: Host on GitHub Pages for persistent URL (optional but recommended)

**Tech Stack Decisions**:
- Android signing: Use production keystore, NOT debug keystore for release
- iOS obfuscation: Document in build script (not enforced by Xcode project)
- Demo account: Firebase Auth email/password (not OAuth for easier reviewer access)

**Risks**:
- **Task 3.1 (Marketing Assets)** takes longest (2h) - allocate dedicated design time
- **Task 1.4 (Build & Test)** might reveal obfuscation issues - test thoroughly
- **Task 3.3 (Demo Account)** requires Firebase access - ensure credentials available

**Carry-forward for Next Release**:
- After v1.0 approval: Monitor crash reports, user reviews
- Plan v1.1 based on initial feedback
- Consider adding in-app purchases (requires new compliance tasks)
- Explore Apple Watch companion app (iOS)

---

## 📚 Related Documentation

**External Resources**:
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Developer Policies](https://play.google/developer-content-policy/)

**Internal FitLog Pro Docs**:
- `docs/plans/2025-11-22-app-publishing-readiness-plan.md` (Original 18-task plan)
- `docs/DESIGN_GUIDELINES.md` (Theme, colors, accessibility)
- `docs/NAVIGATION/INDEX.md` (Feature documentation index)
- `CLAUDE.md` (Project rules - localization, theme, iOS compliance)

**Compliance Analysis**:
- Full compliance report generated 2025-11-22
- Current readiness: 80% (80% complete, 20% remaining in this plan)

---

## 🔄 Execution Tracking

**Status**: Not Started
**Current Phase**: N/A
**Completed Tasks**: 0/11
**Estimated Remaining**: ~8.5h (505 minutes)
**Actual Time Spent**: 0h

**Blockers**: None (plan ready for execution)

**Next Action**: Start with Task 1.1 (Android Production Signing) - CRITICAL

---

**Last Updated**: 2025-11-22 17:00
**Plan Author**: Claude Code (task-master.dev integration, compliance-focused)
**Approved By**: Michele (developer)
**Plan Type**: Remaining Tasks Only (focuses on 20% incomplete work)
