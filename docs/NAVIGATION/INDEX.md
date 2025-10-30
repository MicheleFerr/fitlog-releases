# 📚 GymBro Documentation Index

**Last Updated**: October 21, 2025
**Version**: 2.0 (Cleaned & Consolidated)

---

## 🚀 START HERE

### For AI Assistants (Claude, Copilot, etc.)
**⚠️ MANDATORY**: Read [`CLAUDE.md`](../../CLAUDE.md) (30 min) before making ANY code changes
- Multilingua rules (context.l10n)
- Theme rules (context.colors)
- Architecture patterns (Riverpod, Clean Architecture)
- iOS-specific features (Live Activities, Apple Sign-In)
- Security rules (Firebase, input validation)
- Pre-commit checklist

### For New Developers
1. **Read First**: [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md) (15 min)
   - Where to find everything in this codebase
   - Quick commands and common tasks

2. **Understand Architecture**: [`EXERCISE_DATABASE_SYNC_ARCHITECTURE.md`](./EXERCISE_DATABASE_SYNC_ARCHITECTURE.md) (30 min)
   - High-level system design
   - Data flow and storage strategy

3. **Pick Your Path**:
   - Working on **Exercises** → Start with Exercise section below
   - Working on **Workouts** → Start with Workout section below
   - Working on **Setup/Config** → Start with Setup section below

### For Resuming After Break
```bash
# 1. Check current progress
cat docs/IMPLEMENTATION_STATUS.json | jq '.current_phase, .overall_progress_percent'

# 2. Open quick reference
open docs/QUICK_REFERENCE.md

# 3. Jump to your feature section below
```

---

## 📂 Documentation Structure

### 🤖 AI ASSISTANT RULES
**⚠️ MANDATORY READ FOR ALL AI ASSISTANTS (Claude, Copilot, etc.)**

| Document | Purpose | Location | Audience |
|----------|---------|----------|----------|
| [`CLAUDE.md`](../../CLAUDE.md) | **OBBLIGATORIO**: Regole, linee guida e best practices per AI che lavorano su questo progetto | Root project | AI Assistants, All Developers |

**Key Topics in CLAUDE.md**:
- Multilingua obbligatorio (context.l10n)
- Tema scuro/chiaro (context.colors)
- Architettura Riverpod patterns
- iOS-specific features (Live Activities, Sign in with Apple)
- Firebase & sicurezza
- Performance & memoria
- Testing & debugging
- BuildContext Extensions (regole FASE 1)
- Componenti unificati (LoadingIndicator, SnackBarService, ModalService)
- Documentazione feature-specific (Workout, Exercise Card, Exercise Insertion)
- Git & versioning rules

### 🔒 SECURITY & AUDITS

| Document | Purpose | Audience | Last Audit |
|----------|---------|----------|------------|
| [`SECURITY_AUDIT_2025-10-20.md`](../audit/SECURITY_AUDIT_2025-10-20.md) | Security audit report with findings and remediation roadmap | All developers, DevOps | Oct 20, 2025 |

**Security Score**: 78/100 (B+)
- 2 HIGH priority issues (debug logging, Firebase API keys)
- 4 MEDIUM priority issues (rate limiting, input validation, Firestore rules, dependencies)
- 3 LOW priority issues

### 🏗️ ARCHITECTURE & FUNDAMENTALS
| Document | Purpose | Audience | Read Time |
|----------|---------|----------|-----------|
| [`EXERCISE_DATABASE_SYNC_ARCHITECTURE.md`](./EXERCISE_DATABASE_SYNC_ARCHITECTURE.md) | System design, data flow, storage strategy | All developers | 30 min |
| [`HYBRID_ARCHITECTURE.md`](./HYBRID_ARCHITECTURE.md) | Local-first + cloud-sync pattern | Backend/Storage devs | 20 min |
| [`EXERCISE_FEEDBACK_SYSTEM_ARCHITECTURE.md`](./EXERCISE_FEEDBACK_SYSTEM_ARCHITECTURE.md) | Admin feedback system, user submissions, real-time sync | All developers | 45 min |
| [`WORKOUT_SYSTEM_OVERVIEW.md`](./WORKOUT_SYSTEM_OVERVIEW.md) | Non-technical overview of workout flow | PM/Designers/Devs | 15 min |
| [`EXERCISE_CARD_SYSTEM_OVERVIEW.md`](./EXERCISE_CARD_SYSTEM_OVERVIEW.md) | Non-technical overview of exercise UI | PM/Designers/Devs | 15 min |
| [`EXERCISE_INSERTION_SYSTEM_OVERVIEW.md`](./EXERCISE_INSERTION_SYSTEM_OVERVIEW.md) | Non-technical overview of insertion flow | PM/Designers/Devs | 15 min |
| **[`HIVE_BOX_MANAGER_MIGRATION_REPORT.md`](../TECHNICAL_FOUNDATION/HIVE_BOX_MANAGER_MIGRATION_REPORT.md)** | **✅ Complete migration report: HiveBoxManager centralized pattern (68+ calls)** | **All developers** | **20 min** |
| **[`HIVE_BOX_MANAGER_CHECKLIST.md`](../TECHNICAL_FOUNDATION/HIVE_BOX_MANAGER_CHECKLIST.md)** | **🚨 Mandatory checklist for all Hive storage (prevents memory leaks)** | **All developers** | **10 min** |

### 💻 IMPLEMENTATION GUIDES (ROE - Rules of Engagement)
These are **mandatory** before implementing features in their domain:

| Document | Domain | Must Read? | Implementation Time |
|----------|--------|-----------|------------------|
| [`EXERCISE_IMPLEMENTATION_PLAYBOOK.md`](./EXERCISE_IMPLEMENTATION_PLAYBOOK.md) | Exercise Database (Phases 1-4) | ✅ YES | 2-3 hours |
| [`EXERCISE_CARD_DEVELOPMENT_GUIDE.md`](./EXERCISE_CARD_DEVELOPMENT_GUIDE.md) | Exercise UI Components | ✅ YES (if modifying cards) | 90 min |
| [`EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md`](./EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md) | Exercise Modal/Insertion | ✅ YES (if modifying insertion) | 2 hours |
| [`EXERCISE_INSERTION_CUSTOMIZATION_GUIDE.md`](./EXERCISE_INSERTION_CUSTOMIZATION_GUIDE.md) | Exercise Toggles & Settings | ✅ YES (if adding toggles) | 1 hour |
| [`WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md`](./WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md) | Workout Features | ✅ YES (if modifying workouts) | 2 hours |
| [`EXERCISE_FEEDBACK_DEV_GUIDE.md`](./EXERCISE_FEEDBACK_DEV_GUIDE.md) | Exercise Feedback System | ✅ YES (if modifying feedback) | 15 min (quick) + 45 min (full) |
| [`DROPSET_RESTPAUSE_WORKFLOWS.md`](./DROPSET_RESTPAUSE_WORKFLOWS.md) | Advanced Exercise Types | Reference | 45 min |

### 🎓 KNOWLEDGE BASES (Reference & Troubleshooting)
Use these to understand specific systems:

| Document | Subject | Use When |
|----------|---------|----------|
| [`TIMER_AUDIO_KB.md`](./TIMER_AUDIO_KB.md) | Timer system & audio playback | Debugging timer/audio issues |
| [`LIVE_ACTIVITY_KB.md`](./LIVE_ACTIVITY_KB.md) | iOS Live Activities system | Implementing/fixing Live Activities |
| [`NOTIFICATION_SYSTEM_KB.md`](./NOTIFICATION_SYSTEM_KB.md) | Notification flows & triggers | Debugging notification issues |
| [`ERROR_KB.md`](./ERROR_KB.md) | Common errors & solutions | When you hit a build/runtime error |

### 🔧 SETUP & CONFIGURATION
These cover initial setup and configuration:

| Document | Topic | For Whom |
|----------|-------|----------|
| [`LOCALIZATION_GUIDE.md`](./LOCALIZATION_GUIDE.md) | i18n/l10n patterns & best practices | All developers |
| [`FIREBASE_APP_CHECK_SETUP.md`](./FIREBASE_APP_CHECK_SETUP.md) | Firebase security setup | DevOps/Backend |
| [`PRODUCTION_LOGGING_GUIDE.md`](./PRODUCTION_LOGGING_GUIDE.md) | Logging standards (debugPrint, kDebugMode) | All developers |
| [`PERFORMANCE_OPTIMIZATIONS.md`](./PERFORMANCE_OPTIMIZATIONS.md) | Performance best practices | All developers |
| [`IAP_SETUP_GUIDE.md`](./IAP_SETUP_GUIDE.md) | In-App Purchases (if needed) | Payment systems |

### 📊 PROJECT TRACKING
| Document | Purpose |
|----------|---------|
| [`IMPLEMENTATION_STATUS.json`](./IMPLEMENTATION_STATUS.json) | Current progress on Exercise Database project |

### 📱 PLATFORM-SPECIFIC
| Document | Platform | Topic |
|----------|----------|-------|
| [`ios_native_error_analysis.md`](./ios_native_error_analysis.md) | iOS | Native error debugging reference |
| [`ANDROID_TIMER_INTEGRATION.md`](./ANDROID_TIMER_INTEGRATION.md) | Android | Timer integration specifics |

---

## 🎯 Quick Navigation by Task

### "I want to implement a new feature..."

**Exercise-Related Feature**:
1. Read: [`EXERCISE_IMPLEMENTATION_PLAYBOOK.md`](./EXERCISE_IMPLEMENTATION_PLAYBOOK.md)
2. Reference: [`EXERCISE_CARD_DEVELOPMENT_GUIDE.md`](./EXERCISE_CARD_DEVELOPMENT_GUIDE.md)
3. Reference: [`EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md`](./EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md)

**Workout-Related Feature**:
1. Read: [`WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md`](./WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md)
2. Reference: [`WORKOUT_SYSTEM_OVERVIEW.md`](./WORKOUT_SYSTEM_OVERVIEW.md)

**Timer/Audio Feature**:
1. Reference: [`TIMER_AUDIO_KB.md`](./TIMER_AUDIO_KB.md)
2. Reference: [`EXERCISE_DATABASE_SYNC_ARCHITECTURE.md`](./EXERCISE_DATABASE_SYNC_ARCHITECTURE.md)

**Live Activity Feature (iOS)**:
1. Reference: [`LIVE_ACTIVITY_KB.md`](./LIVE_ACTIVITY_KB.md)
2. Reference: [`ios_native_error_analysis.md`](./ios_native_error_analysis.md)

**Notification Feature**:
1. Reference: [`NOTIFICATION_SYSTEM_KB.md`](./NOTIFICATION_SYSTEM_KB.md)

**Admin Feedback System (User Submissions & Reviews)**:
1. Read: [`EXERCISE_FEEDBACK_SYSTEM_ARCHITECTURE.md`](./EXERCISE_FEEDBACK_SYSTEM_ARCHITECTURE.md)
2. Reference: [`EXERCISE_DATABASE_SYNC_ARCHITECTURE.md`](./EXERCISE_DATABASE_SYNC_ARCHITECTURE.md) (parent system)

### "I'm hitting an error..."

1. Check: [`ERROR_KB.md`](./ERROR_KB.md) - Common solutions
2. Check relevant KB:
   - Timer issues → [`TIMER_AUDIO_KB.md`](./TIMER_AUDIO_KB.md)
   - Live Activity issues → [`LIVE_ACTIVITY_KB.md`](./LIVE_ACTIVITY_KB.md)
   - Notification issues → [`NOTIFICATION_SYSTEM_KB.md`](./NOTIFICATION_SYSTEM_KB.md)
3. Check platform-specific guide:
   - iOS → [`ios_native_error_analysis.md`](./ios_native_error_analysis.md)
   - Android → [`ANDROID_TIMER_INTEGRATION.md`](./ANDROID_TIMER_INTEGRATION.md)

### "I need to add translations..."

1. Read: [`LOCALIZATION_GUIDE.md`](./LOCALIZATION_GUIDE.md)

### "I need to optimize performance..."

1. Read: [`PERFORMANCE_OPTIMIZATIONS.md`](./PERFORMANCE_OPTIMIZATIONS.md)

### "I'm setting up the project..."

1. **AI Assistants**: Read [`CLAUDE.md`](../../CLAUDE.md) (MANDATORY)
2. Start: [`QUICK_REFERENCE.md`](./QUICK_REFERENCE.md)
3. Check: [`FIREBASE_APP_CHECK_SETUP.md`](./FIREBASE_APP_CHECK_SETUP.md)
4. Setup logging: [`PRODUCTION_LOGGING_GUIDE.md`](./PRODUCTION_LOGGING_GUIDE.md)

### "I need to review security..."

1. Read: [`SECURITY_AUDIT_2025-10-20.md`](../audit/SECURITY_AUDIT_2025-10-20.md)
2. Check remediation roadmap (Sprint 1-3 priorities)
3. Review Firestore security rules: `firestore.rules`

---

## 📋 Complete File List (by category)

### AI Assistant Rules & Security (Critical)
- `../../CLAUDE.md` 🤖 ⭐ **MANDATORY for all AI assistants**
- `../audit/SECURITY_AUDIT_2025-10-20.md` 🔒

### Getting Started (Read These First)
- `QUICK_REFERENCE.md` ⭐
- `EXERCISE_DATABASE_SYNC_ARCHITECTURE.md` ⭐

### System Overviews (Non-Technical)
- `EXERCISE_CARD_SYSTEM_OVERVIEW.md`
- `EXERCISE_INSERTION_SYSTEM_OVERVIEW.md`
- `WORKOUT_SYSTEM_OVERVIEW.md`

### Implementation Guides (Technical)
- `EXERCISE_IMPLEMENTATION_PLAYBOOK.md`
- `EXERCISE_CARD_DEVELOPMENT_GUIDE.md`
- `EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md`
- `EXERCISE_INSERTION_CUSTOMIZATION_GUIDE.md`
- `WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md`
- `EXERCISE_FEEDBACK_DEV_GUIDE.md`
- `DROPSET_RESTPAUSE_WORKFLOWS.md`

### Knowledge Bases
- `TIMER_AUDIO_KB.md`
- `LIVE_ACTIVITY_KB.md`
- `NOTIFICATION_SYSTEM_KB.md`
- `ERROR_KB.md`

### UX Flows & System Reports
- `UX_FLOWS/routine_center/WORKOUT_SUGGESTION_SYSTEM_REPORT.md` 🎯 (Workout suggestion algorithm analysis)
- `UX_FLOWS/routine_center/WORKOUT_TEMPLATES_SCREEN_REPORT.md` 📋 (Templates screen architecture & flow analysis)
- `UX_FLOWS/routine_center/WORKOUT_TEMPLATES_SCREEN_IMPROVEMENT_REPORT.md` 🔧 (Improvement plan for AI consultants)
- `UX_FLOWS/routine_center/WORKOUT_TEMPLATES_SCREEN_COMPLIANCE_SECURITY_REPORT.md` 🔒 (Compliance & security audit: WCAG 2.2, OWASP, GDPR)
- `UX_FLOWS/routine_center/UNUSED_TEMPLATE_SCREENS_AUDIT.md` 🔍 (Dead code audit: 3 unused template screens - COMPLETED)

### Architecture & Design
- `EXERCISE_DATABASE_SYNC_ARCHITECTURE.md`
- `HYBRID_ARCHITECTURE.md`
- `EXERCISE_FEEDBACK_SYSTEM_ARCHITECTURE.md`

### Setup & Config
- `LOCALIZATION_GUIDE.md`
- `FIREBASE_APP_CHECK_SETUP.md`
- `PRODUCTION_LOGGING_GUIDE.md`
- `PERFORMANCE_OPTIMIZATIONS.md`
- `IAP_SETUP_GUIDE.md`

### Platform-Specific
- `ios_native_error_analysis.md`
- `ANDROID_TIMER_INTEGRATION.md`

### Project Tracking
- `IMPLEMENTATION_STATUS.json`

---

## 🔄 How to Use This Index

### When Starting New Work
1. **Go to "Quick Navigation by Task"** section above
2. **Find your task type**
3. **Follow the reading order**
4. **Open the linked documents**

### When You Get Stuck
1. **Go to "I'm hitting an error..."** section
2. **Check ERROR_KB.md first**
3. **Then check relevant KB**
4. **Fallback to platform-specific guides**

### When Onboarding Developers
1. **Share this file** (INDEX.md)
2. **Point them to "START HERE"** section
3. **Let them pick their path** based on work
4. **Bookmark "Quick Navigation by Task"** for reference

---

## 📊 Documentation Statistics

- **Total active docs**: 29 files
- **Obsolete docs deleted**: 132 files
- **Documentation reduced**: 91% cleanup
- **Maintained categories**: 8 (AI Rules, Security, Architecture, Implementation, KB, Setup, Platform, Tracking)
- **Latest Additions**:
  - Workout Templates Compliance & Security Report (Oct 21, 2025) 🔒
  - Workout Suggestion System Report (Oct 21, 2025) 🎯
  - Security Audit Report (Oct 20, 2025) 🔒
  - AI Assistant Rules linked (Oct 20, 2025) 🤖
  - Exercise Feedback System Architecture (Oct 18, 2025)
  - Exercise Feedback Dev Guide (Oct 18, 2025)

---

## 🎯 Document Maintenance

### Keep Updated When
- Adding new features → Update relevant ROE guide
- Changing architecture → Update EXERCISE_DATABASE_SYNC_ARCHITECTURE.md or EXERCISE_FEEDBACK_SYSTEM_ARCHITECTURE.md
- Creating new error pattern → Add to ERROR_KB.md
- Implementing new system → Create new KB file
- Changing setup steps → Update QUICK_REFERENCE.md
- Modifying feedback system → Update EXERCISE_FEEDBACK_SYSTEM_ARCHITECTURE.md
- Adding AI rules/patterns → Update CLAUDE.md
- Security changes → Run new security audit, update docs/audit/

### Review Quarterly
- Security audit (run `/audit` command, update docs/audit/)
- Performance optimizations (real metrics)
- Error patterns (new common errors)
- Setup procedures (new tools/steps)
- Dependency updates (security patches)

---

**Last Audit**: October 20, 2025
**Next Audit**: January 20, 2026
**Last Updated**: October 20, 2025 (Added Security Audit Report & linked CLAUDE.md)
