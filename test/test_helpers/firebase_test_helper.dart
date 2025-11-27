import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

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

/// Setup test environment with Firebase and Hive
Future<void> setupTestEnvironment() async {
  setupFirebaseCoreMocks();
  await Firebase.initializeApp();
  await Hive.initFlutter('./test/hive_test');
  await HiveBoxManagerEnhanced.initialize();
}

/// Enhanced Firebase test environment setup
Future<void> setupEnhancedTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase already initialized, continue
  }

  // Initialize Hive for local storage tests
  try {
    await Hive.initFlutter('./test/hive_test');
  } catch (e) {
    // Hive already initialized, continue
  }

  // Initialize HiveBoxManagerEnhanced
  try {
    await HiveBoxManagerEnhanced.initialize();
  } catch (e) {
    // Already initialized, continue
  }
}

/// Clean up test environment
Future<void> cleanupTestEnvironment() async {
  try {
    await Hive.close();
  } catch (e) {
    // Ignore cleanup errors
  }
}