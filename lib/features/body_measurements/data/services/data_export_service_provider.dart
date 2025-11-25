import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/services/audit_logger_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/services/data_export_service.dart';

/// Provider for DataExportService
///
/// Provides singleton instance of DataExportService for GDPR data portability.
///
/// **GDPR CRITICAL**: Article 20 - Right to Data Portability
///
/// **Usage**:
/// - Export all user data in machine-readable JSON format
/// - Respects consent boundaries (only exports consented data)
/// - Logs export action to audit trail
///
/// **Usage in Presentation Layer**:
/// ```dart
/// class ExportDataButton extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final exportService = ref.read(dataExportServiceProvider);
///
///     return ElevatedButton(
///       onPressed: () async {
///         // Export all user data
///         final result = await exportService.exportUserData(
///           userId: currentUser.uid,
///         );
///
///         result.fold(
///           (failure) => showError(failure.message),
///           (exportData) {
///             // Save to file
///             final jsonString = jsonEncode(exportData.toJson());
///             await saveToFile(jsonString, 'my_data_export.json');
///             showSuccess('Data exported successfully!');
///           },
///         );
///       },
///       child: Text('Export My Data'),
///     );
///   }
/// }
/// ```
final dataExportServiceProvider = Provider<DataExportService>((ref) {
  return DataExportService(
    measurementRepo: ref.read(measurementRepositoryProvider),
    consentRepo: ref.read(consentRepositoryProvider),
    auditLogger: ref.read(auditLoggerProvider),
  );
});
