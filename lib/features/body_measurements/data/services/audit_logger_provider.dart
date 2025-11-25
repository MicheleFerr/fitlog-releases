import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/services/audit_logger_service.dart';

/// Provider for AuditLoggerService
///
/// Provides singleton instance of AuditLoggerService for GDPR audit trail.
///
/// **GDPR CRITICAL**: Article 30 - Records of processing activities
///
/// **Usage**:
/// - Log all data processing activities (consent changes, data access, deletions)
/// - Verify audit log integrity (detect tampering)
/// - Provide audit trail to data protection authorities on request
///
/// **Usage in Presentation Layer**:
/// ```dart
/// class DataExportButton extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final auditLogger = ref.read(auditLoggerProvider);
///
///     return ElevatedButton(
///       onPressed: () async {
///         // Export data
///         await exportUserData();
///
///         // Log action for GDPR compliance
///         await auditLogger.logAction(
///           userId: currentUser.uid,
///           action: AuditAction.dataExport,
///           affectedMetrics: null, // All metrics
///           actionDetails: 'Exported 150 measurements to JSON',
///         );
///       },
///       child: Text('Export Data'),
///     );
///   }
/// }
/// ```
///
/// **Usage in Data Layer** (Repository):
/// ```dart
/// class MeasurementRepositoryImpl implements MeasurementRepository {
///   final AuditLoggerService _auditLogger;
///
///   @override
///   Future<Either<MeasurementFailure, void>> deleteMeasurement({
///     required String userId,
///     required String measurementId,
///   }) async {
///     // Delete measurement
///     final result = await _localDatasource.deleteMeasurement(...);
///
///     // Log deletion for GDPR compliance
///     await _auditLogger.logAction(
///       userId: userId,
///       action: AuditAction.dataDelete,
///       affectedMetrics: [measurement.metricType],
///       actionDetails: 'Deleted measurement $measurementId',
///     );
///
///     return result;
///   }
/// }
/// ```
final auditLoggerProvider = Provider<AuditLoggerService>((ref) {
  return AuditLoggerService();
});
