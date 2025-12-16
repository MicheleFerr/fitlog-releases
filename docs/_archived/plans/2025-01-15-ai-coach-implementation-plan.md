# AI Coach Refactoring - Implementation Plan

**Generated**: 2025-01-15 17:15
**Source**: task-master.dev (WebFetch) + Design Documents Integration
**Complexity Score**: HIGH
**Reason**: Major architectural refactoring + New features + 25 tasks
**Total Tasks**: 25
**Estimated Time**: ~18-20 hours (4 weeks)
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: 3.16.0
- Key Packages: riverpod ^2.4.9, firebase_core ^2.24.2, fl_chart ^0.66.0
- Target Platforms: iOS 14+, Android 8+
- Related Design Docs:
  - `2025-01-15-ai-coach-refactoring-design.md` (Architecture)
  - `2025-01-15-ai-coach-retention-strategy.md` (Retention & UX)

---

## 📋 Original Request

> Analizza approfonditamente l'AI Coach voglio fare un refactoring ed ottimizzazioni
>
> Obiettivi chiave:
> - Qualità insights (ridurre falsi positivi 40% → <10%)
> - Architettura modulare (Strategy Pattern, plugin architecture)
> - UX/UI migliorate (visualizzazioni, gamification, onboarding)
> - Estensibilità (nuovi analyzer: Mobility, CNS Fatigue, Periodization)
> - Retention (onboarding, notifiche smart, streak tracking)

---

## 🎯 Task Breakdown

### PHASE 1: Domain Layer Foundation (Week 1, Days 1-2)

#### Task 1.1: Core Domain Entities with Freezed
- **Layer**: Domain
- **Files**:
  - `lib/features/ai_coach/domain/entities/ai_insight.dart`
  - `lib/features/ai_coach/domain/entities/user_context.dart`
  - `lib/features/ai_coach/domain/entities/insight_rule.dart`
- **Dependencies**: None (BLOCKING - must complete first)
- **Est. Time**: 45 min
- **Blocking**: Yes (blocks all subsequent tasks)
- **Verification**:
  - Unit tests for entity equality
  - Freezed code generation successful
  - `flutter analyze` passes (0 errors)
- **Code Prompt**:
  ```dart
  // Create freezed entities with json_serializable
  //
  // AIInsight fields: id, type (enum), severity, title, description,
  //   recommendation, priority, affectedExercise, affectedTemplates,
  //   scientificStrategies, dataPoints, timestamp
  //
  // UserContext fields: userId, experienceLevel (enum), primaryGoal (enum),
  //   weeklyAvailability, injuryHistory, preferredExercises
  //
  // InsightRule fields: insightType, minWeeks, volumeThreshold,
  //   personalizedThresholds (Map<ExperienceLevel, double>)
  ```
- **Localization**: None (domain layer)

---

#### Task 1.2: Analyzer Strategy Interface
- **Layer**: Domain
- **Files**: `lib/features/ai_coach/domain/repositories/insight_analyzer.dart`
- **Dependencies**: Task 1.1
- **Est. Time**: 20 min
- **Blocking**: Yes (blocks all analyzer implementations)
- **Verification**:
  - Interface compiles
  - Documentation complete (dartdoc)
  - Abstract methods defined
- **Code Prompt**:
  ```dart
  // Define abstract InsightAnalyzer interface
  //
  // Methods:
  // - Future<AIInsight?> analyze(List<Workout> workouts, UserContext context)
  // - InsightType get type
  // - int get basePriority
  // - bool shouldAnalyze(UserContext context) // Feature gating
  ```

---

#### Task 1.3: Analyzer Registry & Factory
- **Layer**: Domain
- **Files**: `lib/features/ai_coach/domain/repositories/analyzer_registry.dart`
- **Dependencies**: Task 1.2
- **Est. Time**: 30 min
- **Blocking**: No (but recommended before analyzer implementations)
- **Verification**:
  - Unit tests for registration/retrieval
  - Error handling for unregistered types
  - Factory pattern working
- **Code Prompt**:
  ```dart
  // Create registry pattern for dynamic analyzer loading
  //
  // Features:
  // - registerAnalyzer(InsightAnalyzer analyzer)
  // - getAnalyzer(InsightType type) → InsightAnalyzer
  // - getAllEnabledAnalyzers(UserContext context) → List<InsightAnalyzer>
  //   (respects feature gating for free vs. premium)
  ```

---

### PHASE 2: Data Layer - Concrete Analyzers (Week 1, Days 3-7)

#### Task 2.1: Volume Balance Analyzer
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/analyzers/volume_balance_analyzer.dart`
- **Dependencies**: Tasks 1.2, 1.3
- **Est. Time**: 50 min
- **Blocking**: No (parallel with other analyzers)
- **Verification**:
  - Unit tests with mock workout data
  - Threshold personalization working (beginner vs. advanced)
  - Returns typed `AIInsight` objects
- **Code Prompt**:
  ```dart
  // Extract logic from old ai_coach_service.dart _analyzeVolumeByMuscleGroup
  //
  // Apply context-aware thresholds:
  // - Beginner: MEV=8, MAV=15, MRV=20
  // - Intermediate: MEV=10, MAV=18, MRV=25
  // - Advanced: MEV=12, MAV=20, MRV=30
  //
  // Return AIInsight with:
  // - type: InsightType.muscleGroupBalance
  // - severity: critical if >MRV or <MEV
  // - recommendation: "Add X sets of Y exercise"
  // - dataPoints: Map of muscle group volumes
  ```
- **Localization**:
  - `context.l10n.volumeBalanceTitle`
  - `context.l10n.volumeBalanceDescription`
  - `context.l10n.volumeBalanceRecommendation`

---

#### Task 2.2: Progressive Overload Analyzer
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/analyzers/progressive_overload_analyzer.dart`
- **Dependencies**: Tasks 1.2, 1.3
- **Est. Time**: 45 min
- **Blocking**: No
- **Verification**: Unit tests for weight progression detection
- **Localization**: `context.l10n.progressiveOverload*`

---

#### Task 2.3: Recovery Pattern Analyzer
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/analyzers/recovery_pattern_analyzer.dart`
- **Dependencies**: Tasks 1.2, 1.3
- **Est. Time**: 40 min
- **Blocking**: No
- **Localization**: `context.l10n.recoveryPattern*`

---

#### Task 2.4: CNS Fatigue Analyzer (NEW - Blind Spot Fix)
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/analyzers/cns_fatigue_analyzer.dart`
- **Dependencies**: Tasks 1.2, 1.3
- **Est. Time**: 40 min
- **Blocking**: No
- **Verification**:
  - Tracks heavy compound lifts (squat, deadlift, bench >85% 1RM)
  - Calculates fatigue index (0-10 scale)
  - Recommends deload when index >7
- **Code Prompt**:
  ```dart
  // CNS Fatigue = f(heavy sets, compound lifts, frequency)
  //
  // Formula:
  // fatigueIndex = (heavySets * 1.5 + compoundSets * 1.2) / weeklyWorkouts
  //
  // Thresholds:
  // - <4: Fresh (no action)
  // - 4-6: Moderate (monitor)
  // - 7-8: High (deload recommended)
  // - >8: Critical (mandatory rest)
  ```
- **Localization**: `context.l10n.cnsFatigue*`

---

#### Task 2.5: Periodization Analyzer (NEW - Blind Spot Fix)
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/analyzers/periodization_analyzer.dart`
- **Dependencies**: Tasks 1.2, 1.3
- **Est. Time**: 40 min
- **Blocking**: No
- **Verification**:
  - Detects phase (hypertrophy, strength, deload)
  - Recommends phase change based on volume/intensity trends
- **Code Prompt**:
  ```dart
  // Detect training phase from volume + intensity patterns
  //
  // Hypertrophy: 8-12 reps, 60-90s rest, moderate weight
  // Strength: 1-5 reps, 3-5min rest, heavy weight (>85% 1RM)
  // Deload: -40% volume, light weight
  //
  // Recommend phase change:
  // - After 4-6 weeks in same phase
  // - If plateau detected
  // - If CNS fatigue high
  ```
- **Localization**: `context.l10n.periodization*`

---

#### Task 2.6: Mobility Analyzer (NEW - Blind Spot Fix)
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/analyzers/mobility_analyzer.dart`
- **Dependencies**: Tasks 1.2, 1.3
- **Est. Time**: 40 min
- **Blocking**: No
- **Verification**:
  - Detects ROM limitations from exercise replacements
  - Recommends mobility work
- **Code Prompt**:
  ```dart
  // Track if user consistently replaces exercises
  // Example: Always replaces "Squat" with "Leg Press"
  //   → Suggests mobility issue in ankles/hips
  //
  // Recommendation: "Add ankle mobility drills before leg day"
  ```
- **Localization**: `context.l10n.mobility*`

---

#### Task 2.7: Insight Rule Engine
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/repositories/insight_rule_repository.dart`
- **Dependencies**: Task 1.1
- **Est. Time**: 50 min
- **Blocking**: No (but recommended for Tasks 2.1-2.6)
- **Verification**:
  - Unit tests for rule evaluation
  - Cache strategy working (Hive local storage)
  - Threshold adjustment working
- **Code Prompt**:
  ```dart
  // Repository for managing dynamic insight rules
  //
  // Features:
  // - fetchRules(InsightType type) → InsightRule
  // - updateThreshold(InsightType, param, value) → void
  // - getPersonalizedThreshold(InsightType, UserContext) → double
  //
  // Storage: Hive (local) + Firestore (sync for analytics)
  ```

---

### PHASE 3: Presentation Layer - Refactored UI (Week 2)

#### Task 3.1: AI Insight State Management (Riverpod)
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/providers/ai_insights_provider.dart`
- **Dependencies**: Tasks 1.3, 2.7
- **Est. Time**: 40 min
- **Blocking**: Yes (blocks all UI tasks)
- **Verification**:
  - Provider unit tests
  - Loads insights from registry
  - Filters work (by severity, type)
- **Code Prompt**:
  ```dart
  // Create Riverpod providers
  //
  // aiInsightsProvider = FutureProvider.autoDispose<List<AIInsight>>((ref) {
  //   final registry = ref.watch(analyzerRegistryProvider);
  //   final userContext = ref.watch(userContextProvider);
  //   final workouts = await ref.watch(workoutRepositoryProvider).getWorkouts();
  //
  //   final insights = <AIInsight>[];
  //   for (final analyzer in registry.getAllEnabledAnalyzers(userContext)) {
  //     final insight = await analyzer.analyze(workouts, userContext);
  //     if (insight != null) insights.add(insight);
  //   }
  //
  //   insights.sort((a, b) => a.priority.compareTo(b.priority));
  //   return insights.take(5).toList(); // Top 5 insights
  // });
  ```

---

#### Task 3.2: Insight Severity Visual Indicator
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/insight_severity_indicator.dart`
- **Dependencies**: Task 1.1
- **Est. Time**: 35 min
- **Blocking**: No
- **Verification**:
  - Widget tests for color coding
  - Pulsing animation working for critical
  - Theme compliance (context.colors.*)
- **Code Prompt**:
  ```dart
  // Visual severity system
  //
  // Severity.low: Blue badge (context.colors.info)
  // Severity.medium: Yellow badge (context.colors.warning)
  // Severity.high: Orange badge (context.colors.warning)
  // Severity.critical: Red pulsing badge (context.colors.error + animation)
  //
  // Use AnimatedIconPatterns.pulsing() for critical
  ```
- **Localization**: Severity level labels

---

#### Task 3.3: Progressive Disclosure Widget
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/insight_expansion_widget.dart`
- **Dependencies**: Task 3.2
- **Est. Time**: 40 min
- **Blocking**: No
- **Verification**:
  - Widget tests for expand/collapse
  - 3-tier expansion working
  - Accessibility (semantic labels)
- **Code Prompt**:
  ```dart
  // 3-tier progressive disclosure
  //
  // LAYER 1 (always visible - glance):
  // - Severity badge
  // - Title
  // - 1-line summary
  //
  // LAYER 2 (tap to expand - details):
  // - Full description
  // - "Why this matters" explanation
  // - Data chart (if available)
  //
  // LAYER 3 (sub-expand - deep dive):
  // - Scientific strategies
  // - Action button: "Fix This"
  // - Feedback (thumbs up/down)
  ```

---

#### Task 3.4: Chart Integration (fl_chart)
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/insight_trend_chart.dart`
- **Dependencies**: Task 1.1, fl_chart package
- **Est. Time**: 50 min
- **Blocking**: No
- **Verification**:
  - Widget tests with mock data
  - Line charts rendering
  - Touch interaction working
- **Code Prompt**:
  ```dart
  // Use fl_chart for trend visualization
  //
  // Charts:
  // - Volume trend (7-day / 30-day toggle)
  // - Progressive overload (weight over time)
  // - Recovery pattern (days between workouts)
  //
  // Features:
  // - Touch to see exact values
  // - Theme-aware colors (context.colors.primary for line)
  // - Responsive to screen size
  ```
- **Localization**: Axis labels, date formatting

---

#### Task 3.5: Refactored AI Coach Card
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/ai_coach_card.dart`
- **Dependencies**: Tasks 3.1, 3.2, 3.3, 3.4
- **Est. Time**: 60 min
- **Blocking**: No
- **Verification**:
  - Widget tests
  - Comparison with original behavior (backward compatible)
  - Performance (no jank, <16ms frame time)
- **Code Prompt**:
  ```dart
  // Decompose 2382-line monolithic widget
  //
  // Replace with composition:
  // - AICoachCard (container)
  //   - InsightSeverityIndicator (Task 3.2)
  //   - InsightExpansionWidget (Task 3.3)
  //     - InsightTrendChart (Task 3.4)
  //   - FeedbackButtons
  //
  // Maintain:
  // - Gradient card design
  // - Animations (Lottie)
  // - Existing feedback system
  ```

---

### PHASE 4: Retention & Engagement Features (Week 3)

#### Task 4.1: Onboarding Flow (4 Steps)
- **Layer**: Presentation
- **Files**:
  - `lib/features/ai_coach/presentation/screens/onboarding/onboarding_experience_screen.dart`
  - `lib/features/ai_coach/presentation/screens/onboarding/onboarding_goal_screen.dart`
  - `lib/features/ai_coach/presentation/screens/onboarding/onboarding_quick_win_screen.dart`
  - `lib/features/ai_coach/presentation/screens/onboarding/onboarding_notifications_screen.dart`
- **Dependencies**: Task 3.1
- **Est. Time**: 50 min
- **Blocking**: No
- **Verification**:
  - Widget tests for each step
  - Flow progression working
  - Data persisted to UserContext
- **Code Prompt**:
  ```dart
  // 4-step onboarding sequence
  //
  // Step 1: Experience level (Beginner/Intermediate/Advanced)
  // Step 2: Primary goal (Hypertrophy/Strength/Endurance)
  // Step 3: Quick Win (analyze existing data, show 1 insight)
  //   - Show celebration animation if data found
  //   - Show "Start training" CTA if no data
  // Step 4: Notification permission request
  //   - Preview notification based on experience level
  //   - Smart ask (after showing value)
  ```
- **Localization**: All onboarding text (`context.l10n.onboarding*`)

---

#### Task 4.2: Smart Notification System
- **Layer**: Presentation
- **Files**:
  - `lib/features/ai_coach/presentation/providers/smart_notifications_provider.dart`
  - `lib/features/ai_coach/data/repositories/notification_timing_analyzer.dart`
- **Dependencies**: Tasks 3.1, 4.1
- **Est. Time**: 50 min
- **Blocking**: No
- **Verification**:
  - Integration test with mock notifications
  - Behavioral timing working (predicts optimal times)
  - Frequency control working (max per week)
- **Code Prompt**:
  ```dart
  // Behavioral notification timing
  //
  // Features:
  // 1. Analyze user app open history (last 30 days)
  // 2. Predict top 3 optimal times (6-7am, 11am, 7pm defaults)
  // 3. Respect user preferences:
  //    - Frequency (2-4 per week based on experience)
  //    - Do Not Disturb periods
  //    - Enabled insight types
  // 4. Track dismissal rate (if >70% for type, stop sending)
  //
  // Content personalization:
  // - Beginner: Motivational ("🔥 2 workouts left this week!")
  // - Advanced: Technical ("CNS fatigue: 7/10. Deload recommended")
  ```
- **Localization**: Notification text templates

---

#### Task 4.3: Gamification - Streak Tracker
- **Layer**: Domain + Presentation
- **Files**:
  - `lib/features/ai_coach/domain/entities/streak_data.dart` (freezed)
  - `lib/features/ai_coach/data/repositories/streak_repository.dart`
  - `lib/features/ai_coach/presentation/widgets/streak_display.dart`
- **Dependencies**: Task 1.1
- **Est. Time**: 40 min
- **Blocking**: No
- **Verification**:
  - Unit tests for streak calculation
  - Widget tests for UI
  - Milestone celebrations working (7, 14, 30 days)
- **Code Prompt**:
  ```dart
  // Streak tracking system
  //
  // Rules:
  // - Consecutive days training = streak
  // - Grace period: 1 rest day allowed (doesn't break streak)
  // - >2 days gap = streak resets to 1
  //
  // Milestones: 3, 7, 14, 21, 30, 50, 100, 365 days
  // Rewards:
  // - 7 days: "Week Warrior" badge
  // - 30 days: 25% discount on Premium
  // - 100 days: Free 1 month Premium
  //
  // Celebration:
  // - Lottie animation
  // - Push notification
  // - Badge unlock
  ```

---

#### Task 4.4: Achievement System
- **Layer**: Domain + Presentation
- **Files**:
  - `lib/features/ai_coach/domain/entities/achievement.dart` (freezed)
  - `lib/features/ai_coach/data/repositories/achievement_repository.dart`
  - `lib/features/ai_coach/presentation/widgets/achievement_showcase.dart`
- **Dependencies**: Task 1.1
- **Est. Time**: 45 min
- **Blocking**: No
- **Verification**:
  - Achievements unlock correctly
  - UI showcase working
- **Code Prompt**:
  ```dart
  // Achievement system
  //
  // Achievements:
  // - "Volume Wizard": Completed 5 volume optimization insights
  // - "Plateau Breaker": Overcame 3 plateaus
  // - "Form Master": 10 sessions with perfect form
  // - "Recovery Coach": Followed 5 deload recommendations
  // - "PR Hunter": Set 20 personal records
  //
  // Rewards: Badge + XP
  ```

---

#### Task 4.5: Advanced Feedback Loop
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/repositories/insight_feedback_repository.dart`
- **Dependencies**: Task 1.1
- **Est. Time**: 45 min
- **Blocking**: No
- **Verification**:
  - Unit tests for feedback persistence
  - Threshold adjustment working
  - Cohort analysis data collected
- **Code Prompt**:
  ```dart
  // Multi-dimensional feedback system
  //
  // Instead of thumbs up/down, collect:
  // - Accuracy: "Was this analysis correct?" (1-5)
  // - Actionability: "Could you act on this?" (1-5)
  // - Timing: "Right time to show this?" (1-5)
  // - Value: "Did this help your training?" (1-5)
  // - Comment: Optional text feedback
  //
  // Automatic threshold adjustment:
  // - If avg accuracy < 60% (3.0/5): Increase thresholds
  // - If actionability < 50%: Add more specific recommendations
  //
  // Cohort analysis:
  // - Segment feedback by experience level
  // - Identify which insights work better for which cohorts
  ```

---

#### Task 4.6: Feature Gating Service (Free vs. Premium)
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/repositories/feature_gate_repository.dart`
- **Dependencies**: Task 1.1
- **Est. Time**: 35 min
- **Blocking**: No
- **Verification**:
  - Unit tests for tier validation
  - Paywall triggers working
- **Code Prompt**:
  ```dart
  // Feature gating for monetization
  //
  // Free tier:
  // - Basic analyzers (volume, progressive overload, recovery)
  // - 3 insights per week
  // - Basic charts (last 30 days)
  //
  // Premium tier ($3.99/mo):
  // - All basic features
  // - Unlimited insights
  // - Advanced charts (all-time data)
  // - Smart notifications
  //
  // Pro tier ($9.99/mo):
  // - All premium features
  // - Advanced analyzers (CNS fatigue, periodization, mobility)
  // - Team features (group coaching)
  // - Priority support
  //
  // Paywall triggers:
  // - After 2 weeks of usage
  // - After 3rd insight in a week
  // - When accessing advanced charts
  ```

---

### PHASE 5: Testing & Quality (Week 3-4)

#### Task 5.1: Unit Tests - Analyzers
- **Layer**: Testing
- **Files**: `test/features/ai_coach/data/analyzers/`
- **Dependencies**: Tasks 2.1-2.6
- **Est. Time**: 60 min
- **Blocking**: No
- **Verification**:
  - 85%+ coverage
  - All tests pass
  - Mock data covers edge cases
- **Test Cases**:
  ```dart
  // For each analyzer:
  // 1. Test with empty workout data → returns null
  // 2. Test with insufficient data → returns null
  // 3. Test with optimal data → returns null (no insight needed)
  // 4. Test with imbalance → returns AIInsight
  // 5. Test personalization (beginner vs. advanced thresholds)
  ```

---

#### Task 5.2: Widget Tests - UI Components
- **Layer**: Testing
- **Files**: `test/features/ai_coach/presentation/widgets/`
- **Dependencies**: Tasks 3.2-3.5
- **Est. Time**: 50 min
- **Blocking**: No
- **Verification**:
  - All widgets tested
  - Golden files captured
  - Interaction flows verified
- **Test Cases**:
  ```dart
  // Test InsightSeverityIndicator:
  // - Renders correct color per severity
  // - Pulsing animation for critical
  //
  // Test InsightExpansionWidget:
  // - Expands on tap
  // - Shows all 3 layers
  // - Collapses on second tap
  //
  // Test InsightTrendChart:
  // - Renders with mock data
  // - Touch interaction works
  ```

---

#### Task 5.3: Integration Tests - E2E Flow
- **Layer**: Testing
- **Files**: `integration_test/ai_coach_e2e_test.dart`
- **Dependencies**: Tasks 5.1, 5.2
- **Est. Time**: 50 min
- **Blocking**: No
- **Verification**:
  - Full flow passes on iOS/Android emulators
  - Onboarding → Insight generation → Feedback → Notification
- **Test Scenario**:
  ```dart
  // 1. Complete onboarding (all 4 steps)
  // 2. Generate insights (mock workout data)
  // 3. Expand insight, view chart
  // 4. Provide feedback (thumbs up)
  // 5. Receive notification (mock timing)
  // 6. Track streak (mock consecutive workouts)
  ```

---

### PHASE 6: Localization & Documentation (Week 4)

#### Task 6.1: Localization Setup (EN + IT)
- **Layer**: Localization
- **Files**: `lib/l10n/app_en.arb`, `app_it.arb`
- **Dependencies**: Tasks 2.1-2.6, 4.1, 4.2
- **Est. Time**: 40 min
- **Blocking**: No (but recommended before release)
- **Verification**:
  - `flutter gen-l10n` generates without warnings
  - All new strings added
  - Italian translations reviewed
- **Strings to Add**:
  ```arb
  // Analyzers
  "volumeBalanceTitle": "Volume Balance",
  "cnsFatigueTitle": "CNS Fatigue Detected",
  "periodizationTitle": "Phase Change Recommended",
  "mobilityTitle": "Mobility Limitation",

  // Onboarding
  "onboardingExperienceTitle": "How long have you been training?",
  "beginnerLevel": "Beginner (0-1 year)",
  ...

  // Notifications
  "notificationVolumeImbalance": "Volume gap detected: {muscle}",
  "notificationCNSFatigue": "CNS fatigue: {score}/10. Deload recommended",
  ...
  ```

---

#### Task 6.2: Architecture Documentation
- **Layer**: Documentation
- **Files**: `docs/AI_COACH_ARCHITECTURE.md`
- **Dependencies**: All architecture tasks
- **Est. Time**: 30 min
- **Blocking**: No
- **Verification**:
  - Diagrams render (Mermaid)
  - All classes documented
  - Plugin extension guide complete
- **Contents**:
  ```markdown
  # AI Coach Architecture

  ## Strategy Pattern Rationale

  ## Analyzer Registry Flow

  ## Data Flow Diagram
  UserContext → Analyzer → AIInsight → Provider → UI

  ## Plugin Extension Guide
  How to add new analyzer:
  1. Implement InsightAnalyzer interface
  2. Register in AnalyzerRegistry
  3. Add localization strings
  4. Write unit tests
  ```

---

#### Task 6.3: Migration Guide & Release Notes
- **Layer**: Documentation
- **Files**: `docs/AI_COACH_MIGRATION_GUIDE.md`, `CHANGELOG.md`
- **Dependencies**: All tasks
- **Est. Time**: 25 min
- **Blocking**: No
- **Verification**:
  - Breaking changes documented
  - Migration steps clear
- **Contents**:
  ```markdown
  # Migration Guide

  ## Backward Compatibility
  - Old AICoachService still works (deprecated)
  - New AnalyzerRegistry is opt-in
  - User data migration automatic

  ## Breaking Changes
  - None (fully backward compatible)

  ## New Features
  - 3 new analyzers: CNS Fatigue, Periodization, Mobility
  - Onboarding flow (skip if already onboarded)
  - Smart notifications (opt-in)
  - Gamification (streaks, achievements)
  ```

---

## 📊 Implementation Order

### Week 1: Foundation + Analyzers
**MUST DO FIRST** (blocking):
- Task 1.1, 1.2, 1.3 → Domain foundation (~95 min)

**THEN** (parallel workable):
- Task 2.1-2.6 → Analyzers (~265 min = 4.4 hours)
- Task 2.7 → Rule engine (50 min)

**Total Week 1**: ~5.5 hours

---

### Week 2: UI Refactor
**MUST DO FIRST**:
- Task 3.1 → Riverpod providers (40 min)

**THEN** (parallel):
- Task 3.2-3.4 → UI components (~125 min = 2.1 hours)

**FINALLY**:
- Task 3.5 → Refactored card (60 min)

**Total Week 2**: ~3.7 hours

---

### Week 3: Retention Features + Testing
**Parallel workable**:
- Task 4.1-4.6 → Retention features (~265 min = 4.4 hours)
- Task 5.1-5.3 → Testing (~160 min = 2.7 hours)

**Total Week 3**: ~7.1 hours

---

### Week 4: Localization + Documentation
- Task 6.1-6.3 → Finalization (~95 min = 1.6 hours)

**Total Week 4**: ~1.6 hours

---

## ✅ Quality Gates

After **EACH** task:
- [ ] `flutter analyze` → 0 errors
- [ ] All text uses `context.l10n.*` (no hardcoded strings)
- [ ] All colors use `context.colors.*` (theme compliance)
- [ ] Icons use `AppIcons.*` (not `Icons.*`)
- [ ] Commit with format: `feat(ai_coach): [Task X.Y] description`
- [ ] Tests pass (if applicable)

---

## 🎯 Success Metrics

After full implementation:

| Metric | Baseline | Target | Method |
|--------|----------|--------|--------|
| False Positive Rate | 40% | <10% | User feedback analysis |
| Actionable Insights | 30% | >80% | Action rate tracking |
| Day 1 Retention | 45% | 60% | Onboarding completion |
| Day 30 Retention | 8% | 15% | Gamification + notifications |
| Notification Opt-In | 45% | 70% | Smart ask timing |
| Engagement Rate | 20% | 50% | Insight interaction |
| Conversion Rate | 0% | 3-5% | Paywall optimization |

---

## 🚨 Risk Mitigation

### Risk #1: Task Estimation Too Optimistic
**Mitigation**:
- Add 20% buffer to each week
- Focus on MUST DO FIRST tasks
- Parallel work only after blockers complete

### Risk #2: Backward Compatibility Breaks
**Mitigation**:
- Keep old AICoachService alongside new
- Gradual migration (feature flag)
- Comprehensive integration tests

### Risk #3: Performance Regression
**Mitigation**:
- Profile before/after
- Cache insights (Hive)
- Lazy loading for charts

---

## 📝 Notes & Decisions

### Design Decision Log

**2025-01-15**: Chose Strategy Pattern over Observer Pattern
- **Reason**: Better testability, clearer separation of concerns
- **Trade-off**: More boilerplate, but worth it for maintainability

**2025-01-15**: Using fl_chart instead of charts_flutter
- **Reason**: Better Flutter integration, more active maintenance
- **Trade-off**: Learning curve, but better long-term

**2025-01-15**: Freezed for all domain entities
- **Reason**: Immutability, equality, copyWith out of the box
- **Trade-off**: Code generation overhead, but standard practice

---

## 🔗 Cross-References

**Related Documents**:
- Architecture Design: `2025-01-15-ai-coach-refactoring-design.md`
- Retention Strategy: `2025-01-15-ai-coach-retention-strategy.md`

**Related Code**:
- Current monolithic service: `lib/features/home/domain/services/ai_coach_service.dart`
- Current UI card: `lib/features/home/presentation/widgets/ai_coach_card.dart`
- Good separation example: `lib/features/home/domain/services/ai_volume_calculator.dart`

---

## 🎓 Retrospective Template (Complete After Implementation)

### What Went Well
- [ ] (Fill after Task 1.3)
- [ ] (Fill after Task 2.7)
- [ ] (Fill after Task 3.5)

### What Didn't Go Well
- [ ] (Fill with blockers/issues)

### Learnings
- [ ] Estimation accuracy: Actual time vs. estimated
- [ ] Threshold values that worked best
- [ ] User feedback on new features

### Action Items for Future
- [ ] Patterns to replicate
- [ ] Mistakes to avoid

---

**Plan Version**: 1.0
**Generated By**: task-master.dev + Claude Code
**Total Estimated Time**: 18-20 hours (4 weeks)
**Confidence Level**: HIGH (detailed breakdown, clear dependencies)
