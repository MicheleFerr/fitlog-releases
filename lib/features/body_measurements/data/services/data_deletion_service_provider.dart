import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/presentation/providers/measurement_local_datasource_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/services/audit_logger_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/services/data_deletion_service.dart';

/// Provider for DataDeletionService
///
/// Provides singleton instance of DataDeletionService for GDPR data erasure.
///
/// **GDPR CRITICAL**: Article 17 - Right to Erasure
///
/// **Usage**:
/// - Soft-delete measurements (30-day retention)
/// - Permanently delete all user data
/// - Purge soft-deleted data after retention period
/// - Logs deletion actions to audit trail
///
/// **Usage in Presentation Layer**:
/// ```dart
/// class DeleteDataButton extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final deletionService = ref.read(dataDeletionServiceProvider);
///
///     return ElevatedButton(
///       onPressed: () async {
///         // Soft-delete weight measurements
///         final result = await deletionService.softDeleteMeasurements(
///           userId: currentUser.uid,
///           metricType: MetricType.weight,
///         );
///
///         result.fold(
///           (failure) => showError(failure.message),
///           (deletionResult) {
///             showSuccess(
///               'Deleted ${deletionResult.deletedCount} measurements. '
///               'Data will be permanently deleted on ${deletionResult.retentionEndsAt}',
///             );
///           },
///         );
///       },
///       child: Text('Delete Weight Data'),
///     );
///   }
/// }
/// ```
final dataDeletionServiceProvider = Provider<DataDeletionService>((ref) {
  return DataDeletionService(
    measurementRepo: ref.read(measurementRepositoryProvider),
    localDatasource: ref.read(measurementLocalDatasourceProvider),
    consentRepo: ref.read(consentRepositoryProvider),
    auditLogger: ref.read(auditLoggerProvider),
  );
});
