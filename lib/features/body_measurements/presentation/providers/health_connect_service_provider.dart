import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/services/health_connect_service.dart';

/// Provider for HealthConnectService
///
/// Provides singleton instance of HealthConnectService for Android Health Connect integration.
///
/// **Platform**: Android only (Android 14+ or Android 7+ with Google Play Services)
/// **Usage**: Health data sync (bi-directional)
/// **GDPR**: Consent-driven (only syncs consented metrics)
///
/// **Installation Check**:
/// Health Connect must be installed (separate app on Android 7-13):
/// - Check availability with `isAvailable()`
/// - Prompt user to install from Play Store if missing
///
/// **Usage in Presentation Layer**:
/// ```dart
/// class SyncButton extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final healthConnectService = ref.read(healthConnectServiceProvider);
///
///     return ElevatedButton(
///       onPressed: () async {
///         // Check if Health Connect available
///         final available = await healthConnectService.isAvailable();
///         if (!available) {
///           showError('Health Connect not installed. Please install from Play Store.');
///           return;
///         }
///
///         // Request permissions
///         final granted = await healthConnectService.requestPermissions([
///           MetricType.weight,
///           MetricType.bodyFatPercentage,
///         ]);
///
///         granted.fold(
///           (failure) => showError(failure.message),
///           (success) {
///             if (success) {
///               // Start sync
///               syncWithHealthConnect();
///             }
///           },
///         );
///       },
///       child: Text('Sync with Health Connect'),
///     );
///   }
/// }
/// ```
final healthConnectServiceProvider = Provider<HealthConnectService>((ref) {
  return HealthConnectService();
});
