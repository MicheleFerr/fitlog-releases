# 🚀 Next Session Plan: Routine Center v2.0 Implementation

## ✅ What's Already Done

### Branch Setup
- ✅ Created branch: `feature/routine-center-v2-pattern-detection`
- ✅ Committed documentation: `ROUTINE_CENTER_IMPROVEMENTS_PLAN.md` (2,290 lines)

### Phase 1 Progress (Started)
- ✅ Created `PatternDetectionResult` entity (95 lines)
  - Location: `lib/features/workout/domain/entities/pattern_detection_result.dart`
  - Features: predictNext(), displayPattern, visualPattern, confidence helpers
  - ⚠️ **Needs**: `dart run build_runner build` to generate .freezed/.g files
  
- ✅ Created `PatternDetectionService` skeleton (85 lines)
  - Location: `lib/features/workout/domain/services/pattern_detection_service.dart`
  - Status: Skeleton only, all methods throw `UnimplementedError`
  - **Ready for TDD implementation**

## 🎯 Next Session Tasks

### Immediate Action (5 min)
1. **Fix Build Runner Blocker**:
   ```bash
   # Fix syntax error in premium_purchase_screen_v2.dart:1598
   # Error: "A try block must be followed by an 'on', 'catch', or 'finally' clause"
   ```

2. **Generate Freezed Files**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Phase 1 Implementation (TDD Approach)

#### Step 1: Write Tests First (1 hour)
File: `test/features/workout/domain/services/pattern_detection_service_test.dart`

Test cases to write:
```dart
group('PatternDetectionService', () {
  test('detects simple 3-workout pattern', () {});
  test('detects 2-workout alternating pattern', () {});
  test('returns null when insufficient data', () {});
  test('calculates confidence correctly', () {});
  test('handles irregular patterns', () {});
  test('normalizes workout names', () {});
  test('finds last position correctly', () {});
  test('prefers longer patterns over shorter', () {});
  test('handles pattern violations', () {});
  test('performance <100ms for 50 workouts', () {});
});
```

#### Step 2: Implement PatternDetectionService (2-3 hours)
Methods to implement in order:

1. `_normalizeWorkoutName()` - Simple string manipulation
2. `_findPatternsOfLength()` - Sliding window algorithm
3. `_calculateConfidence()` - Scoring formula
4. `detectPattern()` - Main logic orchestration

**Reference**: See `ROUTINE_CENTER_IMPROVEMENTS_PLAN.md` lines 356-475 for complete algorithm

#### Step 3: Create PatternViabilityChecker (1 hour)
File: `lib/features/workout/domain/services/pattern_viability_checker.dart`

5 viability rules:
- Minimum confidence 0.70
- Minimum 3 complete cycles
- Minimum 18 days of data
- Minimum 6 workouts total
- Pattern coverage >50%

**Reference**: See `ROUTINE_CENTER_IMPROVEMENTS_PLAN.md` lines 1367-1391

#### Step 4: Integration + Polish (30 min)
- Run all tests
- Benchmark performance
- Update TodoWrite to mark Phase 1 complete

## 📊 Progress Tracking

Phase 1: Pattern Detection Core (3-4 days)
- [x] Entity created (PatternDetectionResult)
- [x] Service skeleton created
- [ ] Unit tests written (10+ cases)
- [ ] Service implemented (sliding window)
- [ ] Viability checker implemented
- [ ] Performance benchmark passed
- [ ] Phase 1 complete ✅

## 🔗 Key References

1. **Algorithm Details**: `ROUTINE_CENTER_IMPROVEMENTS_PLAN.md` lines 356-475
2. **Viability Rules**: `ROUTINE_CENTER_IMPROVEMENTS_PLAN.md` lines 1367-1391
3. **Consultant Feedback**: `ROUTINE_CENTER_IMPROVEMENTS_PLAN.md` lines 1339-2230
4. **Success Metrics**: `ROUTINE_CENTER_IMPROVEMENTS_PLAN.md` lines 736-750

## ⚡ Quick Start Commands

```bash
# Fix build runner blocker first
# Then generate freezed files
dart run build_runner build --delete-conflicting-outputs

# Run tests (once implemented)
flutter test test/features/workout/domain/services/pattern_detection_service_test.dart

# Check performance
flutter test test/features/workout/domain/services/pattern_detection_service_test.dart --name "performance"
```

## 🎯 After Phase 1

Remaining phases (in order):
- Phase 2: Prediction Engine Integration (2-3 days)
- Phase 3: UI Components (3-4 days)
- Phase 4: FlexibleRoutine Integration (2-3 days)
- Phase 5: Analytics & Tracking (2 days)
- Phase 6: Testing & Polish (2-3 days)

**Total estimate**: 14-19 days remaining after Phase 1

---

**Last updated**: Session 2025-01-03
**Branch**: `feature/routine-center-v2-pattern-detection`
**Status**: Phase 1 in progress (30% complete)
