# 💪 GymBro - Fitness Tracking App

> A comprehensive Flutter fitness app with intelligent workout tracking, exercise database, and performance analytics.

**Status**: Production (Active Development)
**Platform**: iOS + Android
**Architecture**: Clean Architecture + Riverpod
**State**: Tier-1 Development Phase

---

## 🚀 Quick Start

### New to the Project?

1. **Read Project Rules**: [`CLAUDE.md`](./CLAUDE.md) - Required reading for all changes
2. **Read Code Quality**: [`CODE_QUALITY_RULES.md`](./CODE_QUALITY_RULES.md) - Enforcement standards
3. **Browse Docs**: [`📚 docs/INDEX.md`](./docs/INDEX.md) - Complete documentation index
4. **Setup Dev Environment**: Follow instructions in `docs/QUICK_REFERENCE.md`

### For Quick Reference
```bash
# Check what docs are available
open docs/INDEX.md

# Check project rules
open CLAUDE.md

# See implementation status
cat docs/IMPLEMENTATION_STATUS.json | jq '.current_phase, .overall_progress_percent'
```

---

## 📚 Documentation

The project has **comprehensive, organized documentation**:

| Resource | Purpose | Location |
|----------|---------|----------|
| **📖 Main Index** | Start here for all docs | [`docs/INDEX.md`](./docs/INDEX.md) |
| **⚡ Quick Reference** | Quick lookup & navigation | [`docs/QUICK_REFERENCE.md`](./docs/QUICK_REFERENCE.md) |
| **📋 Project Rules** | Mandatory rules & patterns | [`CLAUDE.md`](./CLAUDE.md) |
| **✅ Code Quality** | Quality enforcement rules | [`CODE_QUALITY_RULES.md`](./CODE_QUALITY_RULES.md) |
| **🏗️ Architecture** | System design & data flow | [`docs/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md`](./docs/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md) |
| **🎯 Implementation** | Step-by-step guides | `docs/` directory |
| **🔍 Knowledge Bases** | Reference & troubleshooting | `docs/` (*.KB.md files) |

**➡️ Start with [`docs/INDEX.md`](./docs/INDEX.md) for complete navigation!**

---

## 🏗️ Project Structure

```
gymbro_flutter_new/
├── 📋 Documentation
│   ├── CLAUDE.md                          ⭐ Project rules (READ FIRST)
│   ├── CODE_QUALITY_RULES.md              ✅ Quality standards
│   ├── docs/INDEX.md                      📚 Documentation index
│   ├── docs/QUICK_REFERENCE.md            🚀 Quick lookup
│   └── docs/                              📖 All technical docs
│
├── 💻 Source Code
│   ├── lib/
│   │   ├── features/                      Feature modules
│   │   │   ├── exercise_database/         Exercise system
│   │   │   ├── workout/                   Workout system
│   │   │   ├── timer/                     Timer system
│   │   │   ├── auth/                      Authentication
│   │   │   └── ...
│   │   ├── shared/                        Shared utilities
│   │   │   ├── presentation/              UI components & extensions
│   │   │   ├── domain/                    Business logic
│   │   │   └── services/                  Common services
│   │   └── app/                           App entry point
│   │
│   ├── test/                              Unit tests
│   ├── integration_test/                  Integration tests (Patrol)
│   └── assets/                            App assets
│
├── 📱 iOS Configuration
│   ├── ios/
│   │   ├── Runner/                        iOS app
│   │   │   ├── Managers/                  iOS managers (audio, timer, etc)
│   │   │   └── LiveActivityTimer/         Live Activities
│   │   └── Podfile
│
├── 🤖 Android Configuration
│   ├── android/
│   │   ├── app/
│   │   │   ├── src/main/kotlin/           Android code
│   │   │   └── src/main/res/              Android resources
│   │   └── build.gradle.kts
│
└── 🔧 Configuration
    ├── pubspec.yaml                       Dependencies
    ├── l10n.yaml                          Localization config
    ├── analysis_options.yaml               Lint rules
    ├── firestore.rules                     Firestore security rules
    └── firebase.json                       Firebase config
```

---

## 🎯 Core Features

### ✅ Implemented
- **Workout Tracking** - Real-time workout logging with timer
- **Exercise Database** - 1,567 curated Italian exercises
- **Live Activities** - iOS lock screen timer display
- **Background Timer** - Continue timing when app is backgrounded
- **Multi-language** - English & Italian (BuildContext extensions)
- **Dark/Light Theme** - System theme support
- **Analytics** - Workout statistics & insights
- **Firebase Integration** - Cloud sync & authentication
- **Hybrid Storage** - Local-first (Hive) + cloud (Firestore)

### 🚧 In Development
- Advanced analytics (AI coach)
- Routine templates
- Social features

---

## ⚙️ Key Technologies

| Layer | Technologies |
|-------|--------------|
| **UI Framework** | Flutter 3.x with Material Design 3 |
| **State Management** | Riverpod 2.x |
| **Local Storage** | Hive |
| **Cloud** | Firebase (Auth, Firestore, Cloud Functions) |
| **Testing** | Dart test, Flutter test, Patrol (E2E) |
| **Localization** | Flutter's built-in i18n system |
| **CI/CD** | GitHub Actions |

---

## 📋 Development Workflow

### Before Making Any Changes
1. ✅ Read [`CLAUDE.md`](./CLAUDE.md) - Project rules
2. ✅ Check [`CODE_QUALITY_RULES.md`](./CODE_QUALITY_RULES.md) - Quality standards
3. ✅ Check [`docs/INDEX.md`](./docs/INDEX.md) - Find relevant guide
4. ✅ Run `flutter analyze` - Check for errors

### Working on Features
- **Modifying Exercise System** → Read [`docs/EXERCISE_CARD_DEVELOPMENT_GUIDE.md`](./docs/EXERCISE_CARD_DEVELOPMENT_GUIDE.md)
- **Modifying Workout System** → Read [`docs/WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md`](./docs/WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md)
- **Adding Exercises** → Read [`docs/EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md`](./docs/EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md)
- **Debugging Issues** → Check [`docs/ERROR_KB.md`](./docs/ERROR_KB.md)

### Testing & Building
```bash
# Run analysis
flutter analyze

# Run unit tests
flutter test

# Run integration tests (Patrol)
patrol test

# Build for iOS
flutter build ios

# Build for Android
flutter build apk
```

---

## 🛡️ Code Quality Standards

This project enforces **strict code quality**:

| Rule | Enforcement | Reference |
|------|-------------|-----------|
| **No Hardcoded Strings** | i18n via `context.l10n.*` | [`CLAUDE.md`](./CLAUDE.md#-regola-1-multilingua-obbligatorio) |
| **No Hardcoded Colors** | Theme via `context.colors.*` | [`CLAUDE.md`](./CLAUDE.md#-regola-2-tema-scuroschiaro) |
| **No print() in Code** | Use `debugPrint()` + `kDebugMode` | [`CLAUDE.md`](./CLAUDE.md#🖨️-debug-printing-obbligatorio) |
| **BuildContext Extensions** | Use optimized accessors | [`CLAUDE.md`](./CLAUDE.md#-regola-13-buildcontext-extensions-obbligatorio) |
| **Unified Components** | LoadingIndicator, SnackBarService, ModalService | [`CLAUDE.md`](./CLAUDE.md#-regola-14-componenti-e-servizi-unificati-obbligatorio) |
| **Clean Architecture** | Feature-based structure with ROE | [`docs/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md`](./docs/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md) |

**⚠️ Pre-commit hooks enforce these automatically!**

---

## 📖 Documentation Standards

Documentation is **organized, maintained, and centralized**:

- **24 active documentation files** (cleaned from 200+)
- **6 major categories**: Architecture, Implementation, Knowledge Bases, Setup, Platform, Tracking
- **Quick lookup via INDEX.md**: Start at [`docs/INDEX.md`](./docs/INDEX.md)
- **Rules-of-Engagement (ROE)** for each major domain
- **Knowledge Bases** for troubleshooting

**All documentation is kept updated and relevant.**

---

## 🚀 Getting Started (Development)

### Prerequisites
```bash
# Flutter (latest stable)
flutter --version

# Device setup
flutter devices
```

### Initial Setup
```bash
# Get dependencies
flutter pub get

# Generate code (localizations, etc)
flutter gen-l10n

# Run app
flutter run
```

### Development Workflow
```bash
# Watch for errors
flutter analyze

# Run tests
flutter test

# Hot reload during development
flutter run -v

# Check localization
flutter gen-l10n

# Verify quality standards
make quality-check  # (if available)
```

---

## 🔐 Security & Privacy

- **User Data**: Protected with Firestore security rules
- **Authentication**: Firebase Auth with Sign in with Apple
- **Privacy Policy**: [`legal/PRIVACY_POLICY.md`](./legal/PRIVACY_POLICY.md)
- **Terms of Service**: [`legal/TERMS_OF_SERVICE.md`](./legal/TERMS_OF_SERVICE.md)

---

## 📞 Support & Documentation

| Need | Resource |
|------|----------|
| How to implement a feature | [`docs/INDEX.md`](./docs/INDEX.md) - Quick Navigation section |
| Build errors or crashes | [`docs/ERROR_KB.md`](./docs/ERROR_KB.md) |
| Architecture questions | [`docs/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md`](./docs/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md) |
| iOS-specific issues | [`docs/ios_native_error_analysis.md`](./docs/ios_native_error_analysis.md) |
| Android-specific issues | [`docs/ANDROID_TIMER_INTEGRATION.md`](./docs/ANDROID_TIMER_INTEGRATION.md) |
| Project rules | [`CLAUDE.md`](./CLAUDE.md) |

---

## 📊 Project Status

**Overall Progress**: See [`docs/IMPLEMENTATION_STATUS.json`](./docs/IMPLEMENTATION_STATUS.json)

```bash
# Quick status check
cat docs/IMPLEMENTATION_STATUS.json | jq '.current_phase, .overall_progress_percent, .quick_status'
```

---

## 📄 License

[Add appropriate license here if applicable]

---

## 🎯 Next Steps

1. **New Developer?** → Start: [`CLAUDE.md`](./CLAUDE.md)
2. **Have a Task?** → Go to: [`docs/INDEX.md`](./docs/INDEX.md)
3. **Need to Fix Something?** → Check: [`docs/ERROR_KB.md`](./docs/ERROR_KB.md)
4. **Setup Environment?** → Follow: [`docs/QUICK_REFERENCE.md`](./docs/QUICK_REFERENCE.md)

**📚 All documentation is one click away: [`docs/INDEX.md`](./docs/INDEX.md)**

---

**Last Updated**: October 18, 2025
**Maintained by**: Development Team
**Documentation Status**: Clean & Organized ✅
