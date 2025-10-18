# 📚 Document Categorization Guide - Hook

> **Auto-triggered**: When creating or updating documentation

This hook provides guidance on **where to place documentation** based on the UX flow or technical domain it covers.

---

## 📂 Documentation Structure

```
docs/
├── NAVIGATION/                          # Entry points
│   ├── INDEX.md                        # Start here
│   ├── QUICK_REFERENCE.md              # Quick lookup
│   └── IMPLEMENTATION_STATUS.json       # Progress tracking
│
├── UX_FLOWS/                           # Organized by User Experience
│   ├── home_dashboard/                 # Home screen & dashboard
│   ├── workout_session/                # Workout execution (timer, exercises)
│   ├── exercise_database/              # Exercise management & database
│   ├── routine_templates/              # Routine & template system
│   └── user_account/                   # User auth & settings
│
├── TECHNICAL_FOUNDATION/               # Core technical docs
│   ├── Architecture & Design Patterns
│   ├── Setup & Configuration
│   └── Troubleshooting & Reference
│
├── archived/                           # Future features & old docs
│   └── (Speculative or completed projects)
│
└── CONDITIONAL/                        # May not be implemented
    ├── MISSING_EXERCISE_SYSTEM.md
    ├── QUESTIONNAIRE_ANALYTICS.md
    └── (Feature-specific, status unclear)
```

---

## 🎯 Document Categorization Rules

### Rule 1: UX Flow Documents
**When to use UX_FLOWS/**: Document describes a user-facing feature or workflow

#### HOME_DASHBOARD/
- Home screen overview
- Dashboard design
- Analytics display
- Recent workouts view

**Examples**:
- `HOME_SCREEN_DEVELOPMENT_GUIDE.md`
- `DASHBOARD_ANALYTICS_GUIDE.md`

#### WORKOUT_SESSION/
- Timer system
- Exercise selection & execution
- Set tracking
- Rest timers
- Live Activities (iOS)
- Reps/weight input
- Form validation

**Examples**:
- `TIMER_AUDIO_KB.md` ✅ (already placed)
- `EXERCISE_CARD_DEVELOPMENT_GUIDE.md` ✅ (already placed)
- `EXERCISE_INSERTION_DEVELOPMENT_GUIDE.md` ✅ (already placed)
- `WORKOUT_FEATURE_DEVELOPMENT_GUIDE.md` ✅ (already placed)

#### EXERCISE_DATABASE/
- Exercise database architecture
- Exercise sync & management
- Exercise feedback system
- Exercise card UI/UX
- Exercise search & filter
- Exercise categories

**Examples**:
- `EXERCISE_DATABASE_SYNC_ARCHITECTURE.md` ✅ (already placed)
- `EXERCISE_IMPLEMENTATION_PLAYBOOK.md` ✅ (already placed)
- `EXERCISE_FEEDBACK_SYSTEM_ARCHITECTURE.md` ✅ (already placed)

#### ROUTINE_TEMPLATES/
- Routine creation & management
- Template system
- Preset workouts
- Routine execution

**Examples**:
- (Currently no docs - create as needed)

#### USER_ACCOUNT/
- User authentication
- User models & structure
- Settings & preferences
- Localization & i18n
- Premium features
- User profile

**Examples**:
- `USER_MODELS_GUIDE.md` ✅ (already placed)
- `LOCALIZATION_GUIDE.md` ✅ (already placed)

---

### Rule 2: Technical Foundation Documents
**When to use TECHNICAL_FOUNDATION/**: Document describes architecture, patterns, or core technical concepts (not specific to one UX flow)

#### Types of Technical Docs
- **Architecture**: System design, data flow
- **Patterns**: Implementation patterns, design patterns
- **Setup**: Configuration, installation, initial setup
- **Troubleshooting**: Error KB, debugging guides
- **Performance**: Optimization guides, profiling
- **Security**: Auth, encryption, validation

**Examples**:
- `HYBRID_ARCHITECTURE.md` ✅ (already placed)
- `ERROR_KB.md` ✅ (already placed)
- `PERFORMANCE_OPTIMIZATIONS.md` ✅ (already placed)
- `NOTIFICATION_SYSTEM_KB.md` ✅ (already placed)

---

### Rule 3: Navigation Documents
**When to use NAVIGATION/**: Entry points and high-level navigation

- `INDEX.md` - Complete documentation index
- `QUICK_REFERENCE.md` - Quick lookup guide
- `IMPLEMENTATION_STATUS.json` - Progress tracking

**Never move these files** - they're the entry point!

---

### Rule 4: Archived Documents
**When to use archived/**: Future features or completed projects (reference only)

- Speculative features not yet implemented
- Completed migration docs (for reference)
- Historical project reports

**Examples**:
- `AI_COACH_ARCHITECTURE.md` (future feature)
- `PREMIUM_DETECTION_SYSTEM.md` (future feature)

---

### Rule 5: Conditional Documents
**When to use root docs (conditional)**: Status of implementation unclear

Place in `docs/` root if:
- Feature might be implemented
- Implementation status unclear
- Keep for future reference but not active

**Examples**:
- `MISSING_EXERCISE_SYSTEM.md` - If active, move to exercise_database/
- `QUESTIONNAIRE_ANALYTICS.md` - If active, move to home_dashboard/ or create analytics/

---

## ✅ Decision Tree

When adding or updating a document, ask these questions:

```
1. Is this for a user-facing feature/workflow?
   YES → Go to step 2
   NO  → Go to step 3

2. Which UX flow does it cover?
   - Home/Dashboard?     → HOME_DASHBOARD/
   - Workout execution?  → WORKOUT_SESSION/
   - Exercise management? → EXERCISE_DATABASE/
   - Routines/Templates? → ROUTINE_TEMPLATES/
   - User/Settings?      → USER_ACCOUNT/

3. Is this technical/architectural?
   YES → TECHNICAL_FOUNDATION/
   NO  → Go to step 4

4. Is this a navigation/entry point?
   YES → NAVIGATION/
   NO  → Go to step 5

5. Is this a future feature or archival?
   YES → archived/
   NO  → Root docs/ (conditional)
```

---

## 📝 Example Categorizations

### Example 1: REST Timer Documentation
```
Feature: Rest timer during workout
Coverage: Workout session, timer display, notifications

Decision:
1. User-facing? YES
2. Which flow? Workout execution
3. Category: WORKOUT_SESSION/

Result: docs/UX_FLOWS/workout_session/REST_TIMER_GUIDE.md
```

### Example 2: Firestore Architecture
```
Feature: Data synchronization architecture
Coverage: Database design, sync logic, offline support

Decision:
1. User-facing? NO
2. Technical/architectural? YES
3. Category: TECHNICAL_FOUNDATION/

Result: docs/TECHNICAL_FOUNDATION/FIRESTORE_SYNC_ARCHITECTURE.md
```

### Example 3: User Authentication
```
Feature: Sign-in flow, user models, authentication
Coverage: User login, authentication, user data structure

Decision:
1. User-facing? YES (partially)
2. Which flow? User account
3. Category: USER_ACCOUNT/

Result: docs/UX_FLOWS/user_account/AUTHENTICATION_GUIDE.md
```

### Example 4: Performance Optimization
```
Feature: General performance best practices
Coverage: Rendering, memory, CPU optimization

Decision:
1. User-facing? NO
2. Technical/architectural? YES
3. Category: TECHNICAL_FOUNDATION/

Result: docs/TECHNICAL_FOUNDATION/PERFORMANCE_OPTIMIZATION.md
```

---

## 🎯 When Updating Existing Documents

If updating an existing document:
1. **Check current location** - Is it in the right folder?
2. **If wrong folder** - Move it to appropriate UX flow or technical folder
3. **Update NAVIGATION/INDEX.md** - If moved, update the index links

---

## 📊 Current Status

### Organized by UX Flow
- ✅ WORKOUT_SESSION/ - 11 files (Timer, Exercise, Tracking)
- ✅ EXERCISE_DATABASE/ - 5 files (Database, Sync, Feedback)
- ✅ USER_ACCOUNT/ - 2 files (Auth, Localization)
- ⏳ HOME_DASHBOARD/ - 0 files (create as needed)
- ⏳ ROUTINE_TEMPLATES/ - 0 files (create as needed)

### Technical Foundation
- ✅ TECHNICAL_FOUNDATION/ - 10 files (Architecture, KB, Setup)

### Navigation
- ✅ NAVIGATION/ - 3 files (INDEX, QUICK_REFERENCE, STATUS)

### Archived
- ✅ archived/ - 4 files (Future features, completed projects)

### Conditional (Root)
- ⚠️ MISSING_EXERCISE_SYSTEM.md
- ⚠️ QUESTIONNAIRE_ANALYTICS.md

---

## 🚀 Implementation Tips

### When Creating New Documentation
1. **Ask yourself**: Which UX flow or technical area does this cover?
2. **Check decision tree**: Follow the categorization rules above
3. **Place in correct folder**: Use the folder structure
4. **Update NAVIGATION/INDEX.md**: Add entry to the appropriate section
5. **Add cross-links**: Link related docs in other folders

### Organizing Existing Documentation
1. **Review current placements** - Are docs in the right UX flow?
2. **Move misplaced files** - Use the decision tree to recategorize
3. **Update INDEX.md** - Keep it in sync with folder structure
4. **Consolidate duplicates** - Merge if documentation overlaps

---

## ✅ Checklist for New Documentation

- [ ] Decided on correct category using decision tree
- [ ] File is in appropriate UX_FLOWS/, TECHNICAL_FOUNDATION/, NAVIGATION/, or archived/ folder
- [ ] File name clearly describes content (e.g., `REST_TIMER_GUIDE.md` not `guide.md`)
- [ ] Added entry to NAVIGATION/INDEX.md
- [ ] Linked to related documentation in other folders
- [ ] Follows project documentation standards (from CLAUDE.md)

---

## 🆘 If Unsure

When unsure about categorization:
1. **Check similar documentation** - Is there a similar doc? Where is it placed?
2. **Ask yourself**: Is this user-facing or technical?
3. **Default to TECHNICAL_FOUNDATION/** - If still unsure, this is the safest place
4. **Create MissingCategory issue** - If new category needed

---

**Last Updated**: October 18, 2025
**Status**: Active - Use this guide when categorizing new documentation
