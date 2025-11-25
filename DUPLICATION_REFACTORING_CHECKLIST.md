# Code Duplication Refactoring - Action Checklist

**Status**: ✅ ALL CLEANUP COMPLETED
**Last Updated**: 2025-11-25 (Re-analysis + Fix completed)

---

## 🎉 PROGRESS SUMMARY

**Completed**: 17 major duplications resolved (including WorkoutTemplate rename)
**Clarified**: 12 "false duplications" (different purposes)
**New Issues**: 0
**Remaining**: 0 - All SSOT issues resolved!

---

## QUICK REFERENCE - Status Update

### ✅ RESOLVED (Already Done)

- [x] **Context Extensions** (3→1 file) - ✅ DONE
- [x] **Hive Box Manager** - ✅ Using enhanced version
- [x] **Exercise Entity** - ✅ CLARIFIED: ExerciseDefinition vs Exercise (different purposes)
- [x] **Timer State** (3→1) - ✅ DONE
- [x] **Workout Template** - ✅ FIXED: Renamed static `WorkoutTemplate` → `ExerciseSuggestions` in workout.dart
  - `CommunityWorkoutTemplate` (workout_templates feature) - for community sharing
  - `WorkoutTemplate` (workout feature) - for user templates
  - `ExerciseSuggestions` (workout.dart) - static exercise database (was misnamed)
- [x] **Template Card** (2→1) - ✅ DONE
- [x] **AI Coach Card** (2→1) - ✅ DONE
- [x] **Quick Start Card** (3→1) - ✅ DONE
- [x] **Tier1 Components** (2→1) - ✅ DONE
- [x] **Template Provider** (home→workout_templates) - ✅ DONE
- [x] **Template Repository** (workout→workout_templates) - ✅ DONE
- [x] **Achievement Repository** (ai_coach→analytics) - ✅ DONE
- [x] **Achievement Provider** (ai_coach→analytics) - ✅ DONE
- [x] **Streak Repository** (ai_coach→streak) - ✅ DONE
- [x] **Feature Flags** (core) - ✅ DONE
- [x] **CPU/Memory Monitor** - ✅ DONE

### ✅ CLARIFIED (Different Purposes - Keep Both)

- [x] **BaseHybridRepository** (2 versions) - ✅ CLARIFIED: Documented different purposes
  - `BaseHybridRepository` → USER data (workouts, analytics) with full CRUD + waitForDisposal()
  - `OptimizedBaseHybridRepository` → SHARED data (exercise DB) with 24h caching, no CRUD
- [x] **Logger Files** (14 classes) - ✅ CLARIFIED: Different purposes, not duplicates
  - `SecureLogger` → SSOT for security-aware logging with PII sanitization
  - `PersistentLogger` → FILE-based logging for release debugging
  - `AppLogger/DebugLogger/ProductionLogger` → Memory-based with different levels
  - `TimerLogger` → Domain-specific [TIMER] prefix
  - `_*Logger` (6 files) → Private feature-scoped (intentional)

### ✅ CLARIFIED (Proper Architecture - Keep Separate)

- [x] **Notification Services** (9 services) - ✅ CLARIFIED: Single Responsibility architecture
  - `NotificationService` (timer) → Platform infrastructure (flutter_local_notifications)
  - `IntelligentNotificationService` → AI-based post-workout notifications
  - `SmartNotificationService` → Smart scheduling per routine
  - `PRNotificationService` → PR celebration
  - `RoutineNotificationService` → Routine reminders
  - `StreakAchievementNotificationService` → Streak achievements
  - `DailyWorkoutReminderService` → Daily reminders
- [x] **Consent Dialogs** (4 dialogs) - ✅ CLARIFIED: GDPR compliance requires separation
  - `ConsentDialog` (shared) → GDPR Art. 7 general consent
  - `PrivacyConsentDialog` (notifications) → GDPR Art. 7 notification consent
  - `HealthKitConsentDialog` (ai_coach) → GDPR Art. 9 iOS health data (Special Category)
  - `HealthConnectConsentDialog` (ai_coach) → GDPR Art. 9 Android health data (Special Category)

---

## PHASE 1: QUICK WINS (Week 1-2)

### Task 1.1: Context Extensions Consolidation
- [ ] Identify all 3 context_extensions files
- [ ] Verify they have identical content
- [ ] Merge into `/shared/presentation/extensions/build_context_extensions.dart`
- [ ] Remove old locations
- [ ] Update imports (use IDE bulk refactoring)
- [ ] Run tests
- [ ] Verify no broken imports

**Files to Update**: 50-80  
**Estimated Time**: 8-10 hours  
**Risk Level**: Low

---

### Task 1.2: HiveBoxManager Migration (Enhanced → Basic)
- [ ] Rename `hive_box_manager_enhanced.dart` → `hive_box_manager_tmp.dart`
- [ ] Verify all imports of basic version
- [ ] Replace basic with enhanced (better error handling)
- [ ] Rename back to `hive_box_manager.dart`
- [ ] Update imports in all files using basic version
- [ ] Remove old basic version file
- [ ] Test Hive operations
- [ ] Verify database migrations work

**Files to Update**: 10-20  
**Estimated Time**: 6-8 hours  
**Risk Level**: Medium (database operations affected)

---

### Task 1.3: Timer State (3→1)
- [ ] Identify which is canonical (entities/ likely)
- [ ] Merge models/timer_state.dart into entities/timer_state.dart
- [ ] Check unified_timer_state.dart is truly different
- [ ] Remove duplicate files
- [ ] Update imports
- [ ] Test timer operations
- [ ] Verify all timer-related tests pass

**Files to Update**: 15-20  
**Estimated Time**: 4-6 hours  
**Risk Level**: Low

---

### Task 1.4: Quick Start Card Files
- [ ] Consolidate 3 variations into one
- [ ] Use subdirectory structure: `/quick_start/quick_start_card.dart`
- [ ] Move template variant to: `/template_cards/template_quick_start_card.dart`
- [ ] Update imports
- [ ] Verify widget renders correctly

**Files to Update**: 5-8  
**Estimated Time**: 2-3 hours  
**Risk Level**: Low

---

### Task 1.5: AI Coach Card
- [ ] Consolidate into `/ai_coach/presentation/widgets/ai_coach_card.dart`
- [ ] Remove home version
- [ ] Home feature imports from ai_coach feature
- [ ] Add variant parameter if needed (compact/detail)
- [ ] Test both home and ai_coach screens

**Files to Update**: 3-5  
**Estimated Time**: 2 hours  
**Risk Level**: Low

---

### Task 1.6: Template Card Consolidation
- [ ] Keep in `workout_templates/presentation/widgets/template_card.dart`
- [ ] Remove `workout/presentation/widgets/template_card.dart`
- [ ] Update workout feature imports
- [ ] Test template rendering

**Files to Update**: 5-8  
**Estimated Time**: 2 hours  
**Risk Level**: Low

---

### Task 1.7: Tier1 Components Move to Shared
- [ ] Create `/shared/presentation/widgets/tier1/`
- [ ] Move consolidated version there
- [ ] Remove from home and analytics
- [ ] Update imports
- [ ] Test both features

**Files to Update**: 5-10  
**Estimated Time**: 3 hours  
**Risk Level**: Low

---

### Task 1.8: Exercise History Tab Move to Shared
- [ ] Create `/shared/presentation/widgets/exercise_history_tab.dart`
- [ ] Remove feature-specific versions
- [ ] Update imports in workout and analytics
- [ ] Test both features

**Files to Update**: 3-5  
**Estimated Time**: 2 hours  
**Risk Level**: Low

---

### Task 1.9: Monitor Files Consolidation
- [ ] Keep `core/utils/memory_monitor.dart` as SSOT
- [ ] Remove `features/home/presentation/providers/memory_monitor.dart`
- [ ] Same for CPU monitor (keep core/utils/)
- [ ] Update imports

**Files to Update**: 3-5  
**Estimated Time**: 1-2 hours  
**Risk Level**: Low

---

### Task 1.10: Feature Flags Consolidation
- [ ] Keep `core/config/feature_flags.dart`
- [ ] Remove `shared/config/feature_flags.dart`
- [ ] Update imports

**Files to Update**: 10-15  
**Estimated Time**: 2-3 hours  
**Risk Level**: Low

---

## PHASE 2: MEDIUM EFFORT (Week 3-4)

### Task 2.1: Exercise Entity Consolidation (2→1)
- [ ] Decide: Keep `exercise_database/domain/entities/exercise.dart`
- [ ] Remove `workout/domain/entities/exercise.dart`
- [ ] Check for circular dependencies (high risk)
- [ ] Update 30-50 import statements
- [ ] Careful testing required (exercise used everywhere)
- [ ] Test all workout and analytics features

**Files to Update**: 30-50  
**Estimated Time**: 12-16 hours  
**Risk Level**: High (circular dependency risk)

---

### Task 2.2: Analytics Provider Consolidation (4→1 file)
- [ ] Create main `analytics_providers.dart` file
- [ ] Move all provider definitions there:
  - `workoutAnalyticsProvider`
  - `lazyAnalyticsProvider`
  - `memoizedAnalyticsProvider`
  - `skipAnalyticsProvider`
- [ ] Remove individual provider files
- [ ] Update imports in 10-15 files

**Files to Update**: 10-15  
**Estimated Time**: 6-8 hours  
**Risk Level**: Low

---

### Task 2.3: Sync Status Consolidation (2-3→1)
- [ ] SSOT: `shared/domain/entities/sync_status.dart`
- [ ] Remove `history/domain/entities/sync_status.dart`
- [ ] Keep `health_sync_status.dart` if health-specific
- [ ] Update imports

**Files to Update**: 8-12  
**Estimated Time**: 3-4 hours  
**Risk Level**: Low

---

### Task 2.4: Rate Limiter Consolidation
- [ ] SSOT: `shared/domain/security/rate_limiter.dart`
- [ ] Remove `core/services/rate_limiter.dart`
- [ ] Update imports

**Files to Update**: 8-12  
**Estimated Time**: 2-3 hours  
**Risk Level**: Low

---

### Task 2.5: I Analytics Service Consolidation
- [ ] SSOT: `core/services/analytics/i_analytics_service.dart`
- [ ] Remove `shared/domain/services/i_analytics_service.dart`
- [ ] Update imports

**Files to Update**: 5-8  
**Estimated Time**: 1-2 hours  
**Risk Level**: Low

---

### Task 2.6: Secure Logger Verification
- [ ] Verify all imports use `shared/domain/services/secure_logger.dart`
- [ ] Confirm re-exports in deprecated locations work
- [ ] Document deprecation timeline

**Files to Update**: None (already handled)  
**Estimated Time**: 0.5-1 hour  
**Risk Level**: None

---

### Task 2.7: Consent Dialogs Consolidation (4→1 + variants)
- [ ] Create generic `shared/presentation/widgets/consent/generic_consent_dialog.dart`
- [ ] Keep feature-specific only if truly different UX
- [ ] Create variants:
  - `health_kit_consent_variant.dart`
  - `privacy_consent_variant.dart`
  - `health_connect_consent_variant.dart`
- [ ] Update imports

**Files to Update**: 8-12  
**Estimated Time**: 8-10 hours  
**Risk Level**: Low

---

### Task 2.8: Exercise Replacement Dialog/Modal
- [ ] SSOT: `workout/presentation/widgets/exercise_replacement_dialog.dart`
- [ ] Remove: home version and modal variant
- [ ] Keep dialog, create modal as wrapper if needed
- [ ] Update imports

**Files to Update**: 3-5  
**Estimated Time**: 2 hours  
**Risk Level**: Low

---

### Task 2.9: Recovery Skip Dialogs
- [ ] Consolidate into: `routine/presentation/widgets/skip_recovery_dialog.dart`
- [ ] Decide on dialog vs bottom_sheet (keep one)
- [ ] Remove duplicate
- [ ] Update imports

**Files to Update**: 2-3  
**Estimated Time**: 1-2 hours  
**Risk Level**: Low

---

### Task 2.10: Base Hybrid Repository Migration (Optimized)
- [ ] Verify optimized version is truly better
- [ ] If yes: Rename optimized → basic
- [ ] Remove old basic version
- [ ] Update all repository imports

**Files to Update**: 15-25  
**Estimated Time**: 6-8 hours  
**Risk Level**: Medium

---

## PHASE 3: STRATEGIC REFACTORING (Week 5-6)

### Task 3.1: Notification Services Architecture Redesign
- [ ] Create domain interfaces:
  - `notifications/domain/services/i_notification_service.dart`
  - `notifications/domain/services/i_notification_scheduler.dart`
- [ ] Create data layer implementations
- [ ] Create feature-specific facades (optional)
- [ ] Consolidate all 6+ notification services
- [ ] Major refactoring affecting multiple features

**Files to Update**: 20-30  
**Estimated Time**: 24-30 hours  
**Risk Level**: High (core system change)

---

### Task 3.2: Workout Template vs Workout Feature Clarification
- [ ] Decision: Does workout_templates own templates?
- [ ] If YES: Move all template logic there
- [ ] If NO: Merge workout_templates into workout feature
- [ ] Current recommendation: Keep separation
- [ ] Move Template entity to workout_templates if needed
- [ ] Update all import paths

**Files to Update**: 25-40  
**Estimated Time**: 20-30 hours  
**Risk Level**: High (architectural decision)

---

### Task 3.3: Repository and Service Consolidation
- [ ] Consolidate achievement repositories (2→1)
- [ ] Consolidate template repositories (2→1)
- [ ] Consolidate template providers (2→1)
- [ ] Consolidate streak repositories (2→1)
- [ ] Consolidate consent repositories (2→1)

**Files to Update**: 40-60  
**Estimated Time**: 16-20 hours  
**Risk Level**: Medium

---

### Task 3.4: Logging Architecture Consolidation
- [ ] Create unified logging service
- [ ] Consolidate debug, production, secure, persistent loggers
- [ ] Create proper service hierarchy
- [ ] Update all imports

**Files to Update**: 20-30  
**Estimated Time**: 12-16 hours  
**Risk Level**: Medium

---

### Task 3.5: Context Extensions - Final Verification
- [ ] Ensure all extensions are properly categorized
- [ ] Add missing extensions if needed
- [ ] Document extension library
- [ ] Create extension test suite

**Files to Update**: Done in Phase 1  
**Estimated Time**: 4-6 hours  
**Risk Level**: Low

---

## IMPLEMENTATION STRATEGY

### Approach A: Individual Tasks (Safer)
- Do one duplication at a time
- Test thoroughly after each
- Easier to rollback if issues
- Takes longer (20-30 weeks)

### Approach B: Batched by Feature (Faster)
- Group by feature (ai_coach, analytics, workout, etc.)
- Refactor all related duplications together
- Test entire feature after
- Takes 4-6 weeks
- Higher risk (more changes at once)

### Approach C: Hybrid (Recommended)
- **Week 1-2**: Phase 1 (low-risk quick wins)
- **Week 3-4**: Phase 2 (medium effort, medium risk)
- **Week 5-6**: Phase 3 (strategic, high risk)
- **Week 7**: Testing, verification, documentation

---

## TESTING CHECKLIST

After each task, verify:

- [ ] Imports compile without errors
- [ ] No circular dependencies
- [ ] `flutter analyze` passes
- [ ] All tests still pass
- [ ] Feature-specific tests pass
- [ ] No unused imports
- [ ] Documentation updated if paths changed

---

## PARALLEL WORK OPPORTUNITIES

These can be done simultaneously (no conflicts):
- Task 1.4 (Quick Start Card) + Task 1.5 (AI Coach Card)
- Task 1.6 (Template Card) + Task 1.7 (Tier1 Components)
- Task 1.8 (Exercise History) + Task 1.9 (Monitors)

---

## RISK MITIGATION

### High-Risk Tasks:
- **Exercise Entity**: Create branch, test thoroughly
- **Notification Services**: Complex interdependencies, needs planning
- **Workout Template**: Architectural decision, gather team input first

### Mitigation:
- [ ] Create feature branch for refactoring
- [ ] Have at least 2 reviewers for high-risk PRs
- [ ] Test on both iOS and Android
- [ ] Test in debug and release modes
- [ ] Run full test suite after each phase

---

## SUCCESS CRITERIA

✓ All duplications consolidated to single SSOT  
✓ No circular dependencies  
✓ `flutter analyze` passes with 0 errors  
✓ All tests passing  
✓ Import paths consistent across codebase  
✓ Documentation updated  
✓ Team familiar with new structure  

---

## METRICS TO TRACK

- [ ] Lines of duplicate code removed: _____ LOC
- [ ] Number of consolidations completed: ___/31
- [ ] Files updated: ___/320
- [ ] Test pass rate: _____%
- [ ] Build time (before): ___s → (after): ___s
- [ ] Time spent per task

---

## NOTES & OBSERVATIONS

**Already Good** (No refactoring needed):
- APRE Services - Proper hierarchy
- Insight Services - Well distributed
- Feature Gate System - Single feature
- Event Trackers - Centralized

**Watch For**:
- Circular dependencies when consolidating exercise entity
- Database migration issues with HiveBoxManager change
- Deep import trees in notification services

**Opportunities**:
- Move common UI patterns to shared after consolidation
- Improve test organization after structural refactoring
- Create shared widget library for duplicated components

---

## GENERATED: 2025-11-25
**Full Analysis**: See `DUPLICATE_CODE_ANALYSIS.md`
