/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/providers
/// 🎯 Feature: analytics
/// 🔧 Type: provider
///
/// Riverpod providers for analytics service
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/services/analytics/firebase_analytics_service.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';
import 'package:gymbro_flutter_new/core/services/analytics/mock_analytics_service.dart';

/// Analytics service provider
///
/// Provides the appropriate analytics service based on build mode:
/// - **Release mode**: FirebaseAnalyticsService (sends data to Firebase)
/// - **Debug mode**: MockAnalyticsService (logs to console only)
///
/// The service is automatically initialized in the background.
///
/// Usage:
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final analytics = ref.read(analyticsServiceProvider);
///
///     return ElevatedButton(
///       onPressed: () async {
///         await analytics.logEvent(
///           name: 'button_clicked',
///           parameters: {'screen': 'MyWidget'},
///         );
///       },
///       child: Text('Track Event'),
///     );
///   }
/// }
/// ```
final analyticsServiceProvider = Provider<IAnalyticsService>((ref) {
  // Create appropriate service based on build mode
  final service = kDebugMode
      ? MockAnalyticsService()
      : FirebaseAnalyticsService();

  // Initialize in background
  service.initialize().catchError((error) {
    if (kDebugMode) {
      debugPrint('❌ Error initializing analytics service: $error');
    }
  });

  // Cleanup on dispose
  ref.onDispose(() {
    if (kDebugMode) {
      debugPrint('🔥 Analytics service disposed');
    }
  });

  return service;
});

/// Analytics service async provider
///
/// FutureProvider variant that guarantees the service is initialized
/// before returning. Use this when you need to ensure initialization
/// is complete before proceeding.
///
/// Usage:
/// ```dart
/// final analyticsAsync = ref.watch(analyticsServiceAsyncProvider);
///
/// analyticsAsync.when(
///   data: (analytics) {
///     // Service is ready
///     analytics.logEvent(name: 'screen_view');
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final analyticsServiceAsyncProvider = FutureProvider<IAnalyticsService>((ref) async {
  final service = ref.read(analyticsServiceProvider);
  await service.initialize();
  return service;
});

/// Analytics initialization state provider
///
/// Tracks whether the analytics service has been initialized.
/// Useful for showing loading states or preventing early tracking calls.
///
/// Usage:
/// ```dart
/// final isInitialized = ref.watch(isAnalyticsInitializedProvider);
///
/// if (isInitialized) {
///   // Safe to track events
/// } else {
///   // Show loading or wait
/// }
/// ```
final isAnalyticsInitializedProvider = StateProvider<bool>((ref) => false);

/// Helper to initialize analytics and update state
///
/// Call this early in app startup (e.g., in main.dart).
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   final container = ProviderContainer();
///   await initializeAnalytics(container);
///
///   runApp(
///     UncontrolledProviderScope(
///       container: container,
///       child: MyApp(),
///     ),
///   );
/// }
/// ```
Future<void> initializeAnalytics(ProviderContainer container) async {
  try {
    final analytics = container.read(analyticsServiceProvider);
    await analytics.initialize();

    container.read(isAnalyticsInitializedProvider.notifier).state = true;

    if (kDebugMode) {
      debugPrint('✅ Analytics initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Error initializing analytics: $e');
    }
    rethrow;
  }
}
