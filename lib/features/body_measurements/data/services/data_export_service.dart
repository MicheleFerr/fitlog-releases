import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_impl.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/services/audit_logger_service.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/user_consent.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';

/// DataExportService - GDPR Article 20 compliance (Right to Data Portability)
///
/// **GDPR CRITICAL**: Enables users to export their personal data in machine-readable format.
///
/// **Functionality**:
/// - Exports all user data to JSON format (measurements, consent, audit logs)
/// - Respects consent boundaries (only exports data user has consented to)
/// - Includes metadata (export timestamp, format version, data types)
/// - Supports selective export (choose specific metric types)
/// - Generates human-readable summary for user verification
///
/// **GDPR Article 20 Requirements**:
/// 1. Data must be in "structured, commonly used, machine-readable format" → JSON ✅
/// 2. User can transmit data to another controller → JSON is portable ✅
/// 3. Only applies to data "provided by the data subject" → Measurements ✅
/// 4. Does not apply to "data derived from analysis" → Excluded ✅
///
/// **Export Format**:
/// ```json
/// {
///   "formatVersion": "1.0",
///   "exportedAt": "2025-01-15T14:30:00.000Z",
///   "userId": "user-123",
///   "dataTypes": ["measurements", "consent", "auditLogs"],
///   "summary": {
///     "totalMeasurements": 150,
///     "metricTypes": ["weight", "bodyFatPercentage", ...],
///     "dateRange": {
///       "from": "2024-01-01T00:00:00.000Z",
///       "to": "2025-01-15T14:30:00.000Z"
///     }
///   },
///   "measurements": [...],
///   "consent": {...},
///   "auditLogs": [...]
/// }
/// ```
///
/// **Usage**:
/// ```dart
/// final exportService = DataExportService(...);
///
/// // Export all data
/// final result = await exportService.exportUserData(
///   userId: currentUser.uid,
/// );
///
/// result.fold(
///   (failure) => showError(failure.message),
///   (exportData) {
///     // Save to file or display to user
///     final jsonString = jsonEncode(exportData.toJson());
///     await saveToFile(jsonString, 'my_data_export.json');
///   },
/// );
///
/// // Export specific metrics only
/// final selectiveResult = await exportService.exportUserData(
///   userId: currentUser.uid,
///   includeMetricTypes: [MetricType.weight, MetricType.bodyFatPercentage],
/// );
/// ```
///
/// **Error Handling**:
/// - Returns Either&lt;DataExportFailure, UserDataExport&gt;
/// - Logs export action to audit trail (GDPR compliance)
/// - Validates consent before exporting sensitive data
class DataExportService {
  final MeasurementRepository _measurementRepo;
  final ConsentRepositoryImpl _consentRepo;
  final AuditLoggerService _auditLogger;

  DataExportService({
    required MeasurementRepository measurementRepo,
    required ConsentRepositoryImpl consentRepo,
    required AuditLoggerService auditLogger,
  })  : _measurementRepo = measurementRepo,
        _consentRepo = consentRepo,
        _auditLogger = auditLogger;

  /// Export all user data in JSON format
  ///
  /// **GDPR CRITICAL**: Article 20 - Right to Data Portability
  ///
  /// Parameters:
  /// - [userId]: User ID
  /// - [includeMetricTypes]: Optional list of metric types to export (default: all consented metrics)
  /// - [includeMeasurements]: Include measurements (default: true)
  /// - [includeConsent]: Include consent records (default: true)
  /// - [includeAuditLogs]: Include audit logs (default: true)
  ///
  /// Returns:
  /// - Right(UserDataExport): Export successful, contains all user data
  /// - Left(DataExportFailure): Export failed (storage error, consent validation failed)
  ///
  /// Example:
  /// ```dart
  /// // Export all data
  /// final result = await exportService.exportUserData(
  ///   userId: 'user-123',
  /// );
  ///
  /// // Export only weight measurements
  /// final selectiveResult = await exportService.exportUserData(
  ///   userId: 'user-123',
  ///   includeMetricTypes: [MetricType.weight],
  ///   includeConsent: false,
  ///   includeAuditLogs: false,
  /// );
  /// ```
  Future<Either<DataExportFailure, UserDataExport>> exportUserData({
    required String userId,
    List<MetricType>? includeMetricTypes,
    bool includeMeasurements = true,
    bool includeConsent = true,
    bool includeAuditLogs = true,
  }) async {
    try {
      // 1. Get user consent
      final consentResult = await _consentRepo.getConsent(userId);
      if (consentResult.isLeft()) {
        return left(DataExportFailure(
          message: 'Failed to retrieve user consent',
          error: consentResult.fold((failure) => failure, (_) => null),
        ));
      }

      final userConsent = consentResult.fold(
        (_) => throw Exception('Unreachable: checked isLeft() above'),
        (consent) => consent,
      );

      // 2. Determine which metrics to export
      final metricsToExport = includeMetricTypes ?? userConsent.consentedMetrics;

      // 3. Validate that user has consented to requested metrics
      for (final metricType in metricsToExport) {
        if (!userConsent.consentedMetrics.contains(metricType)) {
          return left(DataExportFailure(
            message:
                'Cannot export metric "$metricType" - user has not consented to this metric',
          ));
        }
      }

      // 4. Build data types list
      final dataTypes = <String>[];
      if (includeMeasurements) dataTypes.add('measurements');
      if (includeConsent) dataTypes.add('consent');
      if (includeAuditLogs) dataTypes.add('auditLogs');

      // 5. Export measurements
      List<Measurement>? measurements;
      if (includeMeasurements) {
        final measurementsResult =
            await _exportMeasurements(userId, metricsToExport);
        if (measurementsResult.isLeft()) {
          return left(
            measurementsResult.fold(
              (failure) => failure,
              (_) =>
                  throw Exception('Unreachable: isLeft() but fold got Right'),
            ),
          );
        }

        measurements = measurementsResult.fold(
          (_) => throw Exception('Unreachable: checked isLeft() above'),
          (measurements) => measurements,
        );
      }

      // 6. Export consent record
      UserConsent? consentRecord;
      if (includeConsent) {
        consentRecord = userConsent;
      }

      // 7. Export audit logs
      List<AuditLog>? auditLogs;
      if (includeAuditLogs) {
        final auditLogsResult = await _exportAuditLogs(userId);
        if (auditLogsResult.isLeft()) {
          return left(
            auditLogsResult.fold(
              (failure) => failure,
              (_) =>
                  throw Exception('Unreachable: isLeft() but fold got Right'),
            ),
          );
        }

        auditLogs = auditLogsResult.fold(
          (_) => throw Exception('Unreachable: checked isLeft() above'),
          (logs) => logs,
        );
      }

      // 8. Build summary
      final summary = _buildSummary(
        measurements: measurements ?? [],
        auditLogs: auditLogs ?? [],
        metricsToExport: metricsToExport,
      );

      // 9. Create export object
      final exportData = UserDataExport(
        formatVersion: '1.0',
        exportedAt: DateTime.now().toUtc(),
        userId: userId,
        dataTypes: dataTypes,
        summary: summary,
        measurements: measurements,
        consent: consentRecord,
        auditLogs: auditLogs,
      );

      // 10. Log export action to audit trail (GDPR compliance)
      await _auditLogger.logAction(
        userId: userId,
        action: AuditAction.dataExport,
        affectedMetrics: metricsToExport,
        actionDetails:
            'Exported ${summary['totalMeasurements']} measurements to JSON (format v${exportData.formatVersion})',
      );

      return right(exportData);
    } catch (e) {
      return left(DataExportFailure(
        message: 'Failed to export user data: $e',
        error: e,
      ));
    }
  }

  /// Export measurements for specific metric types
  Future<Either<DataExportFailure, List<Measurement>>> _exportMeasurements(
    String userId,
    List<MetricType> metricTypes,
  ) async {
    try {
      final allMeasurements = <Measurement>[];

      for (final metricType in metricTypes) {
        final result = await _measurementRepo.getMeasurements(
          userId,
          filterByType: metricType,
        );

        if (result.isLeft()) {
          return left(DataExportFailure(
            message: 'Failed to export measurements for metric type $metricType',
            error: result.fold((failure) => failure, (_) => null),
          ));
        }

        final measurements = result.fold(
          (_) => throw Exception('Unreachable: checked isLeft() above'),
          (measurements) => measurements,
        );

        allMeasurements.addAll(measurements);
      }

      // Sort by timestamp (oldest first)
      allMeasurements.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return right(allMeasurements);
    } catch (e) {
      return left(DataExportFailure(
        message: 'Failed to export measurements: $e',
        error: e,
      ));
    }
  }

  /// Export audit logs
  Future<Either<DataExportFailure, List<AuditLog>>> _exportAuditLogs(
    String userId,
  ) async {
    try {
      final result = await _auditLogger.getAuditLogs(
        userId: userId,
        dateFrom: DateTime(2020), // From beginning of time
        dateTo: DateTime.now(),
      );

      if (result.isLeft()) {
        return left(DataExportFailure(
          message: 'Failed to export audit logs',
          error: result.fold((failure) => failure, (_) => null),
        ));
      }

      final auditLogs = result.fold(
        (_) => throw Exception('Unreachable: checked isLeft() above'),
        (logs) => logs,
      );

      return right(auditLogs);
    } catch (e) {
      return left(DataExportFailure(
        message: 'Failed to export audit logs: $e',
        error: e,
      ));
    }
  }

  /// Build human-readable summary
  Map<String, dynamic> _buildSummary({
    required List<Measurement> measurements,
    required List<AuditLog> auditLogs,
    required List<MetricType> metricsToExport,
  }) {
    // Find date range
    DateTime? earliestDate;
    DateTime? latestDate;

    if (measurements.isNotEmpty) {
      earliestDate = measurements.first.timestamp;
      latestDate = measurements.last.timestamp;
    }

    return {
      'totalMeasurements': measurements.length,
      'totalAuditLogs': auditLogs.length,
      'metricTypes': metricsToExport.map((m) => m.name).toList(),
      'dateRange': {
        'from': earliestDate?.toIso8601String(),
        'to': latestDate?.toIso8601String(),
      },
    };
  }
}

/// UserDataExport - Complete export of user's personal data
class UserDataExport {
  final String formatVersion;
  final DateTime exportedAt;
  final String userId;
  final List<String> dataTypes;
  final Map<String, dynamic> summary;
  final List<Measurement>? measurements;
  final UserConsent? consent;
  final List<AuditLog>? auditLogs;

  UserDataExport({
    required this.formatVersion,
    required this.exportedAt,
    required this.userId,
    required this.dataTypes,
    required this.summary,
    this.measurements,
    this.consent,
    this.auditLogs,
  });

  Map<String, dynamic> toJson() {
    return {
      'formatVersion': formatVersion,
      'exportedAt': exportedAt.toIso8601String(),
      'userId': userId,
      'dataTypes': dataTypes,
      'summary': summary,
      if (measurements != null)
        'measurements': measurements!.map((m) => m.toJson()).toList(),
      if (consent != null) 'consent': consent!.toJson(),
      if (auditLogs != null)
        'auditLogs': auditLogs!.map((l) => l.toJson()).toList(),
    };
  }

  factory UserDataExport.fromJson(Map<String, dynamic> json) {
    return UserDataExport(
      formatVersion: json['formatVersion'] as String,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      userId: json['userId'] as String,
      dataTypes: (json['dataTypes'] as List<dynamic>).cast<String>(),
      summary: json['summary'] as Map<String, dynamic>,
      measurements: json['measurements'] != null
          ? (json['measurements'] as List<dynamic>)
              .map((m) => Measurement.fromJson(m as Map<String, dynamic>))
              .toList()
          : null,
      consent: json['consent'] != null
          ? UserConsent.fromJson(json['consent'] as Map<String, dynamic>)
          : null,
      auditLogs: json['auditLogs'] != null
          ? (json['auditLogs'] as List<dynamic>)
              .map((l) => AuditLog.fromJson(l as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

/// DataExportFailure - Data export error
class DataExportFailure {
  final String message;
  final Object? error;

  const DataExportFailure({
    required this.message,
    this.error,
  });

  @override
  String toString() => 'DataExportFailure(message: $message, error: $error)';
}
