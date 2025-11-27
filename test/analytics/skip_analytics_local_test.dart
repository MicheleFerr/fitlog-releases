import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/skip_analytics_local_repository.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

// Mock Firebase implementation for tests
void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Provide a mock Firebase platform implementation
  FirebasePlatform.instance = MockFirebasePlatform();
}

class MockFirebasePlatform extends FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseAppPlatform(name, const FirebaseOptions(
      apiKey: 'test',
      appId: 'test',
      messagingSenderId: 'test',
      projectId: 'test',
    ));
  }
  
  @override
  List<FirebaseAppPlatform> get apps => [app()];
  
  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return app(name ?? defaultFirebaseAppName);
  }
}

class MockFirebaseAppPlatform extends FirebaseAppPlatform {
  MockFirebaseAppPlatform(super.name, super.options);
  
  @override
  bool get isAutomaticDataCollectionEnabled => false;
  
  @override
  Stream<bool> get onAutomaticDataCollectionEnabledChanged => Stream.value(false);
  
  @override
  Future<void> delete() async {}
  
  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}
  
  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}
}

void main() {
  group('SkipAnalyticsLocalRepository', () {
    late SkipAnalyticsLocalRepository repository;

    setUpAll(() async {
      // Setup Firebase mock
      setupFirebaseCoreMocks();
      await Firebase.initializeApp();

      // Initialize Hive for testing
      Hive.init('./test/hive_test');

      // Initialize HiveBoxManagerEnhanced
      await HiveBoxManagerEnhanced.initialize();
    });

    setUp(() async {
      repository = SkipAnalyticsLocalRepository();
      await repository.init();
    });

    tearDown(() async {
      // Clean up after each test
      await repository.clearLocalData();
      await Hive.deleteFromDisk();
    });

    test('should save skip locally and update analytics', () async {
      // Act
      await repository.saveSkipLocally(
        exerciseName: 'Bench Press',
        reason: 'equipment_busy',
        timestamp: DateTime.now(),
      );

      // Assert
      final insights = repository.getLocalInsights();
      expect(insights['totalSkips'], 1);
      expect(insights['mostCommonReason'], 'equipment_busy');
      expect(insights['mostSkippedExercise'], 'Bench Press');
      expect(insights['pendingSync'], 1);
    });

    test('should aggregate multiple skips correctly', () async {
      // Act - Add multiple skips
      await repository.saveSkipLocally(
        exerciseName: 'Bench Press',
        reason: 'equipment_busy',
        timestamp: DateTime.now(),
      );
      
      await repository.saveSkipLocally(
        exerciseName: 'Squat',
        reason: 'too_tired',
        timestamp: DateTime.now(),
      );
      
      await repository.saveSkipLocally(
        exerciseName: 'Bench Press',
        reason: 'equipment_busy',
        timestamp: DateTime.now(),
      );

      // Assert
      final analytics = repository.getLocalAnalytics();
      expect(analytics['totalSkips'], 3);
      expect(analytics['reasonCounts']['equipment_busy'], 2);
      expect(analytics['reasonCounts']['too_tired'], 1);
      expect(analytics['exerciseCounts']['Bench Press'], 2);
      expect(analytics['exerciseCounts']['Squat'], 1);
    });

    test('should track time-based patterns', () async {
      // Arrange
      final morningTime = DateTime(2024, 1, 1, 9, 0); // 9 AM
      final eveningTime = DateTime(2024, 1, 1, 18, 0); // 6 PM

      // Act
      await repository.saveSkipLocally(
        exerciseName: 'Bench Press',
        reason: 'equipment_busy',
        timestamp: morningTime,
      );
      
      await repository.saveSkipLocally(
        exerciseName: 'Squat',
        reason: 'equipment_busy',
        timestamp: eveningTime,
      );

      // Assert
      final analytics = repository.getLocalAnalytics();
      expect(analytics['hourlyPatterns']['9']['equipment_busy'], 1);
      expect(analytics['hourlyPatterns']['18']['equipment_busy'], 1);
    });

    test('should identify peak skip hour correctly', () async {
      // Arrange - Add more skips at 6 PM
      final time6pm = DateTime(2024, 1, 1, 18, 0);
      final time9am = DateTime(2024, 1, 1, 9, 0);

      // Act
      for (int i = 0; i < 3; i++) {
        await repository.saveSkipLocally(
          exerciseName: 'Exercise $i',
          reason: 'equipment_busy',
          timestamp: time6pm,
        );
      }
      
      await repository.saveSkipLocally(
        exerciseName: 'Morning Exercise',
        reason: 'too_tired',
        timestamp: time9am,
      );

      // Assert
      final insights = repository.getLocalInsights();
      expect(insights['peakHour'], 18); // 6 PM should be peak hour
    });

    test('should not sync before threshold', () async {
      // Act - Add fewer skips than threshold
      for (int i = 0; i < 5; i++) {
        await repository.saveSkipLocally(
          exerciseName: 'Exercise $i',
          reason: 'too_tired',
          timestamp: DateTime.now(),
        );
      }

      // Assert
      final insights = repository.getLocalInsights();
      expect(insights['pendingSync'], 5);
      // Should not have synced yet (threshold is 10)
    });
  });
}