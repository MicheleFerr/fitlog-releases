import 'dart:convert';

import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/user_consent.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/consent_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';

/// GDPR Article 20 - Right to Data Portability
///
/// Exports all user body measurement data in a structured,
/// commonly used, machine-readable JSON format.
///
/// Export includes:
/// - All measurements (value, unit, metric type, timestamp, source)
/// - Consent record (groups, granted dates, version)
/// - Export metadata (timestamp, format version)
///
/// Usage:
/// ```dart
/// final service = MeasurementExportService(
///   measurementRepo: ref.read(measurementRepositoryProvider),
///   consentRepo: ref.read(consentRepositoryProvider),
/// );
/// final result = await service.exportUserMeasurements(userId);
/// result.fold(
///   (failure) => showError(failure.message),
///   (json) => saveToFile(json),
/// );
/// ```
class MeasurementExportService {
  MeasurementExportService({
    required MeasurementRepository measurementRepo,
    required ConsentRepository consentRepo,
  })  : _measurementRepo = measurementRepo,
        _consentRepo = consentRepo;

  final MeasurementRepository _measurementRepo;
  final ConsentRepository _consentRepo;

  /// Current export format version
  static const int exportFormatVersion = 1;

  /// Export all user measurements as structured JSON string
  ///
  /// Returns a GDPR-compliant data export containing:
  /// - All measurements the user has consented to
  /// - Consent state per metric group
  /// - Export metadata (timestamp, format version, app info)
  ///
  /// [userId] - Firebase Auth UID of the user requesting export
  ///
  /// Returns:
  /// - Right(String): JSON string of exported data
  /// - Left(ExportFailure): Error during export
  Future<Either<ExportFailure, String>> exportUserMeasurements(
    String userId,
  ) async {
    // 1. Fetch all measurements
    final measurementsResult = await _measurementRepo.getMeasurements(userId);
    if (measurementsResult.isLeft()) {
      return left(const ExportFailure(
        message: 'Failed to fetch measurements for export',
      ));
    }

    final measurements = measurementsResult.getOrElse((_) => []);

    // 2. Fetch consent record
    final consentResult = await _consentRepo.getConsent(userId);
    UserConsent? consent;
    if (consentResult.isRight()) {
      consent = consentResult.getOrElse((_) => throw StateError('unreachable'));
    }

    // 3. Build export structure
    final exportData = _buildExportData(
      userId: userId,
      measurements: measurements,
      consent: consent,
    );

    // 4. Encode as JSON
    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    return right(jsonString);
  }

  /// Export measurements as a structured Map (for programmatic use)
  Future<Either<ExportFailure, Map<String, dynamic>>>
      exportUserMeasurementsAsMap(String userId) async {
    final measurementsResult = await _measurementRepo.getMeasurements(userId);
    if (measurementsResult.isLeft()) {
      return left(const ExportFailure(
        message: 'Failed to fetch measurements for export',
      ));
    }

    final measurements = measurementsResult.getOrElse((_) => []);

    final consentResult = await _consentRepo.getConsent(userId);
    UserConsent? consent;
    if (consentResult.isRight()) {
      consent = consentResult.getOrElse((_) => throw StateError('unreachable'));
    }

    return right(_buildExportData(
      userId: userId,
      measurements: measurements,
      consent: consent,
    ));
  }

  Map<String, dynamic> _buildExportData({
    required String userId,
    required List<Measurement> measurements,
    UserConsent? consent,
  }) {
    return {
      'exportMetadata': {
        'formatVersion': exportFormatVersion,
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'userId': userId,
        'totalMeasurements': measurements.length,
        'gdprArticle': 'Article 20 - Right to Data Portability',
      },
      'consent': consent != null
          ? {
              'consentVersion': consent.consentVersion,
              'acceptedAt': consent.acceptedAt.toUtc().toIso8601String(),
              'groups': consent.groupConsents.map(
                (group, state) => MapEntry(group.name, state.name),
              ),
              'essentialGrantedAt':
                  consent.essentialGrantedAt?.toUtc().toIso8601String(),
              'measurementsGrantedAt':
                  consent.measurementsGrantedAt?.toUtc().toIso8601String(),
              'vitalsGrantedAt':
                  consent.vitalsGrantedAt?.toUtc().toIso8601String(),
              'isRevoked': consent.isRevoked,
              'revokedAt': consent.revokedAt?.toUtc().toIso8601String(),
            }
          : null,
      'measurements': measurements.map(_measurementToExportJson).toList(),
    };
  }

  Map<String, dynamic> _measurementToExportJson(Measurement m) {
    return {
      'id': m.id,
      'metricType': m.metricType.name,
      'value': m.value,
      'unit': m.unit,
      'timestamp': m.timestamp.toUtc().toIso8601String(),
      'source': m.source.name,
      'notes': m.notes,
      'createdAt': m.createdAt?.toUtc().toIso8601String(),
      'updatedAt': m.updatedAt?.toUtc().toIso8601String(),
    };
  }
}

/// Failure type for export operations
class ExportFailure {
  const ExportFailure({required this.message, this.error});

  final String message;
  final Object? error;
}
