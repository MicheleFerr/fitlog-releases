import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Base class for all patrol tests with common setup and utilities
class TestBase {
  /// Mock Firestore instance for testing
  static late FakeFirebaseFirestore mockFirestore;
  
  /// Test user credentials
  static const testEmail = 'test@gymbro.com';
  static const testPassword = 'Test123!';
  static const testUserId = 'test_user_123';
  
  /// Initialize test environment
  static Future<void> setupTestEnvironment() async {
    // Initialize mock Firestore
    mockFirestore = FakeFirebaseFirestore();
    
    // Setup test data
    await _setupTestData();
  }
  
  /// Setup initial test data in Firestore
  static Future<void> _setupTestData() async {
    // Add test user document
    await mockFirestore.collection('users').doc(testUserId).set({
      'email': testEmail,
      'displayName': 'Test User',
      'createdAt': DateTime.now().toIso8601String(),
      'preferences': {
        'theme': 'light',
        'language': 'en',
        'restTimerSound': 'timer_complete.wav',
      },
    });
    
    // Add sample workout templates
    await mockFirestore.collection('workoutTemplates').add({
      'name': 'Push Day',
      'userId': testUserId,
      'exercises': [
        {
          'name': 'Bench Press',
          'sets': 4,
          'targetReps': 8,
          'restTime': 180,
        },
        {
          'name': 'Shoulder Press',
          'sets': 3,
          'targetReps': 10,
          'restTime': 120,
        },
      ],
    });
  }
  
  /// Login test user
  static Future<void> loginTestUser(PatrolIntegrationTester $) async {
    // Navigate to login screen
    await $.tap(find.byKey(const Key('login_button')));
    
    // Enter credentials
    await $.enterText(find.byKey(const Key('email_field')), testEmail);
    await $.enterText(find.byKey(const Key('password_field')), testPassword);
    
    // Submit login
    await $.tap(find.byKey(const Key('submit_login')));
    
    // Wait for navigation
    await $.pumpAndSettle();
  }
  
  /// Logout current user
  static Future<void> logoutUser(PatrolIntegrationTester $) async {
    // Navigate to settings
    await $.tap(find.byKey(const Key('settings_tab')));
    
    // Tap logout
    await $.tap(find.byKey(const Key('logout_button')));
    
    // Confirm logout
    await $.tap(find.text('Logout'));
    
    await $.pumpAndSettle();
  }
  
  /// Create a test workout
  static Future<void> createTestWorkout(
    PatrolIntegrationTester $, {
    String name = 'Test Workout',
  }) async {
    // Navigate to workouts
    await $.tap(find.byKey(const Key('workouts_tab')));
    
    // Create new workout
    await $.tap(find.byKey(const Key('create_workout_button')));
    
    // Enter workout name
    await $.enterText(find.byKey(const Key('workout_name_field')), name);
    
    // Add exercise
    await $.tap(find.byKey(const Key('add_exercise_button')));
    await $.enterText(find.byKey(const Key('exercise_search')), 'Bench Press');
    await $.tap(find.text('Bench Press').first);
    
    // Save workout
    await $.tap(find.byKey(const Key('save_workout_button')));
    
    await $.pumpAndSettle();
  }
  
  /// Start a workout session
  static Future<void> startWorkout(PatrolIntegrationTester $) async {
    // Tap start workout
    await $.tap(find.byKey(const Key('start_workout_button')));
    
    // Wait for workout to start
    await $.pumpAndSettle();
  }
  
  /// Complete a set with given weight and reps
  static Future<void> completeSet(
    PatrolIntegrationTester $, {
    double weight = 100,
    int reps = 10,
  }) async {
    // Enter weight
    await $.enterText(
      find.byKey(const Key('weight_input')).first,
      weight.toString(),
    );
    
    // Enter reps
    await $.enterText(
      find.byKey(const Key('reps_input')).first,
      reps.toString(),
    );
    
    // Mark set as complete
    await $.tap(find.byKey(const Key('complete_set_button')).first);
    
    await $.pumpAndSettle();
  }
  
  /// Wait for timer to reach specific time
  static Future<void> waitForTimer(
    PatrolIntegrationTester $, {
    required Duration duration,
  }) async {
    await Future.delayed(duration);
    await $.pumpAndSettle();
  }
  
  /// Verify timer is running
  static Future<bool> isTimerRunning(PatrolIntegrationTester $) async {
    final timerDisplay = find.byKey(const Key('timer_display'));
    return timerDisplay.evaluate().isNotEmpty;
  }
  
  /// Put app in background (iOS/Android)
  static Future<void> putAppInBackground(PatrolIntegrationTester $) async {
    await $.native.pressHome();
  }
  
  /// Bring app to foreground
  static Future<void> bringAppToForeground(PatrolIntegrationTester $) async {
    await $.native.openApp();
  }
  
  /// Check if Live Activity is visible (iOS only)
  /// NOTE: Temporarily disabled - Patrol 3.x API changed
  static Future<bool> isLiveActivityVisible(PatrolIntegrationTester $) async {
    // TODO: Update to Patrol 3.x API
    // if (await $.native.isIOS()) {
    //   return await $.native.isPermissionGranted(Permission.notification);
    // }
    return false;
  }

  /// Grant permission when requested
  /// NOTE: Temporarily disabled - Patrol 3.x API changed
  static Future<void> grantPermission(
    PatrolIntegrationTester $,
    String permissionName,
  ) async {
    // TODO: Update to Patrol 3.x API
    // await $.native.grantPermissionWhenRequested(permission);
  }
  
  /// Clean up after tests
  static Future<void> cleanup() async {
    // Clear Firestore data
    await mockFirestore.clearPersistence();
  }
}

/// Test data fixtures
class TestFixtures {
  static const sampleExercises = [
    {'name': 'Bench Press', 'category': 'Chest'},
    {'name': 'Squat', 'category': 'Legs'},
    {'name': 'Deadlift', 'category': 'Back'},
    {'name': 'Shoulder Press', 'category': 'Shoulders'},
    {'name': 'Barbell Row', 'category': 'Back'},
  ];
  
  static const sampleWorkout = {
    'name': 'Full Body Workout',
    'exercises': [
      {
        'name': 'Squat',
        'sets': [
          {'weight': 135, 'reps': 10},
          {'weight': 185, 'reps': 8},
          {'weight': 225, 'reps': 6},
        ],
      },
      {
        'name': 'Bench Press',
        'sets': [
          {'weight': 135, 'reps': 10},
          {'weight': 155, 'reps': 8},
          {'weight': 175, 'reps': 6},
        ],
      },
    ],
  };
}