import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/services/health_kit_service.dart';

/// Provider for HealthKitService
///
/// Provides singleton instance of HealthKitService for iOS HealthKit integration.
///
/// **Platform**: iOS only
/// **Usage**: Health data sync (bi-directional)
/// **GDPR**: Consent-driven (only syncs consented metrics)
///
/// **Usage in Presentation Layer**:
/// ```dart
/// class SyncButton extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final healthKitService = ref.read(healthKitServiceProvider);
///
///     return ElevatedButton(
///       onPressed: () async {
///         // Check if HealthKit available
///         final available = await healthKitService.isAvailable();
///         if (!available) {
///           showError('HealthKit not available');
///           return;
///         }
///
///         // Request permissions
///         final granted = await healthKitService.requestPermissions([
///           MetricType.weight,
///           MetricType.bodyFatPercentage,
///         ]);
///
///         granted.fold(
///           (failure) => showError(failure.message),
///           (success) {
///             if (success) {
///               // Start sync
///               syncWithHealthKit();
///             }
///           },
///         );
///       },
///       child: Text('Sync with HealthKit'),
///     );
///   }
/// }
/// ```
final healthKitServiceProvider = Provider<HealthKitService>((ref) {
  return HealthKitService();
});
