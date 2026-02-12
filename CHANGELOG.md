# Changelog

All notable changes to FitLog Pro will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/).

## [1.0.0] - 2026-02-11 - Beta Release

### Features
- **Workout Tracking**: Full workout lifecycle with templates, supersets, drop sets, rest-pause sets, RPE tracking
- **AI Coach**: Personal AI coaching with smart suggestions, scientific sources, exercise accessory mapping
- **Analytics Dashboard**: Volume progression, weight charts, plateau detection, personal records, weekly dashboard
- **Exercise Database**: 500+ exercises (EN/IT), popularity ranking, custom exercise creation
- **Workout Templates**: Create, duplicate, schedule, share, cloud sync with exponential backoff retry
- **Timer System**: Unified rest timer with iOS Live Activities, Dynamic Island, inter-exercise timer, background support
- **Workout History**: Calendar and list views, editing, filtering, search
- **Progress Photos**: GDPR-compliant photo tracking with encryption
- **Body Measurements**: End-to-end encrypted measurements with HealthKit/Health Connect sync
- **Gamification**: XP-based tier system (Starter to Platinum), achievements, streaks
- **Data Import**: Support for external app data import (CSV, Hevy)
- **Workout Sharing**: Live workout sharing to WhatsApp
- **Plate Calculator**: Smart plate loading calculator 2.0
- **Onboarding**: 6-step guided onboarding with contextual tutorials and discoverability hints
- **Settings**: Customizable appearance (theme color, text size, dark mode), workout essentials
- **Notifications**: Smart notification system with deep linking (cold-start and warm-start)

### Security & Privacy
- GDPR compliance (Articles 6, 7, 9, 17, 18, 20)
- AES-256 encryption for sensitive local data (Hive boxes)
- Firebase App Check (DeviceCheck/AppAttest on iOS, PlayIntegrity on Android)
- Granular consent management with audit trail
- Full account deletion with data anonymization
- Firestore security rules with owner-based access control
- End-to-end encrypted body measurements

### Technical
- Clean Architecture with Riverpod state management
- Offline-first with Hive local storage + Firestore cloud sync
- Auto-save every 2 minutes + emergency save on background transition
- Crash recovery with draft restoration dialog at app startup
- Firebase Crashlytics for Flutter + platform + async errors
- Privacy-safe analytics (disabled by default, enabled after GDPR consent)
- iOS native: Live Activities, Dynamic Island, background timer via MethodChannel
- Localization: English + Italian (3100+ translation keys)
- Design system: AppIcons (475+ icons), context.colors, LoadingIndicator, EnhancedEmptyState

### Performance
- Local-first data persistence with sync queue and exponential backoff
- Batch Hive operations, singleton managers, debounced event handlers
- Memory leak prevention with consistent disposal patterns
- Firestore query optimization (95% ops reduction via caching)
