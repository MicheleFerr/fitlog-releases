# 📚 GymBro Documentation - Organized by UX Flows

> **NEW STRUCTURE**: Documentation organized by user experience flows, not by technical type

---

## 🚀 START HERE

**New to the project?**
1. Go to: [`NAVIGATION/INDEX.md`](./NAVIGATION/INDEX.md)
2. Quick lookup: [`NAVIGATION/QUICK_REFERENCE.md`](./NAVIGATION/QUICK_REFERENCE.md)

**Want documentation on a specific feature?**
Pick your area below 👇

---

## 📂 Documentation by User Experience Flow

### 🏠 HOME & DASHBOARD
**Building the home screen, dashboard, or analytics views?**

📁 `UX_FLOWS/home_dashboard/`
- Overview of home screen experience
- Dashboard design & layout
- Analytics display patterns
- Recent workouts view

→ [Go to Home Dashboard Docs](./UX_FLOWS/home_dashboard/)

---

### ⏱️ WORKOUT SESSION
**Building or debugging workout execution, timers, or exercises?**

📁 `UX_FLOWS/workout_session/`

**Includes**:
- 🔴 Timer system (Audio, iOS Live Activities, Background)
- 🏋️ Exercise insertion & customization
- 💪 Exercise card components
- ⏰ Rest timers & set tracking
- 🎯 Workout flow & features
- 🚀 Advanced exercise types (superset, dropset, rest-pause)

**Key Files**:
- [`TIMER_AUDIO_KB.md`](./UX_FLOWS/workout_session/TIMER_AUDIO_KB.md) - Timer troubleshooting
- [`EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md`](./UX_FLOWS/workout_session/EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md) - Adding exercises
- [`WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md`](./UX_FLOWS/workout_session/WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md) - ROE for workout features
- [`LIVE_ACTIVITY_KB.md`](./UX_FLOWS/workout_session/LIVE_ACTIVITY_KB.md) - iOS Live Activities

→ [Go to Workout Session Docs](./UX_FLOWS/workout_session/)

---

### 🗂️ EXERCISE DATABASE
**Managing exercises, database sync, or feedback system?**

📁 `UX_FLOWS/exercise_database/`

**Includes**:
- 🗄️ Exercise database architecture & sync
- 📋 Exercise implementation playbook
- 💬 User feedback system for exercises
- 🎨 Exercise card UI/UX
- 🔍 Exercise search & filtering

**Key Files**:
- [`EXERCISE_IMPLEMENTATION_PLAYBOOK.md`](./UX_FLOWS/exercise_database/EXERCISE_IMPLEMENTATION_PLAYBOOK.md) - Step-by-step implementation
- [`EXERCISE_DATABASE_SYNC_ARCHITECTURE.md`](./UX_FLOWS/exercise_database/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md) - System design
- [`EXERCISE_FEEDBACK_DEV_GUIDE.md`](./UX_FLOWS/exercise_database/EXERCISE_FEEDBACK_DEV_GUIDE.md) - User feedback system

→ [Go to Exercise Database Docs](./UX_FLOWS/exercise_database/)

---

### 📅 ROUTINE & TEMPLATES
**Working on routines or workout templates?**

📁 `UX_FLOWS/routine_templates/`

(Documentation coming as features are developed)

→ [Go to Routine Docs](./UX_FLOWS/routine_templates/)

---

### 👤 USER & ACCOUNT
**Authentication, user settings, or localization?**

📁 `UX_FLOWS/user_account/`

**Includes**:
- 👥 User models & data structure
- 🔑 Authentication & user state
- 🌍 Localization & i18n
- ⚙️ User settings & preferences
- 💎 Premium features & tiers

**Key Files**:
- [`USER_MODELS_GUIDE.md`](./UX_FLOWS/user_account/USER_MODELS_GUIDE.md) - User model architecture
- [`LOCALIZATION_GUIDE.md`](./UX_FLOWS/user_account/LOCALIZATION_GUIDE.md) - Multi-language support

→ [Go to User Account Docs](./UX_FLOWS/user_account/)

---

## 🔧 TECHNICAL FOUNDATION

**For architecture, performance, or setup topics**

📁 `TECHNICAL_FOUNDATION/`

**Includes**:
- 🏗️ System architecture (Hybrid, Firestore, etc.)
- 🎯 Performance optimization
- 🔐 Security & setup
- 📝 Error troubleshooting
- 📱 Platform-specific guides (iOS, Android)

**Key Files**:
- [`ERROR_KB.md`](./TECHNICAL_FOUNDATION/ERROR_KB.md) - Common errors & solutions
- [`PERFORMANCE_OPTIMIZATIONS.md`](./TECHNICAL_FOUNDATION/PERFORMANCE_OPTIMIZATIONS.md) - Performance tips
- [`HYBRID_ARCHITECTURE.md`](./TECHNICAL_FOUNDATION/HYBRID_ARCHITECTURE.md) - Local-first sync design

→ [Go to Technical Docs](./TECHNICAL_FOUNDATION/)

---

## 🧭 NAVIGATION

**Entry points and quick access**

📁 `NAVIGATION/`

- [`INDEX.md`](./NAVIGATION/INDEX.md) - Complete navigation & search
- [`QUICK_REFERENCE.md`](./NAVIGATION/QUICK_REFERENCE.md) - Quick lookup by topic
- [`IMPLEMENTATION_STATUS.json`](./NAVIGATION/IMPLEMENTATION_STATUS.json) - Project progress

---

## 📦 ARCHIVED

**Future features and completed projects (reference only)**

📁 `archived/`

- Speculative features (AI Coach, Premium system, etc.)
- Completed project reports
- Historical documentation

---

## 🎯 Quick Navigation by Task

### "I need to implement..."
| Task | Start Here |
|------|-----------|
| **Workout timer system** | `UX_FLOWS/workout_session/TIMER_AUDIO_KB.md` |
| **Exercise insertion flow** | `UX_FLOWS/workout_session/EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md` |
| **Exercise database sync** | `UX_FLOWS/exercise_database/EXERCISE_DATABASE_SYNC_ARCHITECTURE.md` |
| **User authentication** | `UX_FLOWS/user_account/USER_MODELS_GUIDE.md` |
| **Multi-language support** | `UX_FLOWS/user_account/LOCALIZATION_GUIDE.md` |
| **iOS Live Activities** | `UX_FLOWS/workout_session/LIVE_ACTIVITY_KB.md` |

### "I'm hitting an error..."
| Error | Check Here |
|-------|-----------|
| **Build errors** | `TECHNICAL_FOUNDATION/ERROR_KB.md` |
| **Timer issues** | `UX_FLOWS/workout_session/TIMER_AUDIO_KB.md` |
| **Performance problems** | `TECHNICAL_FOUNDATION/PERFORMANCE_OPTIMIZATIONS.md` |

---

## 📋 Why Organized by UX Flows?

### ✅ Benefits
- **Intuitive navigation** - Find docs by what you're building, not by type
- **Feature-focused** - Related docs grouped together
- **Clearer scope** - Understand what belongs to each feature
- **Better for onboarding** - New devs understand user experience first

### Before (Technical Organization)
```
docs/
├── IMPLEMENTATION_GUIDES/
├── KNOWLEDGE_BASES/
├── ARCHITECTURE/
└── SETUP/
```

### After (UX Flow Organization)
```
docs/
├── UX_FLOWS/
│   ├── workout_session/        ← All workout-related docs
│   ├── exercise_database/      ← All exercise-related docs
│   ├── user_account/           ← All user-related docs
│   └── ...
├── TECHNICAL_FOUNDATION/       ← Generic technical docs
└── NAVIGATION/                 ← Entry points
```

---

## 🔗 Understanding Document Types

### ROE (Rules of Engagement)
**MANDATORY BEFORE IMPLEMENTING**
- Example: `EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md`
- Use when: Adding features in that domain
- Contains: Architecture templates, test requirements, best practices

### System Overview (Non-technical)
**FOR PMs/DESIGNERS/STAKEHOLDERS**
- Example: `WORKOUT_SYSTEM_OVERVIEW.md`
- Use when: Understanding user experience
- Contains: User flows, features, design decisions

### Knowledge Base (KB)
**REFERENCE & TROUBLESHOOTING**
- Example: `TIMER_AUDIO_KB.md`
- Use when: Debugging issues
- Contains: Common problems, solutions, technical details

### Architecture
**SYSTEM DESIGN**
- Example: `EXERCISE_DATABASE_SYNC_ARCHITECTURE.md`
- Use when: Understanding how systems interact
- Contains: Data flow, design decisions, patterns

---

## 📖 How to Use This Structure

1. **Finding documentation**:
   - If building a feature → Go to `UX_FLOWS/[feature]/`
   - If setting up infrastructure → Go to `TECHNICAL_FOUNDATION/`
   - If unsure where to start → Go to `NAVIGATION/INDEX.md`

2. **Adding new documentation**:
   - Read `.claude/hooks/document-categorization-guide.md` for rules
   - Place in appropriate UX_FLOWS/ subfolder or TECHNICAL_FOUNDATION/
   - Update `NAVIGATION/INDEX.md` with new entry

3. **Updating documentation**:
   - Find it in the appropriate folder
   - Update the content
   - Verify links still work in other docs

---

## ✅ All Documentation Locations

```
docs/
├── NAVIGATION/
│   ├── INDEX.md                                    ⭐ START HERE
│   ├── QUICK_REFERENCE.md
│   └── IMPLEMENTATION_STATUS.json
│
├── UX_FLOWS/
│   ├── workout_session/
│   │   ├── TIMER_AUDIO_KB.md
│   │   ├── LIVE_ACTIVITY_KB.md
│   │   ├── EXERCISE_CARD_DEVELOPMENT_GUIDE.md
│   │   ├── EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md
│   │   ├── EXERCISE_INSERTION_CUSTOMIZATION_GUIDE.md
│   │   ├── EXERCISE_INSERTION_SYSTEM_OVERVIEW.md
│   │   ├── WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md
│   │   ├── WORKOUT_SYSTEM_OVERVIEW.md
│   │   ├── DROPSET_RESTPAUSE_WORKFLOWS.md
│   │   ├── SET_DURATION_TRACKING_SYSTEM.md
│   │   └── Silent_Track_Background_Audio_Solution.md
│   │
│   ├── exercise_database/
│   │   ├── EXERCISE_DATABASE_SYNC_ARCHITECTURE.md
│   │   ├── EXERCISE_IMPLEMENTATION_PLAYBOOK.md
│   │   ├── EXERCISE_FEEDBACK_SYSTEM_ARCHITECTURE.md
│   │   ├── EXERCISE_FEEDBACK_DEV_GUIDE.md
│   │   └── EXERCISE_CARD_SYSTEM_OVERVIEW.md
│   │
│   ├── user_account/
│   │   ├── USER_MODELS_GUIDE.md
│   │   └── LOCALIZATION_GUIDE.md
│   │
│   ├── home_dashboard/
│   └── routine_templates/
│
├── TECHNICAL_FOUNDATION/
│   ├── HYBRID_ARCHITECTURE.md
│   ├── TECHNICAL_SPECIFICATION.md
│   ├── PERFORMANCE_OPTIMIZATIONS.md
│   ├── PRODUCTION_LOGGING_GUIDE.md
│   ├── ERROR_KB.md
│   ├── NOTIFICATION_SYSTEM_KB.md
│   ├── FIREBASE_APP_CHECK_SETUP.md
│   ├── IAP_SETUP_GUIDE.md
│   ├── ios_native_error_analysis.md
│   └── ANDROID_TIMER_INTEGRATION.md
│
└── archived/
    ├── AI_COACH_ARCHITECTURE.md
    ├── PREMIUM_DETECTION_SYSTEM.md
    ├── PROJECT_IMPLEMENTATION_REPORT_2025.md
    └── USER_MODEL_MIGRATION_EXAMPLE.md
```

---

**Last Updated**: October 18, 2025
**Structure**: UX Flow Based (NEW)
**Status**: ✅ Ready for use

→ **[Start with NAVIGATION/INDEX.md](./NAVIGATION/INDEX.md)**
