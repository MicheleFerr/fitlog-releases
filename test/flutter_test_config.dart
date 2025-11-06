import 'dart:async';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

/// Global test configuration for leak tracking
///
/// This file is automatically picked up by `flutter test` and runs before all tests.
///
/// ✅ Enables memory leak detection for ALL tests
/// ✅ Automatically tears down leak tracking (handled by framework)
/// ✅ Configured to ignore leak from test helpers
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Enable leak tracking globally
  LeakTesting.enable();

  // Configure leak tracking settings
  LeakTesting.settings = LeakTesting.settings.withIgnored(
    // Ignore leaks created by test helper classes
    createdByTestHelpers: true,
  );

  // Run all tests - teardown is handled automatically by the framework
  await testMain();
}
