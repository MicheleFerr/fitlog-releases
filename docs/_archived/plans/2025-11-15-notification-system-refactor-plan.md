# Notification System Refactoring & UX Optimization - Task Plan

**Generated**: 2025-11-15 (manual processing due to timestamp)
**Source**: task-master.dev (WebFetch) + Claude enrichment
**Complexity Score**: HIGH
**Reason**: Multi-system refactor + UX research + Market analysis + 24 tasks spanning research → implementation → testing
**Total Tasks**: 24
**Estimated Time**: ~26-30 hours
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: 3.16.0
- Key Packages: flutter_riverpod ^2.4.9, firebase_core, flutter_local_notifications
- Target Platforms: iOS 14+, Android 8+
- Related PRs/Issues: None
- Parent Milestone: None

---

## 📋 Original Request

> Analizza approfonditamente il sistema di notifiche, voglio refattorizzare migliorando il tutto ed ottimizzando il flusso UX sulla base di analisi di mercato veritiere

---

## 🏗️ Current System Analysis (Pre-Implementation)

### ✅ STRENGTHS (Already Implemented)

**Domain Layer** (`lib/features/notifications/domain/`):
- ✅ Intelligent rules engine (`CheckNotificationRules`) - Transparent, no-AI logic
- ✅ Smart scheduler (`ScheduleWorkoutReminders`) - User-preferred timing
- ✅ Rich entities: `NotificationDecision`, `ScheduleResult`, `WorkoutNotification`
- ✅ Intelligent notification service with workout analysis
- ✅ Analytics service for notification performance tracking

**Data Layer** (`lib/features/notifications/data/`):
- ✅ Repository pattern (`LocalNotificationRepository`, `SimpleNotificationRepository`)
- ✅ FCM integration (`fcm_service.dart`)
- ✅ Timezone handling (`timezone_helper.dart`)

**Presentation Layer** (`lib/features/notifications/presentation/`):
- ✅ Platform adapters (iOS/Android with factory pattern)
- ✅ Riverpod providers (legacy + unified migration pattern)
- ✅ Notification settings screen with permission handling
- ✅ Notification hub widget with unread badge
- ✅ Analytics dashboard
- ✅ Service initializer pattern

**UX Features**:
- ✅ Permission request UI
- ✅ Toggle controls for notification types (workout reminders, recovery alerts, achievements, streak milestones)
- ✅ Pending notifications count display
- ✅ Theme-aware UI (`context.colors.*`)
- ✅ Icon system compliance (`AppIcons.*`)

### ❌ WEAKNESSES & GAPS (To Address)

**UX/UI Gaps**:
- ❌ No market research validation (Strong, Fitbod, Hevy comparison)
- ❌ No user retention studies applied to timing/frequency
- ❌ No in-app notification center/history (only hub widget)
- ❌ No quiet hours/do-not-disturb integration
- ❌ No per-category granular controls (e.g., only achievements at 9 PM)
- ❌ No notification preview/test mechanism
- ❌ Missing localization strings (`context.l10n` TODO markers found)
- ❌ No onboarding for notification preferences
- ❌ No analytics dashboard for user engagement (basic tracking exists, no UI)

**Technical Gaps**:
- ❌ No GDPR compliance audit (consent flows, data retention)
- ❌ No iOS Live Activities integration for persistent workout notifications
- ❌ Migration pattern still in progress (bridge providers indicate transition)
- ❌ No comprehensive integration tests for scheduling flows
- ❌ No widget tests for settings screen
- ❌ No frequency capping (daily limit enforcement)
- ❌ No smart timing based on user activity patterns (only fixed preferred hour)
- ❌ No A/B testing framework for notification strategies

**Documentation Gaps**:
- ❌ No architecture documentation in `docs/`
- ❌ No user guide for notification preferences
- ❌ No release notes for notification features
- ❌ No market research summary document

---

## 🎯 Task Breakdown

### PHASE 1: RESEARCH (3 tasks, ~3.25h)

#### **Task 1.1: Market Competitor Analysis**
- **Category**: Research
- **Layer**: N/A (Documentation)
- **Files**: `docs/research/notification_competitor_analysis.md` (NEW)
- **Dependencies**: None (BLOCKING for Tasks 1.2, 6.1)
- **Est. Time**: 1.5h
- **Blocking**: YES
- **Description**:
  - Analyze notification patterns in 5+ fitness apps: Strong, Fitbod, Hevy, Nike Training Club, MyFitnessPal
  - Document:
    - Timing strategies (morning/evening, pre/post workout)
    - Frequency patterns (daily max, weekly rhythm)
    - Personalization methods (user preference, ML-based timing)
    - Retention metrics (if public data available)
    - Permission request UX (when/how asked)
    - Notification content types (motivation, reminders, achievements, social)
- **Verification**:
  - ✅ Competitive matrix with 5+ apps completed
  - ✅ Timing patterns documented with screenshots
  - ✅ Engagement triggers identified (3+ per app)
  - ✅ Document saved in `docs/research/`
- **Code Prompt**: N/A (manual research)

---

#### **Task 1.2: User Retention & UX Research**
- **Category**: Research
- **Layer**: N/A (Documentation)
- **Files**: `docs/research/notification_retention_study.md` (NEW)
- **Dependencies**: Task 1.1 (BLOCKING for Task 6.1)
- **Est. Time**: 1h
- **Blocking**: YES
- **Description**:
  - Research notification fatigue thresholds from published studies
  - Optimal delivery windows (time-of-day, day-of-week patterns)
  - Engagement patterns (click-through rates, dismissal rates)
  - Find sources: Google Scholar, UX research blogs, app retention case studies
  - Target: 3+ credible sources (academic papers, industry reports)
- **Verification**:
  - ✅ Research summary with 3+ sources cited
  - ✅ Retention benchmarks identified (e.g., "max 2 notifications/day = 15% lower churn")
  - ✅ Optimal frequency ranges documented (e.g., "3-5 reminders/week optimal")
  - ✅ Document saved in `docs/research/`
- **Code Prompt**: N/A (manual research)

---

#### **Task 1.3: Privacy & Compliance Audit**
- **Category**: Research
- **Layer**: N/A (Legal/Compliance)
- **Files**: `docs/compliance/notification_gdpr_audit.md` (NEW)
- **Dependencies**: None
- **Est. Time**: 45min
- **Blocking**: NO (but informs Task 7.1)
- **Description**:
  - Map current implementation against GDPR Article 7 (user consent)
  - Review iOS 14+ privacy requirements (AppTrackingTransparency, notification permissions)
  - Check Android 13+ notification permission flows
  - Identify gaps in:
    - Consent collection (explicit opt-in)
    - Data handling (what notification data is stored)
    - User control (ability to revoke, export data)
    - Retention policies (how long notification logs kept)
- **Verification**:
  - ✅ Compliance checklist created (GDPR + iOS + Android)
  - ✅ Gaps identified with severity ratings (CRITICAL/MEDIUM/LOW)
  - ✅ Recommendation summary (3+ action items)
  - ✅ Document saved in `docs/compliance/`
- **Code Prompt**: N/A (manual audit)

---

### PHASE 2: ANALYSIS (4 tasks, ~4.25h)

#### **Task 2.1: Current System Strengths Assessment**
- **Category**: Analysis
- **Layer**: N/A (Documentation)
- **Files**: `docs/architecture/notification_system_strengths.md` (NEW)
- **Dependencies**: None
- **Est. Time**: 1h
- **Blocking**: NO (but informs design decisions)
- **Description**:
  - Evaluate existing rules engine (`CheckNotificationRules`) - Strength: Transparent logic, no AI black box
  - Evaluate scheduler (`ScheduleWorkoutReminders`) - Strength: User-preferred timing
  - Document architecture patterns worth keeping:
    - Clean Architecture layers (domain/data/presentation)
    - Platform adapter factory pattern
    - Riverpod provider structure
    - Entity-driven design (`NotificationDecision`, `ScheduleResult`)
  - Code quality assessment (readability, testability, extensibility)
- **Verification**:
  - ✅ Architecture overview documented
  - ✅ Strength list (3+ major strengths)
  - ✅ Code quality assessment (score 1-10 with reasoning)
  - ✅ Patterns to preserve identified
- **Code Prompt**: N/A (manual analysis)

---

#### **Task 2.2: Current System Weaknesses Audit**
- **Category**: Analysis
- **Layer**: N/A (Documentation)
- **Files**: `docs/architecture/notification_system_weaknesses.md` (NEW)
- **Dependencies**: Task 2.1
- **Est. Time**: 1h
- **Blocking**: YES (blocks all design tasks)
- **Description**:
  - Identify pain points:
    - Timing logic: Only supports single preferred hour (no smart timing based on activity)
    - Preference handling: Coarse-grained toggles (no per-category timing)
    - Background delivery: No frequency capping enforcement
    - User control: No quiet hours, no per-notification opt-out
  - UX friction points:
    - No notification preview
    - No test notification mechanism
    - Missing localization strings
    - No onboarding for preferences
  - Technical debt:
    - Migration in progress (bridge providers)
    - Missing integration tests
    - No Live Activities integration
- **Verification**:
  - ✅ Weakness inventory (5+ items)
  - ✅ Impact severity ratings (CRITICAL/MEDIUM/LOW)
  - ✅ UX friction points documented (3+ items)
  - ✅ Technical debt prioritized
- **Code Prompt**: N/A (manual analysis)

---

#### **Task 2.3: UX Flow Gap Analysis**
- **Category**: Analysis
- **Layer**: N/A (Documentation)
- **Files**: `docs/ux_flows/notification_gap_analysis.md` (NEW)
- **Dependencies**: Tasks 1.1, 1.2, 2.2
- **Est. Time**: 1.5h
- **Blocking**: YES (blocks Task 3.2, 3.3)
- **Description**:
  - Map current user journey:
    1. App install → Permission request
    2. Settings → Toggle notification types
    3. Background → Receive scheduled notification
    4. Tap notification → Navigate to app
  - Compare against market best practices (from Task 1.1)
  - Identify missed opportunities:
    - Personalization: No ML/activity-based timing
    - Control: No granular timing per category
    - Feedback: No notification engagement analytics shown to user
    - Discovery: No in-app notification center/history
  - Create current vs. ideal flow diagrams (Mermaid or Figma)
- **Verification**:
  - ✅ Current flow diagram created
  - ✅ Ideal flow diagram created (based on research)
  - ✅ Gap analysis matrix (current vs. ideal)
  - ✅ Improvement opportunities ranked (ROI score)
- **Code Prompt**: N/A (manual analysis + diagramming)

---

#### **Task 2.4: Localization & Theme Integration Audit**
- **Category**: Analysis
- **Layer**: Presentation
- **Files**: `lib/features/notifications/presentation/**/*.dart` (existing files)
- **Dependencies**: None
- **Est. Time**: 45min
- **Blocking**: NO (but informs Task 5.2)
- **Description**:
  - Review all presentation layer files for:
    - Hardcoded strings (should be `context.l10n.*`)
    - Hardcoded colors (should be `context.colors.*`)
    - Missing `AppIcons.*` usage
  - Run pre-commit hook checks on notification feature
  - Identify missing localization keys in `assets/i18n/app_en.arb` and `app_it.arb`
  - Check theme switching behavior in notification settings screen
- **Verification**:
  - ✅ Audit report created (list of violations)
  - ✅ Missing strings identified (count + list)
  - ✅ Theme token gaps identified
  - ✅ Consistency check completed (0 violations after fixes)
- **Code Prompt**:
  ```bash
  # Run localization check
  ./scripts/find_hardcoded_strings.sh lib/features/notifications/

  # Run theme check
  ./scripts/fix_theme_violations.sh --dry-run --file lib/features/notifications/
  ```

---

### PHASE 3: DESIGN (5 tasks, ~6.5h)

#### **Task 3.1: Notification Rules Engine Redesign**
- **Category**: Design
- **Layer**: Domain
- **Files**:
  - `lib/features/notifications/domain/entities/notification_rule.dart` (NEW)
  - `lib/features/notifications/domain/entities/frequency_cap.dart` (NEW)
  - `lib/features/notifications/domain/value_objects/time_window.dart` (NEW)
- **Dependencies**: Tasks 2.2, 2.3
- **Est. Time**: 1.5h
- **Blocking**: YES (blocks Task 4.1)
- **Description**:
  - Define enhanced domain model for rules:
    - **Frequency caps**: `maxPerDay`, `maxPerWeek`, `minIntervalHours`
    - **Smart timing**: Activity-based prediction (e.g., "2 hours after last workout" if user typically works out daily)
    - **User segments**: Beginner (more motivational), Advanced (less frequent, data-driven)
  - Sketch domain layer changes:
    - `NotificationRule` entity with `FrequencyCap`, `TimeWindow`, `UserSegment`
    - Updated `CheckNotificationRules` use case with cap enforcement
    - New `PredictOptimalTime` use case (basic heuristic, not ML)
  - Define edge cases:
    - What if user changes preferred time mid-week?
    - What if user disables/re-enables notifications?
    - How to handle timezone changes?
- **Verification**:
  - ✅ Updated domain models documented (Mermaid class diagrams)
  - ✅ Rule examples defined (3+ scenarios)
  - ✅ Edge cases identified (5+ cases with handling strategy)
  - ✅ Migration path from old to new rules defined
- **Code Prompt**: N/A (design phase - no code yet)

---

#### **Task 3.2: User Preference Model Enhancement**
- **Category**: Design
- **Layer**: Domain
- **Files**:
  - `lib/features/notifications/domain/entities/notification_preferences.dart` (UPDATE)
  - `lib/features/notifications/domain/value_objects/quiet_hours.dart` (NEW)
- **Dependencies**: Task 2.3
- **Est. Time**: 1h
- **Blocking**: YES (blocks Task 4.2)
- **Description**:
  - Design preference schema supporting:
    - **Granular control by category**: `workoutReminders`, `achievements`, `streaks`, `social` (each with own `TimeWindow`)
    - **Quiet hours**: `startTime`, `endTime`, `daysOfWeek` (e.g., no notifications 10 PM - 8 AM on weekdays)
    - **Do-not-disturb integration**: Respect system DND on iOS/Android
    - **Snooze preferences**: `snoozeIntervalMinutes`, `maxSnoozeCount`
  - Update `NotificationPreferences` entity (currently exists in presentation layer - MOVE to domain)
  - Design Firestore schema for remote sync:
    ```json
    {
      "userId": "...",
      "preferences": {
        "workoutReminders": { "enabled": true, "timeWindow": "18:00-20:00" },
        "achievements": { "enabled": true, "timeWindow": "any" },
        "quietHours": { "start": "22:00", "end": "08:00", "days": ["mon", "tue"] }
      },
      "updatedAt": "2025-11-15T10:00:00Z"
    }
    ```
  - Define migration strategy from current boolean toggles to new schema
- **Verification**:
  - ✅ Schema diagram created (entity + value objects)
  - ✅ Firestore schema defined (JSON example)
  - ✅ Migration strategy outlined (3-step process)
  - ✅ Backward compatibility ensured (old apps can still read new schema)
- **Code Prompt**: N/A (design phase - no code yet)

---

#### **Task 3.3: Presentation Layer UX Redesign**
- **Category**: Design
- **Layer**: Presentation
- **Files**:
  - `docs/ux_flows/notification_settings_wireframes.md` (NEW)
  - `docs/ux_flows/notification_center_wireframes.md` (NEW)
- **Dependencies**: Tasks 2.3, 3.2
- **Est. Time**: 1.5h
- **Blocking**: YES (blocks Tasks 5.1, 5.2, 5.3)
- **Description**:
  - Create wireframes/flows for:
    1. **Settings screen redesign**:
       - Section 1: Permission status banner
       - Section 2: Notification types (workout, achievements, streaks, social) with per-type time pickers
       - Section 3: Quiet hours configuration (start/end time + days of week)
       - Section 4: Advanced (frequency caps, test notification button)
    2. **In-app notification center** (NEW screen):
       - List of past notifications (last 30 days)
       - Filter by type (all, achievements, reminders)
       - Actions: Mark as read, delete, archive
       - Empty state illustration
    3. **Onboarding flow** (NEW):
       - Step 1: Permission request with benefit explanation
       - Step 2: Choose preferred notification time
       - Step 3: Select notification types
       - Skip option available
  - Define dark/light theme specs for each component
  - List all localization keys needed (30+ strings estimated)
  - Define animation/transition specs (slide-in for notification center, fade for badges)
- **Verification**:
  - ✅ Wireframes created (Figma or Mermaid diagrams)
  - ✅ Localization keys listed (app_en.arb format)
  - ✅ Animation/transition specs defined
  - ✅ Dark/light theme mockups created
- **Code Prompt**: N/A (design phase - no code yet)

---

#### **Task 3.4: Live Activities Integration Plan** (iOS-specific)
- **Category**: Design
- **Layer**: Presentation (iOS native)
- **Files**:
  - `docs/platform_specific/ios_live_activities_notification.md` (NEW)
  - `ios/Runner/NotificationLiveActivity/` (NEW directory planned)
- **Dependencies**: Task 3.2
- **Est. Time**: 1h
- **Blocking**: NO (iOS-only feature, not critical path)
- **Description**:
  - Design iOS Live Activities models for persistent workout notifications:
    - **Use case**: Show "Rest timer" Live Activity during workout (e.g., "30s rest remaining")
    - **Use case**: Show "Workout in progress" with elapsed time + current exercise
  - Define data flow:
    1. Flutter app starts workout → Sends ActivityKit push via platform channel
    2. Swift `NotificationLiveActivity` receives data
    3. Live Activity updates on lock screen/Dynamic Island
    4. User taps → Deep link back to workout screen
  - Define ActivityAttributes struct (Swift):
    ```swift
    struct WorkoutActivityAttributes: ActivityAttributes {
      var workoutName: String
      var startTime: Date
    }
    struct WorkoutActivityState {
      var currentExercise: String
      var restTimeRemaining: Int
    }
    ```
  - Plan platform channel communication:
    - Method: `startLiveActivity(workoutId, workoutName)`
    - Method: `updateLiveActivity(state)`
    - Method: `stopLiveActivity()`
- **Verification**:
  - ✅ Live Activities entities sketched (Swift structs)
  - ✅ Data flow diagram created (Flutter ↔ Swift)
  - ✅ iOS-specific considerations documented (iOS 16.1+ requirement)
  - ✅ Platform channel contract defined
- **Code Prompt**: N/A (design phase - Swift code in later task)

---

#### **Task 3.5: Data Layer & Persistence Strategy**
- **Category**: Design
- **Layer**: Data
- **Files**:
  - `lib/features/notifications/domain/repositories/notification_preference_repository.dart` (UPDATE interface)
  - `lib/features/notifications/domain/repositories/notification_log_repository.dart` (NEW interface)
- **Dependencies**: Tasks 3.1, 3.2
- **Est. Time**: 1h
- **Blocking**: YES (blocks Task 4.3)
- **Description**:
  - Design repository pattern for:
    1. **Notification preferences**: Local (Hive) + Remote (Firestore) sync
       - Methods: `getPreferences()`, `updatePreferences()`, `syncWithRemote()`
       - Conflict resolution: Last-write-wins (Firestore timestamp)
    2. **Delivery logs**: Track when notifications were sent/clicked
       - Methods: `logDelivery()`, `logClick()`, `getHistory(days: 30)`
       - Storage: Local only (Hive), no remote sync (privacy)
    3. **Scheduling state**: Track next scheduled notification time
       - Methods: `getNextScheduledTime()`, `setNextScheduledTime()`
       - Storage: In-memory (Riverpod state) + Local persistence (Hive backup)
  - Define data models:
    - `NotificationPreferencesModel` (Hive + Firestore compatible)
    - `NotificationLogModel` (Hive only)
    - `SchedulingStateModel` (in-memory + Hive)
  - Define sync strategy:
    - On app start: Load local → Sync with remote → Merge
    - On preference change: Update local → Update remote (background)
    - On offline: Queue changes → Sync when online
- **Verification**:
  - ✅ Repository interfaces defined (Dart abstract classes)
  - ✅ Data models created (Hive `@HiveType` + Firestore converters)
  - ✅ Sync strategy documented (state machine diagram)
  - ✅ Offline resilience planned (queue + retry logic)
- **Code Prompt**: N/A (design phase - no code yet)

---

### PHASE 4: IMPLEMENTATION (7 tasks, ~10.5h)

#### **Task 4.1: Domain Layer Refactoring**
- **Category**: Implementation
- **Layer**: Domain
- **Files**:
  - `lib/features/notifications/domain/entities/notification_rule.dart` (NEW)
  - `lib/features/notifications/domain/entities/frequency_cap.dart` (NEW)
  - `lib/features/notifications/domain/value_objects/time_window.dart` (NEW)
  - `lib/features/notifications/domain/value_objects/quiet_hours.dart` (NEW)
  - `lib/features/notifications/domain/usecases/check_notification_rules.dart` (UPDATE)
  - `lib/features/notifications/domain/usecases/predict_optimal_time.dart` (NEW)
- **Dependencies**: Task 3.1
- **Est. Time**: 1.5h
- **Blocking**: YES (blocks Tasks 4.3, 5.4)
- **Description**:
  - Implement new entities from Task 3.1 design:
    - `NotificationRule` with freezed + equatable
    - `FrequencyCap` value object (immutable, validation logic)
    - `TimeWindow` value object (start/end time, validation)
    - `QuietHours` value object (from Task 3.2 design)
  - Update `CheckNotificationRules` use case:
    - Add frequency cap enforcement (check against `NotificationLogRepository`)
    - Add quiet hours check (skip notification if in quiet window)
    - Add time window validation (per-category timing)
  - Implement `PredictOptimalTime` use case (basic heuristic):
    ```dart
    // If user typically works out at 6 PM, suggest notification at 5:30 PM
    // If user inconsistent, default to user-preferred time
    DateTime predict({
      required List<DateTime> recentWorkoutTimes,
      required int preferredHour,
    });
    ```
  - Ensure all entities return `Either<Failure, Success>` for error handling
- **Verification**:
  - ✅ All entities implement equatable (for Riverpod state comparison)
  - ✅ Use cases return `Either<Failure, T>` (fpdart or dartz)
  - ✅ Unit tests pass (write basic tests for each entity)
  - ✅ `flutter analyze` passes with 0 errors
- **Code Prompt**:
  ```dart
  // Create FrequencyCap value object with validation
  class FrequencyCap {
    const FrequencyCap({
      required this.maxPerDay,
      required this.maxPerWeek,
      required this.minIntervalHours,
    });

    final int maxPerDay;
    final int maxPerWeek;
    final int minIntervalHours;

    // Validation: maxPerDay * 7 >= maxPerWeek
    bool get isValid => maxPerDay * 7 >= maxPerWeek;
  }
  ```

---

#### **Task 4.2: Data Layer Repository Implementation**
- **Category**: Implementation
- **Layer**: Data
- **Files**:
  - `lib/features/notifications/data/repositories/notification_preference_repository_impl.dart` (NEW)
  - `lib/features/notifications/data/repositories/notification_log_repository_impl.dart` (NEW)
  - `lib/features/notifications/data/models/notification_preferences_model.dart` (NEW)
  - `lib/features/notifications/data/models/notification_log_model.dart` (NEW)
  - `lib/features/notifications/data/datasources/notification_local_datasource.dart` (NEW)
  - `lib/features/notifications/data/datasources/notification_remote_datasource.dart` (NEW)
- **Dependencies**: Tasks 3.5, 4.1
- **Est. Time**: 1.5h
- **Blocking**: YES (blocks Task 4.3)
- **Description**:
  - Build `NotificationPreferenceRepositoryImpl`:
    - CRUD operations: `get()`, `update()`, `delete()`
    - Sync logic: `syncWithRemote()` (merge local + remote, last-write-wins)
    - Hive box: `notificationPreferences`
    - Firestore collection: `users/{userId}/notificationPreferences`
  - Build `NotificationLogRepositoryImpl`:
    - Methods: `logDelivery()`, `logClick()`, `getHistory(days: 30)`, `clearOldLogs()`
    - Hive box: `notificationLogs` (local only, no remote sync)
    - Retention: Auto-delete logs older than 90 days
  - Create data models:
    - `NotificationPreferencesModel` with Hive `@HiveType` + Firestore `toJson/fromJson`
    - `NotificationLogModel` with Hive `@HiveType`
  - Error handling: All methods return `Either<Failure, T>` (network errors, parsing errors)
  - Offline resilience: Queue write operations when offline → Sync when online
- **Verification**:
  - ✅ CRUD operations verified (unit tests with mocked datasources)
  - ✅ Error handling tested (network failure, parsing error scenarios)
  - ✅ Offline resilience confirmed (queue + retry tested)
  - ✅ Hive migration tested (old schema → new schema)
- **Code Prompt**:
  ```dart
  // NotificationPreferencesModel with Hive + Firestore
  @HiveType(typeId: 15)
  class NotificationPreferencesModel {
    @HiveField(0)
    final String userId;

    @HiveField(1)
    final Map<String, CategoryPreference> categories;

    @HiveField(2)
    final QuietHours? quietHours;

    // Firestore converter
    Map<String, dynamic> toJson() => {...};
    factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) => ...;
  }
  ```

---

#### **Task 4.3: Riverpod Provider Architecture**
- **Category**: Implementation
- **Layer**: Presentation
- **Files**:
  - `lib/features/notifications/presentation/providers/notification_preference_provider.dart` (NEW)
  - `lib/features/notifications/presentation/providers/notification_log_provider.dart` (NEW)
  - `lib/features/notifications/presentation/providers/notification_scheduling_provider.dart` (NEW)
  - `lib/features/notifications/presentation/providers/notification_providers.dart` (UPDATE)
- **Dependencies**: Tasks 4.1, 4.2
- **Est. Time**: 1.5h
- **Blocking**: YES (blocks Tasks 5.1, 5.2)
- **Description**:
  - Create `notificationPreferenceProvider` (StateNotifierProvider):
    - State: `AsyncValue<NotificationPreferences>`
    - Methods: `updateCategory(categoryId, newPreference)`, `setQuietHours(quietHours)`, `syncWithRemote()`
    - Auto-sync on update (background Firestore write)
  - Create `notificationLogProvider` (Provider):
    - Methods: `logDelivery(notificationId)`, `logClick(notificationId)`, `getHistory(days)`
    - Read-only for UI (logs are fire-and-forget)
  - Create `notificationSchedulingProvider` (StateNotifierProvider):
    - State: `AsyncValue<SchedulingState>` (next scheduled time, enabled categories)
    - Methods: `recalculateNextTime()`, `cancelScheduled()`, `forceScheduleNow()`
    - Watches `notificationPreferenceProvider` → Auto-recalculate on preference change
  - Update `notification_providers.dart`:
    - Export all new providers
    - Deprecate old bridge providers (mark with `@Deprecated`)
  - Follow naming conventions: `notificationXxxProvider`, not `xxxNotificationProvider`
  - Ensure immutability: All state updates create new objects (not mutate)
- **Verification**:
  - ✅ Providers follow naming conventions
  - ✅ State immutability verified (use freezed for state classes)
  - ✅ Dependencies properly scoped (no circular dependencies)
  - ✅ Auto-sync tested (preference update → Firestore write confirmed)
- **Code Prompt**:
  ```dart
  final notificationPreferenceProvider = StateNotifierProvider<
    NotificationPreferenceNotifier,
    AsyncValue<NotificationPreferences>
  >((ref) {
    final repository = ref.watch(notificationPreferenceRepositoryProvider);
    return NotificationPreferenceNotifier(repository);
  });

  class NotificationPreferenceNotifier extends StateNotifier<AsyncValue<NotificationPreferences>> {
    NotificationPreferenceNotifier(this._repository) : super(const AsyncValue.loading()) {
      _init();
    }

    final NotificationPreferenceRepository _repository;

    Future<void> _init() async {
      state = const AsyncValue.loading();
      final result = await _repository.get();
      state = result.fold(
        (failure) => AsyncValue.error(failure, StackTrace.current),
        (prefs) => AsyncValue.data(prefs),
      );
    }

    Future<void> updateCategory(String categoryId, CategoryPreference newPref) async {
      // Create new state with updated category
      final current = state.value;
      if (current == null) return;

      final updated = current.copyWith(
        categories: {...current.categories, categoryId: newPref},
      );

      state = AsyncValue.data(updated);

      // Background sync
      await _repository.update(updated);
    }
  }
  ```

---

#### **Task 5.1: Notification Settings UI (Presentation)**
- **Category**: Implementation
- **Layer**: Presentation
- **Files**:
  - `lib/features/notifications/presentation/screens/notification_settings_screen.dart` (UPDATE)
  - `lib/features/notifications/presentation/widgets/category_preference_card.dart` (NEW)
  - `lib/features/notifications/presentation/widgets/quiet_hours_picker.dart` (NEW)
  - `lib/features/notifications/presentation/widgets/test_notification_button.dart` (NEW)
- **Dependencies**: Tasks 3.3, 4.3
- **Est. Time**: 2h
- **Blocking**: NO
- **Description**:
  - Rebuild settings screen with new UX design from Task 3.3:
    - Section 1: Permission status banner (existing, keep)
    - Section 2: Category preferences (NEW widget `CategoryPreferenceCard`)
      - Per-category toggle + time window picker
      - Categories: Workout Reminders, Achievements, Streaks, Social
    - Section 3: Quiet hours configuration (NEW widget `QuietHoursPicker`)
      - Start/end time pickers (Material TimePicker)
      - Days of week multi-select (CheckboxListTile)
    - Section 4: Advanced (NEW expandable section)
      - Frequency cap display (read-only for now, "Max 3/day, 10/week")
      - Test notification button (NEW widget `TestNotificationButton`)
  - Apply theme: `context.colors.*` for all colors
  - Apply localization: `context.l10n.*` for all strings
  - Apply icons: `AppIcons.*` for all icons
  - Add translations to `assets/i18n/app_en.arb` and `app_it.arb` (30+ strings)
  - Test in dark/light themes
- **Verification**:
  - ✅ All screens render correctly (no overflow, proper padding)
  - ✅ Theme switching works (light ↔ dark)
  - ✅ Localization strings present (EN + IT)
  - ✅ `flutter analyze` passes (0 errors)
  - ✅ iOS AND Android tested (platform-specific time pickers work)
- **Code Prompt**:
  ```dart
  class CategoryPreferenceCard extends ConsumerWidget {
    const CategoryPreferenceCard({
      required this.category,
      required this.preference,
      required this.onToggle,
      required this.onTimeWindowChange,
      super.key,
    });

    final String category;
    final CategoryPreference preference;
    final ValueChanged<bool> onToggle;
    final ValueChanged<TimeWindow?> onTimeWindowChange;

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ExpansionTile(
          leading: Icon(
            _getCategoryIcon(category),
            color: preference.enabled ? context.colors.primary : context.colors.onSurfaceVariant,
          ),
          title: Text(
            _getCategoryTitle(context, category),
            style: context.textTheme.titleMedium,
          ),
          subtitle: Text(
            preference.timeWindow != null
              ? '${preference.timeWindow!.start} - ${preference.timeWindow!.end}'
              : context.l10n.anytime,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          trailing: Switch(
            value: preference.enabled,
            onChanged: onToggle,
          ),
          children: [
            if (preference.enabled) _buildTimeWindowPicker(context),
          ],
        ),
      );
    }

    Widget _buildTimeWindowPicker(BuildContext context) {
      // TimePicker for start/end time
      // ...
    }
  }
  ```

---

#### **Task 5.2: Localization String Addition**
- **Category**: Implementation
- **Layer**: Presentation (i18n)
- **Files**:
  - `assets/i18n/app_en.arb` (UPDATE)
  - `assets/i18n/app_it.arb` (UPDATE)
- **Dependencies**: Task 5.1
- **Est. Time**: 30min
- **Blocking**: NO (but required for UI to work)
- **Description**:
  - Add all missing localization strings from Task 3.3 design:
    - Settings screen strings (30+ keys)
    - Notification center strings (20+ keys)
    - Onboarding strings (10+ keys)
  - Format: Follow existing ARB structure
  - English strings: Write clear, concise labels (e.g., "Quiet Hours", "Test Notification")
  - Italian translations: Professionally translated (use DeepL or professional translator)
  - Run `flutter gen-l10n` after adding strings
- **Verification**:
  - ✅ All strings added to both `app_en.arb` and `app_it.arb`
  - ✅ `flutter gen-l10n` runs successfully (0 errors)
  - ✅ Strings render correctly in app (EN and IT)
  - ✅ No hardcoded strings remain (pre-commit hook passes)
- **Code Prompt**:
  ```json
  // app_en.arb
  {
    "notificationSettingsTitle": "Notification Settings",
    "notificationCategoryWorkout": "Workout Reminders",
    "notificationCategoryAchievements": "Achievements",
    "notificationCategoryStreaks": "Streaks",
    "notificationCategorySocial": "Social",
    "quietHours": "Quiet Hours",
    "quietHoursDescription": "Do not send notifications during these hours",
    "testNotification": "Test Notification",
    "testNotificationDescription": "Send a test notification to verify settings",
    ...
  }

  // app_it.arb
  {
    "notificationSettingsTitle": "Impostazioni Notifiche",
    "notificationCategoryWorkout": "Promemoria Allenamenti",
    "notificationCategoryAchievements": "Obiettivi Raggiunti",
    "notificationCategoryStreaks": "Serie",
    "notificationCategorySocial": "Sociale",
    "quietHours": "Ore Silenziose",
    "quietHoursDescription": "Non inviare notifiche durante questi orari",
    "testNotification": "Notifica di Prova",
    "testNotificationDescription": "Invia una notifica di prova per verificare le impostazioni",
    ...
  }
  ```

---

#### **Task 5.3: Notification Center & History**
- **Category**: Implementation
- **Layer**: Presentation
- **Files**:
  - `lib/features/notifications/presentation/screens/notification_center_screen.dart` (NEW)
  - `lib/features/notifications/presentation/widgets/notification_history_list.dart` (NEW)
  - `lib/features/notifications/presentation/widgets/notification_item_card.dart` (NEW)
  - `lib/features/notifications/presentation/widgets/notification_filter_chips.dart` (NEW)
  - `lib/features/notifications/presentation/widgets/notification_empty_state.dart` (NEW)
- **Dependencies**: Tasks 3.3, 4.3
- **Est. Time**: 1.5h
- **Blocking**: NO
- **Description**:
  - Implement in-app notification center screen:
    - AppBar: Title "Notifications" + filter icon
    - Filter chips: All, Achievements, Reminders, Streaks (horizontal scroll)
    - List: Last 30 days of notifications (from `notificationLogProvider`)
      - Each item: Icon, title, timestamp, read/unread indicator
      - Swipe-to-delete action (Dismissible widget)
      - Tap → Navigate to relevant screen (deep link)
    - Empty state: Illustration + "No notifications yet" message
    - Pagination: Load more on scroll (infinite scroll pattern)
  - Apply theme: `context.colors.*`
  - Apply localization: `context.l10n.*`
  - Apply icons: `AppIcons.*`
  - Add route to `GoRouter`: `/notifications/center`
  - Update `NotificationHub` widget: Tap → Navigate to center screen
- **Verification**:
  - ✅ History loads correctly (pagination works)
  - ✅ Delete/archive actions functional (optimistic UI update)
  - ✅ Filter chips work (filter by type)
  - ✅ Empty state renders (when no notifications)
  - ✅ Theme switching works (light ↔ dark)
- **Code Prompt**:
  ```dart
  class NotificationCenterScreen extends ConsumerWidget {
    const NotificationCenterScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final historyAsync = ref.watch(notificationHistoryProvider(days: 30));
      final selectedFilter = ref.watch(notificationFilterProvider);

      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.notificationCenter),
          actions: [
            IconButton(
              icon: Icon(AppIcons.filter),
              onPressed: () => _showFilterSheet(context, ref),
            ),
          ],
        ),
        body: historyAsync.when(
          data: (logs) {
            if (logs.isEmpty) {
              return NotificationEmptyState();
            }

            final filtered = _filterLogs(logs, selectedFilter);
            return NotificationHistoryList(logs: filtered);
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      );
    }

    List<NotificationLog> _filterLogs(List<NotificationLog> logs, NotificationFilter filter) {
      if (filter == NotificationFilter.all) return logs;
      return logs.where((log) => log.type == filter.type).toList();
    }
  }
  ```

---

#### **Task 5.4: Smart Scheduling Engine Enhancement**
- **Category**: Implementation
- **Layer**: Domain + Presentation (service)
- **Files**:
  - `lib/features/notifications/domain/usecases/schedule_workout_reminders.dart` (UPDATE)
  - `lib/features/notifications/presentation/services/smart_notification_service.dart` (UPDATE)
- **Dependencies**: Tasks 4.1, 4.3
- **Est. Time**: 1.5h
- **Blocking**: NO
- **Description**:
  - Enhance scheduler with:
    - **Frequency capping**: Check `notificationLogProvider` before scheduling
      - If daily limit reached (e.g., 3/day), skip scheduling
      - If weekly limit reached (e.g., 10/week), skip scheduling
    - **Optimal time prediction**: Use `PredictOptimalTime` use case (from Task 4.1)
      - If user has consistent workout pattern (e.g., always 6 PM), suggest 5:30 PM
      - If user inconsistent, fallback to user-preferred time
    - **Quiet hour respect**: Check `QuietHours` from preferences
      - If scheduled time falls in quiet hours, reschedule to next available time
    - **Analytics events**: Log scheduling decisions
      - Event: `notification_scheduled` with reason (frequency_cap, optimal_time, quiet_hours)
  - Update `SmartNotificationService`:
    - Replace old scheduling logic with new enhanced logic
    - Add retry mechanism if scheduling fails (exponential backoff)
  - Ensure background scheduling works on iOS/Android (test with app in background)
- **Verification**:
  - ✅ Frequency caps enforced (tested with mock logs exceeding limit)
  - ✅ Quiet hours respected (tested with notification scheduled during quiet time)
  - ✅ Scheduling accuracy >95% (measured over 100 test schedules)
  - ✅ Background scheduling works (app in background, notification still fires)
- **Code Prompt**:
  ```dart
  class ScheduleWorkoutReminders {
    ScheduleWorkoutReminders({
      required CheckNotificationRules rulesEngine,
      required PredictOptimalTime predictor,
      required NotificationLogRepository logRepo,
    }) : _rulesEngine = rulesEngine,
         _predictor = predictor,
         _logRepo = logRepo;

    final CheckNotificationRules _rulesEngine;
    final PredictOptimalTime _predictor;
    final NotificationLogRepository _logRepo;

    Future<ScheduleResult> execute({
      required DateTime lastWorkoutDate,
      required DateTime? lastNotificationDate,
      required DateTime currentTime,
      required NotificationPreferences preferences,
      required List<DateTime> recentWorkoutTimes,
    }) async {
      // 1. Check rules (allow notification?)
      final decision = _rulesEngine.execute(
        lastWorkoutDate: lastWorkoutDate,
        lastNotificationDate: lastNotificationDate,
        currentDate: currentTime,
      );

      if (!decision.shouldNotify) {
        return ScheduleResult(
          shouldSchedule: false,
          scheduledTime: currentTime,
          reason: decision.reason,
        );
      }

      // 2. Check frequency cap
      final todayLogs = await _logRepo.getHistory(days: 1);
      if (todayLogs.length >= preferences.frequencyCap.maxPerDay) {
        return ScheduleResult(
          shouldSchedule: false,
          scheduledTime: currentTime,
          reason: 'Daily frequency cap reached (${preferences.frequencyCap.maxPerDay}/day)',
        );
      }

      // 3. Predict optimal time
      final predictedTime = _predictor.predict(
        recentWorkoutTimes: recentWorkoutTimes,
        preferredHour: preferences.preferredHour,
      );

      // 4. Check quiet hours
      DateTime scheduledTime = predictedTime;
      if (preferences.quietHours != null && preferences.quietHours!.isInQuietWindow(scheduledTime)) {
        // Reschedule to next available time (after quiet hours end)
        scheduledTime = preferences.quietHours!.nextAvailableTime(scheduledTime);
      }

      return ScheduleResult(
        shouldSchedule: true,
        scheduledTime: scheduledTime,
        reason: 'Scheduled at optimal time (predicted: ${predictedTime.hour}:${predictedTime.minute})',
      );
    }
  }
  ```

---

#### **Task 5.5: Privacy & Consent Flow**
- **Category**: Implementation
- **Layer**: Presentation
- **Files**:
  - `lib/features/notifications/presentation/widgets/notification_consent_dialog.dart` (NEW)
  - `lib/features/privacy/data/repositories/user_consent_repository.dart` (UPDATE - add notification consent)
- **Dependencies**: Tasks 1.3, 5.1
- **Est. Time**: 1h
- **Blocking**: NO
- **Description**:
  - Implement GDPR-compliant consent dialog:
    - Show on first app launch (after onboarding)
    - Content:
      - Title: "Notification Permissions"
      - Body: Explain what notifications will be sent (workout reminders, achievements)
      - Benefit: "Helps you stay consistent and motivated"
      - Data handling: "Notification preferences stored locally and synced to your account"
      - Control: "You can change this anytime in Settings"
    - Buttons: "Allow Notifications" (primary), "Not Now" (secondary)
    - Track consent in `UserConsentRepository` (existing privacy system)
  - Add audit logging for notification decisions:
    - Log: When notification scheduled, reason (from scheduling engine)
    - Log: When notification clicked/dismissed
    - Storage: `notificationLogProvider` (local only, auto-delete after 90 days)
  - Add data retention cleanup:
    - Background task: Delete logs older than 90 days
    - Run weekly (use `flutter_workmanager` or similar)
- **Verification**:
  - ✅ Consent dialog shown on first launch
  - ✅ Consent persisted in `UserConsentRepository`
  - ✅ Audit logs generated for scheduling decisions
  - ✅ Retention cleanup scheduled (verified in background)
  - ✅ GDPR compliance confirmed (can export/delete user data)
- **Code Prompt**:
  ```dart
  class NotificationConsentDialog extends ConsumerWidget {
    const NotificationConsentDialog({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      return AlertDialog(
        title: Text(context.l10n.notificationConsentTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.notificationConsentBody),
            const SizedBox(height: 16),
            _buildBenefitItem(context, AppIcons.trendingUp, context.l10n.notificationBenefit1),
            _buildBenefitItem(context, AppIcons.notifications, context.l10n.notificationBenefit2),
            const SizedBox(height: 16),
            Text(
              context.l10n.notificationDataHandling,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(userConsentRepositoryProvider).recordConsent(
                consentType: ConsentType.notifications,
                granted: false,
              );
              Navigator.of(context).pop();
            },
            child: Text(context.l10n.notNow),
          ),
          FilledButton(
            onPressed: () async {
              ref.read(userConsentRepositoryProvider).recordConsent(
                consentType: ConsentType.notifications,
                granted: true,
              );

              // Request system permission
              await ref.read(notificationPermissionProvider.notifier).requestPermission();

              Navigator.of(context).pop();
            },
            child: Text(context.l10n.allowNotifications),
          ),
        ],
      );
    }

    Widget _buildBenefitItem(BuildContext context, IconData icon, String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, color: context.colors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      );
    }
  }
  ```

---

### PHASE 5: TESTING (3 tasks, ~4.5h)

#### **Task 6.1: Domain & Data Layer Unit Tests**
- **Category**: Testing
- **Layer**: Domain + Data
- **Files**:
  - `test/features/notifications/domain/usecases/check_notification_rules_test.dart` (UPDATE)
  - `test/features/notifications/domain/usecases/predict_optimal_time_test.dart` (NEW)
  - `test/features/notifications/domain/entities/frequency_cap_test.dart` (NEW)
  - `test/features/notifications/data/repositories/notification_preference_repository_impl_test.dart` (NEW)
  - `test/features/notifications/data/repositories/notification_log_repository_impl_test.dart` (NEW)
- **Dependencies**: Tasks 4.1, 4.2
- **Est. Time**: 1.5h
- **Blocking**: NO (but required for quality)
- **Description**:
  - Write unit tests for rules engine:
    - Test: Frequency cap enforcement (daily/weekly limits)
    - Test: Quiet hours check (notification blocked during quiet time)
    - Test: Time window validation (per-category timing)
    - Test: Edge cases (timezone change, preference update mid-schedule)
  - Write unit tests for `PredictOptimalTime`:
    - Test: Consistent workout pattern → Predicts 30min before usual time
    - Test: Inconsistent pattern → Fallback to preferred time
    - Test: No workout history → Default to preferred time
  - Write unit tests for repositories:
    - Test: CRUD operations (with mocked datasources)
    - Test: Sync logic (local + remote merge, last-write-wins)
    - Test: Error handling (network failure, parsing error)
    - Test: Offline resilience (queue + retry)
  - Aim for 85%+ coverage on domain/data layers
- **Verification**:
  - ✅ All tests pass (green)
  - ✅ Coverage report generated (`flutter test --coverage`)
  - ✅ Coverage ≥85% on domain/data layers
  - ✅ Edge cases covered (5+ edge case tests)
- **Code Prompt**:
  ```dart
  void main() {
    group('CheckNotificationRules - Frequency Cap', () {
      late CheckNotificationRules rulesEngine;
      late MockNotificationLogRepository mockLogRepo;

      setUp(() {
        mockLogRepo = MockNotificationLogRepository();
        rulesEngine = CheckNotificationRules(logRepository: mockLogRepo);
      });

      test('should block notification when daily cap reached', () async {
        // Arrange
        final today = DateTime(2025, 11, 15, 18, 0);
        final logs = List.generate(3, (_) => NotificationLog(deliveredAt: today));
        when(() => mockLogRepo.getHistory(days: 1)).thenAnswer((_) async => logs);

        // Act
        final result = await rulesEngine.execute(
          lastWorkoutDate: DateTime(2025, 11, 13),
          lastNotificationDate: DateTime(2025, 11, 14),
          currentDate: today,
          frequencyCap: FrequencyCap(maxPerDay: 3, maxPerWeek: 10, minIntervalHours: 2),
        );

        // Assert
        expect(result.shouldNotify, false);
        expect(result.reason, contains('Daily frequency cap reached'));
      });
    });
  }
  ```

---

#### **Task 6.2: Presentation Layer Widget Tests**
- **Category**: Testing
- **Layer**: Presentation
- **Files**:
  - `test/features/notifications/presentation/screens/notification_settings_screen_test.dart` (NEW)
  - `test/features/notifications/presentation/screens/notification_center_screen_test.dart` (NEW)
  - `test/features/notifications/presentation/widgets/category_preference_card_test.dart` (NEW)
  - `test/features/notifications/presentation/widgets/quiet_hours_picker_test.dart` (NEW)
- **Dependencies**: Tasks 5.1, 5.2, 5.3
- **Est. Time**: 1.5h
- **Blocking**: NO (but required for quality)
- **Description**:
  - Test settings screen:
    - Test: Permission banner shown when permission denied
    - Test: Category toggles work (enable/disable updates state)
    - Test: Time window picker updates preference
    - Test: Quiet hours picker updates preference
    - Test: Test notification button triggers notification
  - Test notification center screen:
    - Test: History list renders (with mock logs)
    - Test: Filter chips work (filter by type)
    - Test: Empty state renders (when no logs)
    - Test: Delete action works (swipe-to-delete)
  - Test theme switching:
    - Test: All widgets render correctly in dark mode
    - Test: All widgets render correctly in light mode
  - Test localization rendering:
    - Test: English strings render correctly
    - Test: Italian strings render correctly
- **Verification**:
  - ✅ All widget tests pass (green)
  - ✅ Theme application verified (dark/light mode tests)
  - ✅ Localization keys render correctly (EN/IT)
  - ✅ User interactions tested (tap, swipe, toggle)
- **Code Prompt**:
  ```dart
  void main() {
    group('NotificationSettingsScreen Widget Tests', () {
      testWidgets('should show permission banner when permission denied', (tester) async {
        // Arrange
        final mockContainer = ProviderContainer(
          overrides: [
            notificationPermissionProvider.overrideWith((_) => AsyncValue.data(false)),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: mockContainer,
            child: MaterialApp(
              home: NotificationSettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Notification Permission Required'), findsOneWidget);
        expect(find.byType(PermissionBanner), findsOneWidget);
      });

      testWidgets('should toggle category preference when switch tapped', (tester) async {
        // Arrange
        final mockContainer = ProviderContainer(
          overrides: [
            notificationPreferenceProvider.overrideWith((_) => AsyncValue.data(
              NotificationPreferences(
                categories: {'workout': CategoryPreference(enabled: false)},
              ),
            )),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: mockContainer,
            child: MaterialApp(
              home: NotificationSettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final switchFinder = find.byType(Switch).first;
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        // Assert
        final notifier = mockContainer.read(notificationPreferenceProvider.notifier);
        verify(() => notifier.updateCategory('workout', CategoryPreference(enabled: true))).called(1);
      });
    });
  }
  ```

---

#### **Task 6.3: Integration & End-to-End Tests**
- **Category**: Testing
- **Layer**: Integration
- **Files**:
  - `test/integration/notification_flow_test.dart` (NEW)
  - `test/integration/notification_persistence_test.dart` (NEW)
  - `test/integration/notification_background_test.dart` (NEW)
- **Dependencies**: Tasks 5.4, 5.5
- **Est. Time**: 1.5h
- **Blocking**: NO (but required for quality)
- **Description**:
  - Test preference persistence across app restarts:
    - Scenario: User updates preference → Restart app → Verify preference persisted
    - Test: Local persistence (Hive)
    - Test: Remote sync (Firestore - use Firebase emulator)
  - Test notification delivery against scheduling rules:
    - Scenario: User has quiet hours 10 PM - 8 AM → Schedule notification at 11 PM → Verify rescheduled to 8 AM
    - Scenario: User has frequency cap 3/day → Send 3 notifications → Verify 4th blocked
    - Scenario: User has category time window "Achievements 6-8 PM" → Schedule achievement at 3 PM → Verify rescheduled to 6 PM
  - Test background delivery on both platforms:
    - iOS: Use XCTest to verify notification fires when app in background
    - Android: Use Espresso to verify notification fires when app in background
    - Note: May require manual testing if background automation complex
  - Verify no console errors in E2E flows
- **Verification**:
  - ✅ E2E flows pass on iOS (manual or automated)
  - ✅ E2E flows pass on Android (manual or automated)
  - ✅ Background delivery confirmed (app in background, notification fires)
  - ✅ No console errors (clean logs)
- **Code Prompt**:
  ```dart
  void main() {
    group('Notification Persistence Integration Test', () {
      late ProviderContainer container;

      setUp(() {
        // Use real repositories with in-memory/mock datasources
        container = ProviderContainer(
          overrides: [
            notificationPreferenceRepositoryProvider.overrideWith((_) =>
              NotificationPreferenceRepositoryImpl(
                localDatasource: InMemoryLocalDatasource(),
                remoteDatasource: MockRemoteDatasource(),
              ),
            ),
          ],
        );
      });

      tearDown(() {
        container.dispose();
      });

      test('should persist preference across container rebuild', () async {
        // Arrange
        final notifier = container.read(notificationPreferenceProvider.notifier);
        final newPreference = NotificationPreferences(
          categories: {'workout': CategoryPreference(enabled: true, timeWindow: TimeWindow(start: 18, end: 20))},
        );

        // Act - Update preference
        await notifier.update(newPreference);
        await Future.delayed(Duration(milliseconds: 100)); // Wait for persistence

        // Rebuild container (simulate app restart)
        final newContainer = ProviderContainer(
          overrides: [
            notificationPreferenceRepositoryProvider.overrideWith((_) =>
              NotificationPreferenceRepositoryImpl(
                localDatasource: InMemoryLocalDatasource(), // Same data source
                remoteDatasource: MockRemoteDatasource(),
              ),
            ),
          ],
        );

        // Assert - Verify preference persisted
        final loadedPreference = await newContainer.read(notificationPreferenceProvider.future);
        expect(loadedPreference.categories['workout']?.enabled, true);
        expect(loadedPreference.categories['workout']?.timeWindow?.start, 18);

        newContainer.dispose();
      });
    });
  }
  ```

---

### PHASE 6: DOCUMENTATION (2 tasks, ~1.75h)

#### **Task 7.1: Architecture & Code Documentation**
- **Category**: Documentation
- **Layer**: N/A
- **Files**:
  - `docs/NOTIFICATION_SYSTEM_DOCUMENTATION.md` (NEW)
  - `docs/architecture/notification_domain_model.md` (NEW)
  - `docs/architecture/notification_data_layer.md` (NEW)
  - `docs/architecture/notification_presentation_layer.md` (NEW)
  - `lib/features/notifications/README.md` (NEW)
- **Dependencies**: All implementation tasks (Tasks 4.1-5.5)
- **Est. Time**: 1h
- **Blocking**: NO
- **Description**:
  - Create comprehensive documentation:
    1. **NOTIFICATION_SYSTEM_DOCUMENTATION.md** (master document):
       - Overview: Purpose, key features
       - Architecture: Clean Architecture layers, Riverpod state management
       - UX flows: Onboarding → Settings → Notification center
       - Market research summary: Key findings from Task 1.1, 1.2
       - GDPR compliance: Consent flows, data retention, user control
       - Platform-specific: iOS Live Activities, Android notification channels
    2. **Domain model documentation**:
       - Entities: `NotificationRule`, `FrequencyCap`, `TimeWindow`, `QuietHours`
       - Use cases: `CheckNotificationRules`, `PredictOptimalTime`, `ScheduleWorkoutReminders`
       - Business rules: Frequency caps, quiet hours, time windows
    3. **Data layer documentation**:
       - Repositories: `NotificationPreferenceRepository`, `NotificationLogRepository`
       - Datasources: Local (Hive), Remote (Firestore)
       - Sync strategy: Last-write-wins, offline queue
    4. **Presentation layer documentation**:
       - Providers: `notificationPreferenceProvider`, `notificationLogProvider`, `notificationSchedulingProvider`
       - Screens: `NotificationSettingsScreen`, `NotificationCenterScreen`
       - Widgets: `CategoryPreferenceCard`, `QuietHoursPicker`, `NotificationHub`
  - Add code comments to complex logic:
    - `CheckNotificationRules.execute()`: Explain frequency cap logic
    - `PredictOptimalTime.predict()`: Explain prediction algorithm
    - `NotificationPreferenceRepositoryImpl.syncWithRemote()`: Explain conflict resolution
  - Create architecture diagrams (Mermaid):
    - Domain layer class diagram
    - Data flow diagram (user → UI → provider → repository → datasource)
    - Scheduling flow diagram (rules engine → scheduler → platform adapter)
- **Verification**:
  - ✅ README updated (feature overview, quick start)
  - ✅ Architecture diagrams included (Mermaid or PNG)
  - ✅ Code comments added to complex logic (3+ key methods)
  - ✅ Documentation linked from `docs/INDEX.md`
- **Code Prompt**: N/A (manual documentation)

---

#### **Task 7.2: User-Facing Documentation & Release Notes**
- **Category**: Documentation
- **Layer**: N/A
- **Files**:
  - `docs/user_guide/notification_preferences.md` (NEW)
  - `CHANGELOG.md` (UPDATE)
  - `lib/features/notifications/presentation/widgets/notification_help_dialog.dart` (NEW)
- **Dependencies**: Tasks 5.1, 5.2, 5.3
- **Est. Time**: 45min
- **Blocking**: NO
- **Description**:
  - Create user guide for notification preferences:
    - How to enable/disable notifications
    - How to set quiet hours
    - How to configure per-category timing
    - How to test notifications
    - How to view notification history
    - FAQ: "Why didn't I receive a notification?", "How do I stop notifications temporarily?"
  - Update CHANGELOG.md:
    ```markdown
    ## [1.1.0] - 2025-11-XX

    ### Added - Notification System Refactoring
    - ✨ Granular notification control (per-category timing)
    - ✨ Quiet hours support (do-not-disturb integration)
    - ✨ In-app notification center with history (last 30 days)
    - ✨ Smart scheduling with frequency capping (max 3/day, 10/week)
    - ✨ GDPR-compliant consent flows
    - ✨ Market research-driven UX improvements

    ### Improved
    - 📈 Notification timing optimization (based on user activity patterns)
    - 🎨 Redesigned settings screen with better UX
    - 🌍 Complete localization (EN/IT) for all notification strings
    - ♿ Improved accessibility (semantic labels, screen reader support)

    ### Fixed
    - 🐛 Notification not respecting user-preferred time
    - 🐛 Missing localization strings in settings
    - 🐛 Theme colors not applied correctly in dark mode
    ```
  - Create in-app help dialog:
    - Accessible from settings screen (help icon in AppBar)
    - Content: Brief explanations of each preference
    - Quick tips: "Set quiet hours to avoid night interruptions", "Test your settings with the test button"
- **Verification**:
  - ✅ Help text localized (EN/IT)
  - ✅ Release notes drafted (ready for changelog)
  - ✅ User guide complete (5+ sections)
  - ✅ Help dialog accessible from settings screen
- **Code Prompt**:
  ```dart
  class NotificationHelpDialog extends StatelessWidget {
    const NotificationHelpDialog({super.key});

    @override
    Widget build(BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(AppIcons.help, color: context.colors.primary),
            const SizedBox(width: 8),
            Text(context.l10n.notificationHelp),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpSection(
                context,
                title: context.l10n.notificationHelpCategoriesTitle,
                body: context.l10n.notificationHelpCategoriesBody,
                icon: AppIcons.category,
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                context,
                title: context.l10n.notificationHelpQuietHoursTitle,
                body: context.l10n.notificationHelpQuietHoursBody,
                icon: AppIcons.nightlight,
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                context,
                title: context.l10n.notificationHelpTestTitle,
                body: context.l10n.notificationHelpTestBody,
                icon: AppIcons.science,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.close),
          ),
        ],
      );
    }

    Widget _buildHelpSection(BuildContext context, {required String title, required String body, required IconData icon}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: context.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(body, style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
        ],
      );
    }
  }
  ```

---

## 📊 Implementation Order (Execution Strategy)

### **MUST DO FIRST** (Blocking Tasks - Sequential):

1. **PHASE 1: Research** (3.25h)
   - Task 1.1: Market Competitor Analysis (1.5h) → BLOCKS Tasks 1.2, 6.1
   - Task 1.2: User Retention & UX Research (1h) → BLOCKS Task 6.1
   - Task 1.3: Privacy & Compliance Audit (45min) → Informs Task 7.1

2. **PHASE 2: Analysis** (4.25h)
   - Task 2.1: Current System Strengths (1h) → Informs design decisions
   - Task 2.2: Current System Weaknesses (1h) → BLOCKS all design tasks
   - Task 2.3: UX Flow Gap Analysis (1.5h) → BLOCKS Tasks 3.2, 3.3
   - Task 2.4: Localization & Theme Audit (45min) → Informs Task 5.2

**Total Critical Path (Research + Analysis)**: ~7.5h

---

### **THEN** (Design Phase - Mostly Sequential):

3. **PHASE 3: Design** (6.5h)
   - Task 3.1: Notification Rules Engine Redesign (1.5h) → BLOCKS Task 4.1
   - Task 3.2: User Preference Model Enhancement (1h) → BLOCKS Task 4.2
   - Task 3.3: Presentation Layer UX Redesign (1.5h) → BLOCKS Tasks 5.1, 5.2, 5.3
   - Task 3.4: Live Activities Integration Plan (1h) → iOS-only, not critical path
   - Task 3.5: Data Layer & Persistence Strategy (1h) → BLOCKS Task 4.3

**Total Critical Path (Design)**: ~6.5h

---

### **THEN** (Implementation Phase - Parallelizable After Domain):

4. **PHASE 4: Implementation** (10.5h)
   - **Step 1 - Domain Layer** (MUST DO FIRST):
     - Task 4.1: Domain Layer Refactoring (1.5h) → BLOCKS Tasks 4.3, 5.4

   - **Step 2 - Data Layer** (After 4.1):
     - Task 4.2: Data Layer Repository Implementation (1.5h) → BLOCKS Task 4.3

   - **Step 3 - Providers** (After 4.1 + 4.2):
     - Task 4.3: Riverpod Provider Architecture (1.5h) → BLOCKS Tasks 5.1, 5.2

   - **Step 4 - UI Implementation** (Partially Parallelizable):
     - Task 5.1: Notification Settings UI (2h) → Can start after 4.3
     - Task 5.2: Localization String Addition (30min) → Can run parallel with 5.1 (same developer adds strings while coding)
     - Task 5.3: Notification Center & History (1.5h) → Can run parallel with 5.1 (different screens)

   - **Step 5 - Advanced Features** (After 4.3):
     - Task 5.4: Smart Scheduling Engine Enhancement (1.5h) → Requires 4.1, 4.3
     - Task 5.5: Privacy & Consent Flow (1h) → Can run parallel with 5.1-5.3

**Total Critical Path (Implementation)**: ~10.5h

---

### **FINALLY** (Testing & Documentation - After Implementation):

5. **PHASE 5: Testing** (4.5h)
   - Task 6.1: Domain & Data Layer Unit Tests (1.5h) → Can start after 4.1, 4.2
   - Task 6.2: Presentation Layer Widget Tests (1.5h) → Can start after 5.1, 5.2, 5.3
   - Task 6.3: Integration & E2E Tests (1.5h) → Requires 5.4, 5.5

6. **PHASE 6: Documentation** (1.75h)
   - Task 7.1: Architecture & Code Documentation (1h) → After all implementation
   - Task 7.2: User-Facing Documentation & Release Notes (45min) → After 5.1, 5.2, 5.3

**Total Critical Path (Testing + Documentation)**: ~6.25h

---

## 🎯 Total Critical Path Time Estimate

**Sequential (no parallelization)**: ~30.75h

**Optimized (with parallelization)**:
- Research + Analysis: 7.5h (sequential)
- Design: 6.5h (mostly sequential)
- Implementation: ~8h (with parallelization: 5.1/5.2/5.3 run together, 5.4/5.5 run together)
- Testing: ~3h (6.1/6.2 run parallel after respective impl tasks, 6.3 sequential)
- Documentation: 1.75h (7.1/7.2 can run parallel)

**Total Optimized**: ~26-27h

---

## 📝 Notes & Decisions (To Be Filled During Execution)

### **Design Decisions**:
- TBD: Frequency cap values (currently 3/day, 10/week - adjust based on market research)
- TBD: Quiet hours default (currently none - should we suggest 10 PM - 8 AM?)
- TBD: iOS Live Activities priority (Optional in v1, add in v2 if high demand)

### **Technical Decisions**:
- TBD: Use Hive or Drift for local persistence? (Currently Hive - evaluate performance)
- TBD: Firestore real-time sync or batch sync? (Currently batch - evaluate UX impact)
- TBD: Background scheduling library (flutter_local_notifications vs. platform-specific)

### **UX Decisions**:
- TBD: Onboarding flow placement (after signup? after first workout?)
- TBD: Test notification content ("This is a test notification" vs. realistic example?)
- TBD: Notification center max history (currently 30 days - user feedback may adjust)

---

## 🔗 Cross-Task Dependencies Summary

**Blocking Chain** (Critical Path):
```
1.1 (Market Research) → 1.2 (Retention Research) → 2.3 (Gap Analysis) → 3.3 (UX Redesign) → 5.1/5.2/5.3 (UI Implementation)
2.2 (Weaknesses) → 3.1 (Rules Redesign) → 4.1 (Domain Refactor) → 4.3 (Providers) → 5.4 (Scheduling)
3.2 (Preference Model) → 4.2 (Data Repos) → 4.3 (Providers)
3.5 (Data Strategy) → 4.2 (Data Repos)
```

**Parallel Opportunities**:
- Tasks 2.1, 2.4, 1.3 (no dependencies, run parallel)
- Tasks 5.1, 5.2, 5.3 (after 4.3, run parallel)
- Tasks 5.4, 5.5 (after 4.3, run parallel)
- Tasks 6.1, 6.2 (after respective impl, run parallel)
- Tasks 7.1, 7.2 (after all impl, run parallel)

---

## ✅ FitLog Pro Compliance Checklist

- [ ] ✅ **Icon Design System**: All icons use `AppIcons.*` (no `Icons.*` inline)
- [ ] ✅ **Icon Sizing**: All icon sizes use `AppIconSize.*` constants (no magic numbers)
- [ ] ✅ **Icon Colors**: All icon colors use `context.icon*` helpers (no hardcoded colors)
- [ ] ✅ **Semantic Icons**: All interactive icons use `SemanticIcon` for accessibility
- [ ] ✅ **Localization**: All strings use `context.l10n.*` (no hardcoded text)
- [ ] ✅ **Theme**: All colors use `context.colors.*` (no hardcoded Colors.*)
- [ ] ✅ **Flutter Analyze**: `flutter analyze` passes with 0 errors before commit
- [ ] ✅ **Tests**: Unit tests (domain/data), widget tests (presentation), integration tests
- [ ] ✅ **Dark/Light Theme**: All UI tested in both themes
- [ ] ✅ **Platforms**: iOS AND Android tested (if platform-specific features)
- [ ] ✅ **iOS Build Compliance**: No `const` with `context.l10n`, proper BuildContext params
- [ ] ✅ **Import Disambiguation**: `hide Either, Right, Left` if using fpdart
- [ ] ✅ **Documentation**: Updated INDEX.md, CLAUDE.md, feature docs

---

## 📈 Success Metrics (Post-Implementation)

**User Engagement**:
- Notification click-through rate >20% (industry average: 10-15%)
- Notification dismissal rate <30% (lower = more relevant)
- User retention improvement +15-20% (P3 target)

**Technical Quality**:
- Test coverage ≥85% (domain/data layers)
- `flutter analyze` 0 errors (enforced by pre-commit)
- Localization compliance 100% (no hardcoded strings)
- Theme compliance 100% (no hardcoded colors)

**UX Satisfaction**:
- Settings screen usability score >4.5/5 (user testing)
- Notification timing satisfaction >80% (survey)
- Zero GDPR compliance violations (audit clean)

---

**Plan Status**: 🟢 Ready for Execution
**Last Updated**: 2025-11-15 (v1.0)
**Next Review**: After Task 2.3 completion (UX Gap Analysis)

---

