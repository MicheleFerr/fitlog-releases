# AI Coach Feature Optimization - Task Plan

**Generated**: 2025-11-16 (current time)
**Source**: task-master.dev (WebFetch)
**Complexity Score**: HIGH
**Reason**: Multiple systems integration + GDPR compliance + 53 tasks
**Total Tasks**: 53
**Estimated Time**: ~76h (9.5 days)
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: 3.16.0
- App Version: 1.0.0+49
- Key Packages: riverpod ^2.4.9, firebase_core ^2.24.2, health ^9.0.0 (to be added)
- Target Platforms: iOS 14+, Android 8+
- Related PRs/Issues: None
- Parent Milestone: None
- Last Commit: 7ebb4e4 - docs: update INDEX.md with AI Coach critical implementation guide

---

## 📋 Original Request

> Implement 8 AI Coach Feature optimizations for FitLog Pro fitness app with verified ROI analysis:
>
> **P0 - Quick Wins (Week 1-2)**: Firebase architecture optimization, polling + cache strategy, unlock timing optimization
>
> **P1 - Strategic (Week 3-4)**: Apple HealthKit integration, Health Connect (Android) integration
>
> **P1 - Polish (Week 5-6)**: Staged recovery insights, GDPR breach notification plan, workout vs health data separation

---

## 🎯 Task Breakdown

### **P0: Quick Wins (Week 1-2)** - 12 Tasks, ~12h

#### Firebase Architecture Optimization (4h)

- [ ] **Task 1.1**: Refactor Firestore Document Structure
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/datasources/firebase_coach_datasource.dart`
  - **Dependencies**: None
  - **Est. Time**: 45 min
  - **Blocking**: Yes (blocks Task 1.2, 1.3, 1.4)
  - **Verification**: Profiler shows reads reduced from 8 to 1 on app startup
  - **Code Prompt**:
    ```dart
    // Replace subcollection pattern with single document + map
    // Before: collection('users').doc(userId).collection('featureGates')
    // After: collection('users').doc(userId).set({'features': {...}})
    ```

- [ ] **Task 1.2**: Implement Local TTL Cache Layer
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/local/coach_cache.dart`
  - **Dependencies**: Task 1.1
  - **Est. Time**: 1h 15min
  - **Blocking**: Yes (blocks Task 1.3, 1.4)
  - **Verification**: Cache hits logged, age tracked, 6h expiration confirmed
  - **Code Prompt**:
    ```dart
    // Create cache with TTL mechanism
    class CoachCache {
      final _cache = <String, CachedData>{};
      final Duration ttl = Duration(hours: 6);

      T? get<T>(String key) {
        if (_cache[key]?.isExpired ?? true) return null;
        return _cache[key]!.data as T;
      }
    }
    ```

- [ ] **Task 1.3**: Update Repository Cache Integration
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/repositories/coach_repository_impl.dart`
  - **Dependencies**: Task 1.2
  - **Est. Time**: 1h
  - **Blocking**: No
  - **Verification**: Repository returns cached data before Firestore calls
  - **Code Prompt**:
    ```dart
    // Add cache check in repository
    Future<Map<String, bool>> getFeatures(String userId) async {
      // Check cache first
      final cached = _cache.get<Map<String, bool>>(userId);
      if (cached != null) return cached;

      // Fetch from Firestore
      final features = await _datasource.getFeatures(userId);
      _cache.set(userId, features);
      return features;
    }
    ```

- [ ] **Task 1.4**: Add Cache Invalidation on Unlock Event
  - **Layer**: Domain
  - **Files**: `lib/features/ai_coach/domain/usecases/invalidate_coach_cache.dart`
  - **Dependencies**: Task 1.2
  - **Est. Time**: 1h
  - **Blocking**: No
  - **Verification**: Manual cache clear triggers immediate Firestore refresh
  - **Code Prompt**:
    ```dart
    // Create use case for cache invalidation
    class InvalidateCoachCache {
      Future<void> call(String userId) async {
        _cache.remove(userId);
        await _repository.fetchFreshFeatures(userId);
      }
    }
    ```

---

#### Polling + Cache Strategy (6h)

- [ ] **Task 2.1**: Remove Real-time StreamBuilder Listeners
  - **Layer**: Presentation
  - **Files**: `lib/features/ai_coach/presentation/pages/coach_page.dart`
  - **Dependencies**: Task 1.1
  - **Est. Time**: 1h 30min
  - **Blocking**: Yes (blocks Task 2.2)
  - **Verification**: No StreamBuilder instances in coach widgets
  - **Code Prompt**:
    ```dart
    // Replace StreamBuilder with FutureBuilder + polling
    // Before: StreamBuilder(stream: featureGatesCollection.snapshots())
    // After: FutureBuilder(future: _pollingService.getFeatures())
    ```

- [ ] **Task 2.2**: Implement Polling Service with 6h TTL
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/services/polling_service.dart`
  - **Dependencies**: Task 1.2, Task 2.1
  - **Est. Time**: 1h 45min
  - **Blocking**: Yes (blocks Task 2.3)
  - **Verification**: Polling intervals logged, reads drop from 40/day to 4/day
  - **Code Prompt**:
    ```dart
    // Create polling service with configurable TTL
    class PollingService {
      final Duration pollInterval = Duration(hours: 6);

      Future<Map<String, bool>> getFeatures() async {
        if (_shouldPoll()) {
          return await _fetchAndCache();
        }
        return _cache.get();
      }
    }
    ```

- [ ] **Task 2.3**: Create Polling Notifier (Riverpod)
  - **Layer**: Presentation
  - **Files**: `lib/features/ai_coach/presentation/riverpod/polling_notifier.dart`
  - **Dependencies**: Task 2.2
  - **Est. Time**: 1h 30min
  - **Blocking**: Yes (blocks Task 2.4)
  - **Verification**: Riverpod provider triggers polls at configured intervals
  - **Code Prompt**:
    ```dart
    // Create Riverpod notifier for polling
    class PollingNotifier extends StateNotifier<AsyncValue<Map<String, bool>>> {
      PollingNotifier(this._service) : super(const AsyncValue.loading()) {
        _startPolling();
      }

      void _startPolling() {
        Timer.periodic(_pollInterval, (_) => _poll());
      }
    }
    ```

- [ ] **Task 2.4**: Add Manual Refresh Trigger on Unlock
  - **Layer**: Presentation
  - **Files**: `lib/features/ai_coach/presentation/pages/coach_page.dart`
  - **Dependencies**: Task 2.3
  - **Est. Time**: 45min
  - **Blocking**: No
  - **Verification**: Unlock event invalidates cache and triggers immediate poll
  - **Code Prompt**:
    ```dart
    // Add manual refresh on unlock event
    void onUnlockEvent() {
      ref.read(pollingNotifierProvider.notifier).refreshImmediately();
    }
    ```

---

#### Unlock Timing Optimization (2h)

- [ ] **Task 3.1**: Update Unlock Requirement from 3rd to 2nd Workout
  - **Layer**: Domain
  - **Files**: `lib/features/ai_coach/domain/entities/unlock_requirement.dart`
  - **Dependencies**: None
  - **Est. Time**: 30min
  - **Blocking**: Yes (blocks Task 3.2)
  - **Verification**: Unit test confirms unlock at 2nd workout, not 3rd
  - **Code Prompt**:
    ```dart
    // Change unlock constant
    // Before: const MIN_WORKOUTS_FOR_UNLOCK = 3;
    // After: const MIN_WORKOUTS_FOR_UNLOCK = 2;
    ```

- [ ] **Task 3.2**: Implement Multi-Factor Unlock Logic
  - **Layer**: Domain
  - **Files**: `lib/features/ai_coach/domain/usecases/evaluate_unlock_criteria.dart`
  - **Dependencies**: Task 3.1
  - **Est. Time**: 1h
  - **Blocking**: Yes (blocks Task 3.3)
  - **Verification**: Unlock requires both 2 workouts AND minimum active days
  - **Code Prompt**:
    ```dart
    // Add multi-factor logic
    bool canUnlock(User user) {
      return user.workoutCount >= 2 &&
             user.daysSinceRegistration >= 3 &&
             user.hasCompletedOnboarding;
    }
    ```

- [ ] **Task 3.3**: Update Unlock Celebration UI
  - **Layer**: Presentation
  - **Files**: `lib/features/ai_coach/presentation/widgets/unlock_celebration.dart`
  - **Dependencies**: Task 3.2
  - **Est. Time**: 30min
  - **Blocking**: Yes (blocks Task 3.4)
  - **Verification**: Visual celebration displays when unlock criteria met
  - **Code Prompt**:
    ```dart
    // Create celebration widget
    class UnlockCelebration extends StatelessWidget {
      Widget build(context) => Dialog(
        child: Column(children: [
          Text('🎉 ${context.l10n.newUnlock}'),
          Text(featureName),
          ElevatedButton(context.l10n.tryNow, onTap: ...)
        ])
      );
    }
    ```

- [ ] **Task 3.4**: Add Unlock Analytics Tracking
  - **Layer**: Presentation
  - **Files**: `lib/features/ai_coach/presentation/analytics/unlock_analytics.dart`
  - **Dependencies**: Task 3.3
  - **Est. Time**: 30min
  - **Blocking**: No
  - **Verification**: Firebase Analytics logs unlock attempts and successes
  - **Code Prompt**:
    ```dart
    // Log unlock analytics
    void logUnlockAttempt({required String feature, required bool success}) {
      analytics.logEvent('feature_unlock', parameters: {
        'feature': feature,
        'successful': success,
        'workout_count': user.workoutCount,
      });
    }
    ```

---

### **P1: Strategic (Week 3-4)** - 20 Tasks, ~40h

#### Apple HealthKit Integration (20h)

- [ ] **Task 4.1**: Add Health Package Dependency
  - **Layer**: Infrastructure
  - **Files**: `pubspec.yaml`
  - **Dependencies**: None
  - **Est. Time**: 30min
  - **Blocking**: Yes (blocks all HealthKit tasks)
  - **Verification**: `flutter pub get` succeeds, health plugin loads
  - **Code Prompt**:
    ```yaml
    # Add to pubspec.yaml
    dependencies:
      health: ^9.0.0
    ```

- [ ] **Task 4.2**: Configure Info.plist Usage Descriptions
  - **Layer**: Infrastructure
  - **Files**: `ios/Runner/Info.plist`
  - **Dependencies**: Task 4.1
  - **Est. Time**: 45min
  - **Blocking**: Yes (blocks Task 4.3)
  - **Verification**: NSHealthShareUsageDescription keys present for step/HR/workout
  - **Code Prompt**:
    ```xml
    <!-- Add to Info.plist -->
    <key>NSHealthShareUsageDescription</key>
    <string>Sync workouts and health data for AI-powered insights</string>
    ```

- [ ] **Task 4.3**: Create HealthKit Datasource (Clean Architecture)
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/datasources/healthkit_datasource.dart`
  - **Dependencies**: Task 4.2
  - **Est. Time**: 2h 30min
  - **Blocking**: Yes (blocks Task 4.4, 4.7)
  - **Verification**: Datasource returns step/HR/workout data from HealthKit
  - **Code Prompt**:
    ```dart
    // Create HealthKit datasource
    class HealthKitDatasource {
      final Health _health;

      Future<List<HealthDataPoint>> getStepsToday() async {
        return await _health.getHealthDataFromTypes(
          types: [HealthDataType.STEPS],
          startTime: startOfDay,
          endTime: now,
        );
      }
    }
    ```

- [ ] **Task 4.4**: Implement HealthKit Sync Service
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/services/healthkit_sync_service.dart`
  - **Dependencies**: Task 4.3
  - **Est. Time**: 2h
  - **Blocking**: Yes (blocks Task 4.5)
  - **Verification**: Service syncs data without blocking main thread
  - **Code Prompt**:
    ```dart
    // Create sync service with isolate
    class HealthKitSyncService {
      Future<void> syncInBackground() async {
        await compute(_syncHealthData, userId);
      }

      static Future<void> _syncHealthData(String userId) async {
        // Heavy work in isolate
      }
    }
    ```

- [ ] **Task 4.5**: Build GDPR Article 9 Consent Dialog (iOS)
  - **Layer**: Presentation
  - **Files**: `lib/features/ai_coach/presentation/dialogs/health_consent_dialog.dart`
  - **Dependencies**: Task 4.4
  - **Est. Time**: 1h 30min
  - **Blocking**: Yes (blocks Task 4.6)
  - **Verification**: Dialog explains biometric data processing per Article 9
  - **Code Prompt**:
    ```dart
    // Create GDPR consent dialog
    class HealthConsentDialog extends StatelessWidget {
      Widget build(context) => AlertDialog(
        title: Text('🔒 ${context.l10n.yourHealthDataPrivacy}'),
        content: Column(children: [
          Checkbox(
            value: agreeToHealthTracking,
            onChanged: (value) => setState(() => agreeToHealthTracking = value),
          ),
          Text(context.l10n.healthConsentExplanation),
        ]),
      );
    }
    ```

- [ ] **Task 4.6**: Add HealthKit Permission Error Handling
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/datasources/healthkit_datasource.dart`
  - **Dependencies**: Task 4.5
  - **Est. Time**: 1h
  - **Blocking**: No
  - **Verification**: Graceful fallback when permission denied/unavailable
  - **Code Prompt**:
    ```dart
    // Add error handling
    Future<Result<HealthData>> getHealthData() async {
      try {
        final data = await _health.requestData();
        return Result.success(data);
      } on PermissionDenied {
        return Result.failure('Permission denied. Ask again in 7 days.');
      } on HealthKitNotAvailable {
        return Result.failure('HealthKit not available on this device');
      }
    }
    ```

- [ ] **Task 4.7**: Create HealthKit Models & Mappers
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/models/health_data_model.dart`
  - **Dependencies**: Task 4.3
  - **Est. Time**: 1h 30min
  - **Blocking**: Yes (blocks Task 4.8)
  - **Verification**: Models handle step/HR conversion to domain entities
  - **Code Prompt**:
    ```dart
    // Create models with freezed
    @freezed
    class HealthDataModel with _$HealthDataModel {
      factory HealthDataModel({
        required int steps,
        required int heartRate,
        required DateTime timestamp,
      }) = _HealthDataModel;

      factory HealthDataModel.fromHealthKit(HealthDataPoint point) => ...;
    }
    ```

- [ ] **Task 4.8**: Implement HealthKit Repository Integration
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/repositories/health_repository_impl.dart`
  - **Dependencies**: Task 4.7
  - **Est. Time**: 1h 30min
  - **Blocking**: Yes (blocks Task 4.9)
  - **Verification**: Repository merges HealthKit + Firestore data sources
  - **Code Prompt**:
    ```dart
    // Create repository merging HealthKit + Firestore
    class HealthRepositoryImpl implements HealthRepository {
      Future<HealthData> getHealthData(String userId) async {
        final healthKitData = await _healthKitDatasource.getData();
        final firestoreData = await _firestoreDatasource.getData(userId);
        return _mergeData(healthKitData, firestoreData);
      }
    }
    ```

- [ ] **Task 4.9**: Add Offline Sync Queue for HealthKit Data
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/local/health_sync_queue.dart`
  - **Dependencies**: Task 4.8
  - **Est. Time**: 1h 30min
  - **Blocking**: Yes (blocks Task 4.10)
  - **Verification**: Queue stores health data when offline, syncs on reconnect
  - **Code Prompt**:
    ```dart
    // Create offline sync queue with Hive
    class HealthSyncQueue {
      final Box<HealthDataModel> _queue;

      Future<void> enqueue(HealthDataModel data) async {
        await _queue.add(data);
        if (await _isOnline()) {
          await _syncQueue();
        }
      }
    }
    ```

- [ ] **Task 4.10**: Create HealthKit Test Suite (Physical iPhone)
  - **Layer**: Test
  - **Files**: `test/features/ai_coach/data/datasources/healthkit_datasource_test.dart`
  - **Dependencies**: Task 4.8
  - **Est. Time**: 2h
  - **Blocking**: No
  - **Verification**: Tests pass on physical iPhone (simulator unsupported)
  - **Code Prompt**:
    ```dart
    // Create integration tests
    void main() {
      testWidgets('HealthKit integration test', (tester) async {
        final datasource = HealthKitDatasource();
        final steps = await datasource.getStepsToday();
        expect(steps, isNotNull);
      });
    }
    ```

---

#### Health Connect Integration - Android (20h)

- [ ] **Task 5.1**: Add Health Connect Package Dependency
  - **Layer**: Infrastructure
  - **Files**: `pubspec.yaml`
  - **Dependencies**: None
  - **Est. Time**: 30min
  - **Blocking**: Yes (blocks all Health Connect tasks)
  - **Verification**: `flutter pub get` succeeds, health_connect plugin loads
  - **Code Prompt**:
    ```yaml
    # Add to pubspec.yaml
    dependencies:
      health_connect: ^1.0.0
    ```

- [ ] **Task 5.2**: Configure AndroidManifest.xml Permissions
  - **Layer**: Infrastructure
  - **Files**: `android/app/src/main/AndroidManifest.xml`
  - **Dependencies**: Task 5.1
  - **Est. Time**: 45min
  - **Blocking**: Yes (blocks Task 5.3)
  - **Verification**: QUERY_ALL_PACKAGES + READ_HEALTH_DATA permissions present
  - **Code Prompt**:
    ```xml
    <!-- Add to AndroidManifest.xml -->
    <uses-permission android:name="android.permission.health.READ_STEPS" />
    <uses-permission android:name="android.permission.health.READ_HEART_RATE" />
    ```

- [ ] **Task 5.3**: Create Health Connect Datasource (Clean Architecture)
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/datasources/health_connect_datasource.dart`
  - **Dependencies**: Task 5.2
  - **Est. Time**: 2h 30min
  - **Blocking**: Yes (blocks Task 5.4, 5.7)
  - **Verification**: Datasource returns step/HR/sleep/workout data from HC
  - **Code Prompt**:
    ```dart
    // Create Health Connect datasource
    class HealthConnectDatasource {
      final HealthConnectFactory _healthConnect;

      Future<List<HealthConnectRecord>> getStepsToday() async {
        return await _healthConnect.readRecords(
          recordType: HealthDataType.STEPS,
          startTime: startOfDay,
          endTime: now,
        );
      }
    }
    ```

- [ ] **Task 5.4**: Implement Health Connect Sync Service
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/services/health_connect_sync_service.dart`
  - **Dependencies**: Task 5.3
  - **Est. Time**: 2h
  - **Blocking**: Yes (blocks Task 5.5)
  - **Verification**: Service syncs data without main thread blocking
  - **Code Prompt**:
    ```dart
    // Create sync service
    class HealthConnectSyncService {
      Future<void> syncInBackground() async {
        await compute(_syncHealthConnectData, userId);
      }
    }
    ```

- [ ] **Task 5.5**: Build GDPR Article 9 Consent Dialog (Android)
  - **Layer**: Presentation
  - **Files**: `lib/features/ai_coach/presentation/dialogs/health_connect_consent_dialog.dart`
  - **Dependencies**: Task 5.4
  - **Est. Time**: 1h 30min
  - **Blocking**: Yes (blocks Task 5.6)
  - **Verification**: Dialog explains biometric data usage per Article 9
  - **Code Prompt**:
    ```dart
    // Create GDPR consent dialog (Android variant)
    class HealthConnectConsentDialog extends StatelessWidget {
      Widget build(context) => AlertDialog(
        title: Text('🔒 ${context.l10n.yourHealthDataPrivacy}'),
        content: Column(children: [
          Checkbox(...),
          Text(context.l10n.healthConnectConsentExplanation),
        ]),
      );
    }
    ```

- [ ] **Task 5.6**: Add Health Connect Permission Error Handling
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/datasources/health_connect_datasource.dart`
  - **Dependencies**: Task 5.5
  - **Est. Time**: 1h
  - **Blocking**: No
  - **Verification**: Handles permission denied/app not installed gracefully
  - **Code Prompt**:
    ```dart
    // Add error handling
    Future<Result<HealthData>> getHealthConnectData() async {
      try {
        final data = await _healthConnect.requestData();
        return Result.success(data);
      } on PermissionDenied {
        return Result.failure('Permission denied');
      } on HealthConnectNotInstalled {
        return Result.failure('Install Health Connect app');
      }
    }
    ```

- [ ] **Task 5.7**: Create Health Connect Models & Mappers
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/models/health_connect_model.dart`
  - **Dependencies**: Task 5.3
  - **Est. Time**: 1h 30min
  - **Blocking**: Yes (blocks Task 5.8)
  - **Verification**: Models convert HC data to domain entities
  - **Code Prompt**:
    ```dart
    // Create models
    @freezed
    class HealthConnectModel with _$HealthConnectModel {
      factory HealthConnectModel({
        required int steps,
        required int heartRate,
        required DateTime timestamp,
      }) = _HealthConnectModel;

      factory HealthConnectModel.fromHealthConnect(HealthConnectRecord record) => ...;
    }
    ```

- [ ] **Task 5.8**: Implement Health Connect Repository Integration
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/repositories/health_connect_repository_impl.dart`
  - **Dependencies**: Task 5.7
  - **Est. Time**: 1h 30min
  - **Blocking**: Yes (blocks Task 5.9)
  - **Verification**: Repository merges HC + Firestore data sources
  - **Code Prompt**:
    ```dart
    // Create repository
    class HealthConnectRepositoryImpl implements HealthRepository {
      Future<HealthData> getHealthData(String userId) async {
        final hcData = await _healthConnectDatasource.getData();
        final firestoreData = await _firestoreDatasource.getData(userId);
        return _mergeData(hcData, firestoreData);
      }
    }
    ```

- [ ] **Task 5.9**: Add Offline Sync Queue for Health Connect
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/local/health_connect_sync_queue.dart`
  - **Dependencies**: Task 5.8
  - **Est. Time**: 1h 30min
  - **Blocking**: Yes (blocks Task 5.10)
  - **Verification**: Queue syncs health data when offline reconnects
  - **Code Prompt**:
    ```dart
    // Create offline sync queue
    class HealthConnectSyncQueue {
      final Box<HealthConnectModel> _queue;

      Future<void> enqueue(HealthConnectModel data) async {
        await _queue.add(data);
        if (await _isOnline()) {
          await _syncQueue();
        }
      }
    }
    ```

- [ ] **Task 5.10**: Create Health Connect Test Suite (Physical Android 12+)
  - **Layer**: Test
  - **Files**: `test/features/ai_coach/data/datasources/health_connect_datasource_test.dart`
  - **Dependencies**: Task 5.8
  - **Est. Time**: 2h
  - **Blocking**: No
  - **Verification**: Tests pass on physical Android 12+ device
  - **Code Prompt**:
    ```dart
    // Create integration tests
    void main() {
      testWidgets('Health Connect integration test', (tester) async {
        final datasource = HealthConnectDatasource();
        final steps = await datasource.getStepsToday();
        expect(steps, isNotNull);
      });
    }
    ```

---

### **P1: Polish (Week 5-6)** - 21 Tasks, ~24h

#### Staged Recovery Insights (12h)

- [ ] **Task 6.1**: Define 3-Tier Unlock System Entity
  - **Layer**: Domain
  - **Files**: `lib/features/ai_coach/domain/entities/recovery_tier.dart`
  - **Dependencies**: None
  - **Est. Time**: 1h
  - **Blocking**: Yes (blocks Task 6.2, 6.3, 6.4)
  - **Verification**: Entities define basic/intermediate/advanced unlock criteria
  - **Code Prompt**:
    ```dart
    // Create recovery tier entity
    enum RecoveryTier {
      basic,        // 6 workouts, 14 days
      intermediate, // 12 workouts, 28 days
      advanced      // 20 workouts, 42 days
    }

    @freezed
    class RecoveryTierConfig with _$RecoveryTierConfig {
      factory RecoveryTierConfig({
        required RecoveryTier tier,
        required int minWorkouts,
        required int minDays,
      }) = _RecoveryTierConfig;
    }
    ```

- [ ] **Task 6.2**: Implement Basic Tier (6 workouts, 14 days)
  - **Layer**: Domain
  - **Files**: `lib/features/ai_coach/domain/usecases/evaluate_basic_tier_unlock.dart`
  - **Dependencies**: Task 6.1
  - **Est. Time**: 1h 30min
  - **Blocking**: No
  - **Verification**: Returns readiness score for 6+ workouts over 14+ days
  - **Code Prompt**:
    ```dart
    // Create basic tier use case
    class EvaluateBasicTierUnlock {
      Future<ReadinessScore> call(User user) async {
        if (user.workouts < 6 || user.days < 14) {
          return ReadinessScore.locked;
        }
        return _calculateReadinessScore(user);
      }
    }
    ```

- [ ] **Task 6.3**: Implement Intermediate Tier (12 workouts, 28 days)
  - **Layer**: Domain
  - **Files**: `lib/features/ai_coach/domain/usecases/evaluate_intermediate_tier_unlock.dart`
  - **Dependencies**: Task 6.1
  - **Est. Time**: 1h 30min
  - **Blocking**: No
  - **Verification**: Returns muscle-specific recovery data for 12+ workouts
  - **Code Prompt**:
    ```dart
    // Create intermediate tier use case
    class EvaluateIntermediateTierUnlock {
      Future<MuscleRecoveryData> call(User user) async {
        if (user.workouts < 12 || user.days < 28) {
          return MuscleRecoveryData.locked;
        }
        return _calculateMuscleRecovery(user);
      }
    }
    ```

- [ ] **Task 6.4**: Implement Advanced Tier (20 workouts, 42 days)
  - **Layer**: Domain
  - **Files**: `lib/features/ai_coach/domain/usecases/evaluate_advanced_tier_unlock.dart`
  - **Dependencies**: Task 6.1
  - **Est. Time**: 1h 30min
  - **Blocking**: Yes (blocks Task 6.5, 6.6)
  - **Verification**: Detects overtraining via HRV baseline + TSB calculation
  - **Code Prompt**:
    ```dart
    // Create advanced tier use case
    class EvaluateAdvancedTierUnlock {
      Future<OvertrainingRisk> call(User user) async {
        if (user.workouts < 20 || user.days < 42) {
          return OvertrainingRisk.locked;
        }
        return _detectOvertraining(user);
      }
    }
    ```

- [ ] **Task 6.5**: Add HRV Baseline Calculation Logic
  - **Layer**: Domain
  - **Files**: `lib/features/ai_coach/domain/services/hrv_baseline_service.dart`
  - **Dependencies**: Task 6.4
  - **Est. Time**: 1h 30min
  - **Blocking**: No
  - **Verification**: HRV baseline computed from 20+ days of HR data
  - **Code Prompt**:
    ```dart
    // Create HRV baseline service
    class HrvBaselineService {
      double calculateBaseline(List<HrvReading> readings) {
        if (readings.length < 20) return null;
        return readings.map((r) => r.value).average;
      }
    }
    ```

- [ ] **Task 6.6**: Implement TSB (Training Stress Balance) Calculation
  - **Layer**: Domain
  - **Files**: `lib/features/ai_coach/domain/services/tsb_calculation_service.dart`
  - **Dependencies**: Task 6.4
  - **Est. Time**: 1h 30min
  - **Blocking**: No
  - **Verification**: TSB reflects acute/chronic training loads correctly
  - **Code Prompt**:
    ```dart
    // Create TSB calculation service
    class TsbCalculationService {
      double calculateTsb(List<Workout> workouts) {
        final acuteLoad = _calculate7DayLoad(workouts);
        final chronicLoad = _calculate28DayLoad(workouts);
        return acuteLoad / chronicLoad; // Ratio
      }
    }
    ```

- [ ] **Task 6.7**: Build Unlock Progress Indicators UI
  - **Layer**: Presentation
  - **Files**: `lib/features/ai_coach/presentation/widgets/tier_progress_indicator.dart`
  - **Dependencies**: Task 6.1
  - **Est. Time**: 1h 30min
  - **Blocking**: No
  - **Verification**: Visual progress shows remaining workouts/days per tier
  - **Code Prompt**:
    ```dart
    // Create progress indicator widget
    class TierProgressIndicator extends StatelessWidget {
      Widget build(context) => LinearProgressIndicator(
        value: (user.workouts / requiredWorkouts).clamp(0.0, 1.0),
        backgroundColor: context.colors.surfaceVariant,
        valueColor: AlwaysStoppedAnimation(context.colors.primary),
      );
    }
    ```

- [ ] **Task 6.8**: Create Recovery Insights Repository
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/repositories/recovery_insights_repository_impl.dart`
  - **Dependencies**: Task 6.6
  - **Est. Time**: 1h
  - **Blocking**: No
  - **Verification**: Repository aggregates tier logic + health data
  - **Code Prompt**:
    ```dart
    // Create repository
    class RecoveryInsightsRepositoryImpl implements RecoveryInsightsRepository {
      Future<RecoveryInsights> getInsights(String userId) async {
        final tier = await _determineTier(userId);
        final healthData = await _healthRepository.getData(userId);
        return _generateInsights(tier, healthData);
      }
    }
    ```

- [ ] **Task 6.9**: Add Localization Keys for Recovery Tiers
  - **Layer**: Presentation
  - **Files**: `assets/i18n/app_en.arb`, `assets/i18n/app_it.arb`
  - **Dependencies**: Task 6.7
  - **Est. Time**: 45min
  - **Blocking**: No
  - **Verification**: All tier labels present in EN/IT localizations
  - **Code Prompt**:
    ```json
    // app_en.arb
    {
      "recoveryTierBasic": "Basic Recovery Insights",
      "recoveryTierIntermediate": "Intermediate Recovery Insights",
      "recoveryTierAdvanced": "Advanced Recovery Insights"
    }
    ```

- [ ] **Task 6.10**: Create Theme-Aware Recovery Insights Colors
  - **Layer**: Presentation
  - **Files**: `lib/features/ai_coach/presentation/theme/recovery_colors.dart`
  - **Dependencies**: Task 6.8
  - **Est. Time**: 45min
  - **Blocking**: No
  - **Verification**: Colors adapt to dark/light theme via `context.colors.*`
  - **Code Prompt**:
    ```dart
    // Create theme extension
    class RecoveryColors {
      static Color ready(BuildContext context) => context.colors.success;
      static Color warning(BuildContext context) => context.colors.warning;
      static Color danger(BuildContext context) => context.colors.error;
    }
    ```

---

#### GDPR Breach Notification Plan (7h)

- [ ] **Task 7.1**: Document Breach Response Procedure
  - **Layer**: Documentation
  - **Files**: `docs/GDPR_BREACH_RESPONSE.md`
  - **Dependencies**: None
  - **Est. Time**: 2h
  - **Blocking**: Yes (blocks Task 7.2, 7.3, 7.4)
  - **Verification**: Document covers 72h Article 33 requirement per regulation
  - **Code Prompt**:
    ```markdown
    # GDPR Breach Response Procedure

    ## Timeline (Article 33)
    - Hour 1: Incident detected (Sentry alert)
    - Hour 6: Breach assessed (severity, affected users)
    - Hour 24: Internal team notified
    - Hour 48: Legal counsel consulted
    - Hour 72: Users notified via email + in-app
    ```

- [ ] **Task 7.2**: Setup Sentry Monitoring for Security Events
  - **Layer**: Infrastructure
  - **Files**: `lib/core/monitoring/sentry_setup.dart`
  - **Dependencies**: Task 7.1
  - **Est. Time**: 1h 30min
  - **Blocking**: No
  - **Verification**: Sentry initialized, security events tagged + sampled
  - **Code Prompt**:
    ```dart
    // Configure Sentry
    await SentryFlutter.init((options) {
      options.dsn = 'YOUR_DSN';
      options.tracesSampleRate = 1.0;
      options.beforeSend = (event, hint) {
        if (event.tags?['type'] == 'security') {
          // Tag security events for immediate alert
          event.level = SentryLevel.fatal;
        }
        return event;
      };
    });
    ```

- [ ] **Task 7.3**: Create Breach Notification Email Template
  - **Layer**: Infrastructure
  - **Files**: `templates/breach_notification_email.html`
  - **Dependencies**: Task 7.1
  - **Est. Time**: 1h
  - **Blocking**: No
  - **Verification**: Template includes breach details, user rights, mitigation steps
  - **Code Prompt**:
    ```html
    <!-- Email template -->
    <html>
      <body>
        <h1>Important Security Notice</h1>
        <p>Dear {{user_name}},</p>
        <p>We are writing to inform you of a security incident...</p>
        <h2>Your Rights (GDPR Article 33)</h2>
        <ul>
          <li>Right to withdraw consent</li>
          <li>Right to erasure</li>
          <li>Right to compensation</li>
        </ul>
      </body>
    </html>
    ```

- [ ] **Task 7.4**: Train Team on Breach Response Procedure
  - **Layer**: Documentation
  - **Files**: `docs/BREACH_RESPONSE_TRAINING.md`
  - **Dependencies**: Task 7.1
  - **Est. Time**: 1h 30min
  - **Blocking**: No
  - **Verification**: Team acknowledgment documented, training completed
  - **Code Prompt**:
    ```markdown
    # Breach Response Training

    ## Attendees
    - [ ] Michele (CTO)
    - [ ] Developer 1
    - [ ] Developer 2

    ## Topics Covered
    1. Detection and assessment (Hour 1-6)
    2. Internal notification (Hour 24)
    3. User notification (Hour 72)
    ```

- [ ] **Task 7.5**: Add Breach Response Drill to Annual Calendar
  - **Layer**: Documentation
  - **Files**: `docs/ANNUAL_SECURITY_CALENDAR.md`
  - **Dependencies**: Task 7.1
  - **Est. Time**: 1h
  - **Blocking**: No
  - **Verification**: Drill scheduled quarterly with escalation paths
  - **Code Prompt**:
    ```markdown
    # Annual Security Calendar

    ## Q1 2025
    - [ ] January 15: Breach response drill #1

    ## Q2 2025
    - [ ] April 15: Breach response drill #2
    ```

---

#### Workout vs Health Data Separation (6h)

- [ ] **Task 8.1**: Implement Two-Step Consent Flow UI
  - **Layer**: Presentation
  - **Files**: `lib/features/ai_coach/presentation/pages/consent_flow_page.dart`
  - **Dependencies**: None
  - **Est. Time**: 1h 30min
  - **Blocking**: Yes (blocks Task 8.2, 8.3)
  - **Verification**: Step 1 (workout) and Step 2 (health) presented separately
  - **Code Prompt**:
    ```dart
    // Create two-step consent flow
    class ConsentFlowPage extends StatefulWidget {
      Widget build(context) => PageView(
        children: [
          WorkoutConsentStep(),  // Step 1 (NOT Article 9)
          HealthDataConsentStep(), // Step 2 (Article 9)
        ],
      );
    }
    ```

- [ ] **Task 8.2**: Create Workout Consent (Sets/Reps - NOT Article 9)
  - **Layer**: Presentation
  - **Files**: `lib/features/ai_coach/presentation/dialogs/workout_consent_dialog.dart`
  - **Dependencies**: Task 8.1
  - **Est. Time**: 1h
  - **Blocking**: No
  - **Verification**: Consent dialog excludes biometric data claims
  - **Code Prompt**:
    ```dart
    // Create workout consent dialog
    class WorkoutConsentDialog extends StatelessWidget {
      Widget build(context) => AlertDialog(
        title: Text(context.l10n.workoutConsentTitle),
        content: Text(context.l10n.workoutConsentDescription),
        actions: [
          TextButton(context.l10n.decline, onPressed: ...),
          TextButton(context.l10n.agree, onPressed: ...),
        ],
      );
    }
    ```

- [ ] **Task 8.3**: Create Health Data Consent (HR/HRV/Sleep - Article 9)
  - **Layer**: Presentation
  - **Files**: `lib/features/ai_coach/presentation/dialogs/health_data_consent_dialog.dart`
  - **Dependencies**: Task 8.1
  - **Est. Time**: 1h
  - **Blocking**: Yes (blocks Task 8.5)
  - **Verification**: Dialog explains Article 9 biometric processing requirements
  - **Code Prompt**:
    ```dart
    // Create health data consent dialog
    class HealthDataConsentDialog extends StatelessWidget {
      Widget build(context) => AlertDialog(
        title: Text('🔒 ${context.l10n.healthDataConsentTitle}'),
        content: Column(children: [
          Text(context.l10n.gdprArticle9Notice),
          Checkbox(...), // Granular opt-in
        ]),
      );
    }
    ```

- [ ] **Task 8.4**: Update Privacy Policy with Data Type Distinction
  - **Layer**: Documentation
  - **Files**: `docs/PRIVACY_POLICY.md`
  - **Dependencies**: Task 8.2, Task 8.3
  - **Est. Time**: 1h
  - **Blocking**: No
  - **Verification**: Policy clearly separates workout vs health data legal bases
  - **Code Prompt**:
    ```markdown
    # Privacy Policy Update

    ## Data We Collect

    ### Workout Data (NOT Article 9)
    - Sets, reps, weight lifted
    - Legal basis: Contract performance (GDPR Article 6.1.b)

    ### Health Data (Article 9)
    - Heart rate, HRV, sleep duration
    - Legal basis: Explicit consent (GDPR Article 9.2.a)
    ```

- [ ] **Task 8.5**: Add Granular Opt-In/Opt-Out Toggles in Settings
  - **Layer**: Presentation
  - **Files**: `lib/features/ai_coach/presentation/pages/privacy_settings_page.dart`
  - **Dependencies**: Task 8.3
  - **Est. Time**: 1h
  - **Blocking**: Yes (blocks Task 8.6)
  - **Verification**: Users can independently toggle workout + health data permissions
  - **Code Prompt**:
    ```dart
    // Create privacy settings page
    class PrivacySettingsPage extends StatelessWidget {
      Widget build(context) => ListView(children: [
        SwitchListTile(
          title: Text(context.l10n.workoutDataTracking),
          value: workoutTrackingEnabled,
          onChanged: (value) => ...,
        ),
        SwitchListTile(
          title: Text(context.l10n.healthDataSync),
          value: healthDataSyncEnabled,
          onChanged: (value) => ...,
        ),
      ]);
    }
    ```

- [ ] **Task 8.6**: Create Consent Preference Repository
  - **Layer**: Data
  - **Files**: `lib/features/ai_coach/data/repositories/consent_preferences_repository_impl.dart`
  - **Dependencies**: Task 8.5
  - **Est. Time**: 1h
  - **Blocking**: No
  - **Verification**: Preferences persisted to Firestore + Hive, honored on app startup
  - **Code Prompt**:
    ```dart
    // Create consent preferences repository
    class ConsentPreferencesRepositoryImpl implements ConsentPreferencesRepository {
      Future<void> savePreferences(ConsentPreferences prefs) async {
        await _firestore.collection('users').doc(userId).set({
          'consents': {
            'workoutTracking': prefs.workoutTracking,
            'healthDataSync': prefs.healthDataSync,
            'timestamp': DateTime.now().toIso8601String(),
          }
        }, SetOptions(merge: true));

        await _hive.put('consents', prefs); // Offline cache
      }
    }
    ```

---

## 📊 Implementation Order

**MUST DO FIRST** (blocking tasks):
→ Task 1.1, 1.2 (Firebase optimization foundation) - ~2h
→ Task 3.1 (Unlock requirement change) - ~30min
→ Task 4.1, 4.2 (HealthKit setup) - ~1h 15min
→ Task 5.1, 5.2 (Health Connect setup) - ~1h 15min

**THEN** (parallel workable):
→ Tasks 1.3, 1.4 (Cache integration) - ~2h
→ Tasks 2.1-2.4 (Polling strategy) - ~6h
→ Tasks 3.2-3.4 (Unlock logic + UI) - ~2h
→ Tasks 4.3-4.10 (HealthKit integration) - ~15h
→ Tasks 5.3-5.10 (Health Connect integration) - ~15h

**FINALLY**:
→ Tasks 6.1-6.10 (Recovery insights) - ~12h
→ Tasks 7.1-7.5 (GDPR breach plan) - ~7h
→ Tasks 8.1-8.6 (Consent separation) - ~6h

**Total Critical Path**: ~76h (~9.5 days at 8h/day)

---

## 🔄 Milestone Retrospective Template

### When Complete

After completing this plan, fill out:

**What Went Well**:
- [ ] Tasks completed faster than estimated
- [ ] No major blockers encountered
- [ ] Good test coverage achieved

**What Could Be Improved**:
- [ ] Estimation accuracy (over/under)
- [ ] Dependency management
- [ ] Communication issues

**Carry Forward to Next Milestone**:
- [ ] Patterns that worked
- [ ] Code reuse opportunities
- [ ] Testing strategies

**Time Tracking**:
| Category | Estimated | Actual | Variance |
|----------|-----------|--------|----------|
| P0 Quick Wins | 12h | - | - |
| P1 Strategic | 40h | - | - |
| P1 Polish | 24h | - | - |
| **Total** | **76h** | - | - |

**Learnings for LEARNINGS.md**:
- [ ] Firebase optimization patterns
- [ ] Health integration gotchas
- [ ] GDPR compliance best practices
- [ ] Estimation adjustments needed

---

## 📝 Notes & Decisions

**Architectural Decisions**:
- Using single document + map for Firebase feature gates (vs subcollections)
- Polling with 6h TTL instead of real-time streams
- Separate consent flows for workout vs health data (GDPR Article 9)

**Dependencies**:
- health ^9.0.0 (HealthKit - iOS)
- health_connect ^1.0.0 (Android)
- Sentry for breach monitoring

**Testing Strategy**:
- Unit tests for domain logic (unlock criteria, recovery tiers, TSB)
- Integration tests for repositories (Firebase, cache, health data)
- Physical device testing required (HealthKit/Health Connect)
- Manual testing for GDPR consent flows

**Risks & Mitigations**:
- ⚠️ HealthKit/Health Connect simulators don't support health data → Require physical devices
- ⚠️ GDPR Article 9 compliance requires legal review → Schedule consultation
- ⚠️ Firebase costs may increase with scale → Monitor usage, implement rate limiting

---

## ✅ Verification Checklist (Post-Implementation)

- [ ] All 53 tasks completed
- [ ] `flutter analyze` passes (0 errors)
- [ ] `flutter test` passes (all tests green)
- [ ] Physical device testing completed (iOS + Android)
- [ ] Firebase costs confirmed within free tier
- [ ] GDPR compliance verified (Articles 9, 17, 20, 32, 33)
- [ ] Localization complete (EN + IT)
- [ ] Theme compliance verified (dark + light)
- [ ] Performance benchmarks met:
  - [ ] App start latency < 0.2s
  - [ ] Cache hit rate > 90%
  - [ ] Firebase reads < 50K/day (free tier)
- [ ] Analytics tracking verified:
  - [ ] Unlock attempts logged
  - [ ] Feature usage tracked
  - [ ] D7/D30 retention monitored
- [ ] Documentation updated:
  - [ ] INDEX.md references this plan
  - [ ] CLAUDE.md updated with new patterns
  - [ ] Privacy policy reflects data separation
