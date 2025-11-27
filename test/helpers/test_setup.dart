import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/services.dart';

// Mock classes
class MockBox<T> extends Mock implements Box<T> {}
class MockHiveInterface extends Mock implements HiveInterface {}

/// Initialize test environment
Future<void> initializeTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for testing
  Hive.init('./test_hive');

  // Initialize HiveBoxManagerEnhanced
  await HiveBoxManagerEnhanced.initialize();

  // Mock platform channels
  _mockPlatformChannels();
}

/// Mock platform channels to prevent errors in tests
void _mockPlatformChannels() {
  // Mock lifecycle channel
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('flutter/lifecycle'),
    (methodCall) async {
      return null;
    },
  );
  
  // Mock timer audio channel
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.gymbro.timer/audio'),
    (methodCall) async {
      return null;
    },
  );
  
  // Mock audio session channel
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.gymbro.audio/session'),
    (methodCall) async {
      return null;
    },
  );
  
  // Mock live activity channel
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.gymbro.liveactivity'),
    (methodCall) async {
      switch (methodCall.method) {
        case 'startLiveActivity':
          return 'test-activity-id';
        case 'updateLiveActivity':
        case 'endLiveActivity':
          return true;
        default:
          return null;
      }
    },
  );
  
  // Mock local notifications
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dexterous.com/flutter/local_notifications'),
    (methodCall) async {
      return null;
    },
  );
}

/// Clean up test environment
Future<void> cleanupTestEnvironment() async {
  // Clean up Hive
  await Hive.deleteFromDisk();
}

/// Create a mock Box for testing
MockBox<T> createMockBox<T>() {
  final mockBox = MockBox<T>();
  
  // Setup default behaviors
  when(() => mockBox.isOpen).thenReturn(true);
  when(() => mockBox.isEmpty).thenReturn(true);
  when(() => mockBox.length).thenReturn(0);
  when(() => mockBox.keys).thenReturn([]);
  when(() => mockBox.values).thenReturn([]);
  
  // Setup CRUD operations
  when(() => mockBox.get(any())).thenReturn(null);
  when(() => mockBox.put(any(), any())).thenAnswer((_) async => Future.value());
  when(() => mockBox.delete(any())).thenAnswer((_) async => Future.value());
  when(() => mockBox.clear()).thenAnswer((_) async => 0);
  when(() => mockBox.close()).thenAnswer((_) async => Future.value());
  
  return mockBox;
}