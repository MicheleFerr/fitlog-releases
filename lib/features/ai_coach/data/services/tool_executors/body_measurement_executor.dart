/// Body measurement tool executor for AI Coach
///
/// Handles: getBodyProgress, addBodyMeasurement.
///
/// **Layer**: Data - Service
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:uuid/uuid.dart';

import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/tool_executor_helpers.dart' as h;

class BodyMeasurementExecutor {
  BodyMeasurementExecutor({required this.measurementRepo});

  final MeasurementRepository measurementRepo;
  final Map<String, h.PendingMeasurement> _pendingMeasurements = {};

  Future<String> getBodyProgress(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final metricTypeStr = args['metricType'] as String?;
    final weeksBackRaw = args['weeksBack'];
    final weeksBackParsed = weeksBackRaw is num
        ? weeksBackRaw.toInt()
        : int.tryParse(weeksBackRaw?.toString() ?? '12') ?? 12;
    // Ensure positive value, default to 12 if invalid
    final weeksBack = weeksBackParsed > 0 ? weeksBackParsed : 12;

    try {
      final dateFrom = DateTime.now().subtract(Duration(days: weeksBack * 7));

      // Parse metric type if provided
      MetricType? filterType;
      if (metricTypeStr != null) {
        filterType = _parseMetricType(metricTypeStr);
        if (filterType == null) {
          return jsonEncode({
            'error': 'Tipo di misura non riconosciuto: $metricTypeStr',
            'suggestedTypes': [
              'peso',
              'grasso',
              'vita',
              'petto',
              'bicipite',
              'coscia',
            ],
            'toolName': 'getBodyProgress',
          });
        }
      }

      // Get measurements
      final result = await measurementRepo.getMeasurements(
        userId,
        filterByType: filterType,
        dateFrom: dateFrom,
      );

      return result.fold(
        (failure) => jsonEncode({
          'error': 'Failed to fetch measurements',
          'toolName': 'getBodyProgress',
        }),
        (measurements) {
          if (measurements.isEmpty) {
            return jsonEncode({
              'message': 'Nessuna misurazione trovata nel periodo selezionato',
              'weeksBack': weeksBack,
              'toolName': 'getBodyProgress',
            });
          }

          // Group by metric type
          final byType = <String, List<Map<String, dynamic>>>{};
          for (final m in measurements) {
            final typeName = m.metricType.name;
            byType.putIfAbsent(typeName, () => []);
            byType[typeName]!.add({
              'value': m.value,
              'unit': m.unit,
              'date': m.timestamp.toIso8601String().substring(0, 10),
            });
          }

          // Sort each type by date and calculate progress
          final progress = <String, Map<String, dynamic>>{};
          for (final entry in byType.entries) {
            final sorted = entry.value
              ..sort(
                (a, b) =>
                    (a['date'] as String).compareTo(b['date'] as String),
              );

            final first = sorted.first;
            final last = sorted.last;
            final change =
                (last['value'] as double) - (first['value'] as double);
            final changePercent = first['value'] != 0
                ? (change / (first['value'] as double) * 100)
                : 0.0;

            progress[entry.key] = {
              'firstValue': first['value'],
              'lastValue': last['value'],
              'firstDate': first['date'],
              'lastDate': last['date'],
              'change': change.toStringAsFixed(1),
              'changePercent': changePercent.toStringAsFixed(1),
              'unit': first['unit'],
              'measurementCount': sorted.length,
            };
          }

          return jsonEncode({
            'progress': progress,
            'weeksBack': weeksBack,
            'totalMeasurements': measurements.length,
            'toolName': 'getBodyProgress',
          });
        },
      );
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getBodyProgress',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getBodyProgress',
      });
    }
  }

  Future<String> addBodyMeasurement(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final metricTypeStr = args['metricType'] as String?;
    final valueRaw = args['value'];
    final unitRaw = args['unit'] as String?;
    final notes = args['notes'] as String?;
    final confirmedRaw = args['confirmed'];
    final confirmed =
        confirmedRaw == true ||
        confirmedRaw?.toString().toLowerCase().trim() == 'true';

    try {
      // Step 2: Commit pending measurement only after explicit confirmation
      if (confirmed && metricTypeStr == null && valueRaw == null) {
        final pending = _pendingMeasurements[userId];
        if (pending == null) {
          return jsonEncode({
            'error': 'Nessuna misurazione in attesa di conferma',
            'toolName': 'addBodyMeasurement',
          });
        }

        return _savePendingMeasurement(userId, pending);
      }

      // Handle Italian decimal separator (comma → dot) and parse
      final value = valueRaw is num
          ? valueRaw.toDouble()
          : double.tryParse(valueRaw?.toString().replaceAll(',', '.') ?? '0') ??
                0;

      if (metricTypeStr == null || value == 0) {
        return jsonEncode({
          'error': 'Missing required parameters: metricType and value',
          'toolName': 'addBodyMeasurement',
        });
      }

      // Parse metric type
      final metricType = _parseMetricType(metricTypeStr);
      if (metricType == null) {
        return jsonEncode({
          'error': 'Unknown metric type: $metricTypeStr',
          'supportedTypes': [
            'weight',
            'bodyFatPercentage',
            'leanMass',
            'waistCircumference',
            'chestCircumference',
            'bicepLeftCircumference',
            'bicepRightCircumference',
            'thighLeftCircumference',
            'thighRightCircumference',
          ],
          'toolName': 'addBodyMeasurement',
        });
      }

      // Validate range
      final (minVal, maxVal) = metricType.validRange;
      if (value < minVal || value > maxVal) {
        return jsonEncode({
          'error': 'Value out of range for ${metricType.name}',
          'validRange': {'min': minVal, 'max': maxVal},
          'providedValue': value,
          'toolName': 'addBodyMeasurement',
        });
      }

      final unit = unitRaw ?? metricType.defaultUnit;

      // If model sends confirmed=true with full payload, allow commit only
      // when it exactly matches an already pending measurement.
      if (confirmed) {
        final pending = _pendingMeasurements[userId];
        if (pending != null &&
            pending.metricType == metricType &&
            (pending.value - value).abs() < 0.0001 &&
            pending.unit == unit &&
            (pending.notes ?? '') == (notes ?? '')) {
          return _savePendingMeasurement(userId, pending);
        }
      }

      // Step 1: Prepare pending measurement and ask explicit confirmation
      _pendingMeasurements[userId] = h.PendingMeasurement(
        metricType: metricType,
        value: value,
        unit: unit,
        notes: notes,
      );

      return jsonEncode({
        'confirmationRequired': true,
        'toolName': 'addBodyMeasurement',
        'message':
            'Misurazione pronta ma non ancora salvata. Serve conferma esplicita dell\'utente.',
        'pending': {
          'metricType': metricType.name,
          'value': value,
          'unit': unit,
          'notes': notes,
        },
        'nextAction':
            'Dopo conferma utente, richiama addBodyMeasurement con {"confirmed": true}.',
      });
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: addBodyMeasurement',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'addBodyMeasurement',
      });
    }
  }

  Future<String> _savePendingMeasurement(
    String userId,
    h.PendingMeasurement pending,
  ) async {
    // Get previous measurement for comparison
    final previousResult = await measurementRepo.getLatestMeasurementsByType(
      userId,
    );
    double? previousValue;
    String? previousDate;

    previousResult.fold((_) {}, (latestMap) {
      final prev = latestMap[pending.metricType];
      if (prev != null) {
        previousValue = prev.value;
        previousDate = prev.timestamp.toIso8601String().substring(0, 10);
      }
    });

    final now = DateTime.now();
    final measurement = Measurement(
      id: const Uuid().v4(),
      userId: userId,
      metricType: pending.metricType,
      value: pending.value,
      unit: pending.unit,
      timestamp: now,
      source: MeasurementSource.manual,
      notes: pending.notes,
      createdAt: now,
    );

    final saveResult = await measurementRepo.addMeasurement(
      measurement,
      hasConsent: true,
    );

    return saveResult.fold(
      (failure) => jsonEncode({
        'error': 'Failed to save measurement',
        'toolName': 'addBodyMeasurement',
      }),
      (_) {
        _pendingMeasurements.remove(userId);

        final response = <String, dynamic>{
          'success': true,
          'confirmed': true,
          'saved': {
            'metricType': pending.metricType.name,
            'value': pending.value,
            'unit': pending.unit,
            'date': now.toIso8601String().substring(0, 10),
            'notes': pending.notes,
          },
          'toolName': 'addBodyMeasurement',
        };

        // Add comparison if previous value exists
        if (previousValue != null) {
          final change = pending.value - previousValue!;
          response['comparison'] = {
            'previousValue': previousValue,
            'previousDate': previousDate,
            'change': change.toStringAsFixed(1),
            'direction': change > 0
                ? 'increased'
                : (change < 0 ? 'decreased' : 'unchanged'),
          };
        }

        return jsonEncode(response);
      },
    );
  }

  /// Parse metric type string to MetricType enum
  /// Supports English and Italian names, handles typos and common variations
  MetricType? _parseMetricType(String typeStr) {
    final normalized = typeStr
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .replaceAll('-', '');

    return switch (normalized) {
      // Essential metrics
      'weight' || 'peso' || 'pesokg' => MetricType.weight,
      'bodyfatpercentage' ||
      'bodyfat' ||
      'grasso' ||
      'grassocorporeo' ||
      'percentualegrasso' ||
      'bf' ||
      'bf%' => MetricType.bodyFatPercentage,
      'leanmass' ||
      'massamagra' ||
      'muscolo' ||
      'massamuscolare' => MetricType.leanMass,
      'height' || 'altezza' || 'statura' => MetricType.height,
      'bmi' || 'imc' || 'indicemassacorporea' => MetricType.bmi,
      'bmr' || 'metabolismobasale' => MetricType.bmr,

      // Circumferences - Upper body
      'neckcircumference' ||
      'collo' ||
      'girocollo' => MetricType.neckCircumference,
      'shouldercircumference' ||
      'spalle' ||
      'girospalle' => MetricType.shoulderCircumference,
      'chestcircumference' ||
      'petto' ||
      'torace' ||
      'giropetto' => MetricType.chestCircumference,

      // Circumferences - Core
      'waistcircumference' ||
      'vita' ||
      'girovita' => MetricType.waistCircumference,
      'abdomencircumference' ||
      'addome' ||
      'pancia' ||
      'giroaddome' => MetricType.abdomenCircumference,
      'hipcircumference' ||
      'fianchi' ||
      'girofianchi' ||
      'glutei' => MetricType.hipCircumference,

      // Circumferences - Arms (bilateral)
      'bicepleftcircumference' ||
      'bicipitesinistro' ||
      'braccisinistro' => MetricType.bicepLeftCircumference,
      'biceprightcircumference' ||
      'bicipitedestro' ||
      'bracciodestro' => MetricType.bicepRightCircumference,
      'bicep' ||
      'bicipite' ||
      'braccio' => MetricType.bicepRightCircumference, // Default to right
      'forearmleftcircumference' ||
      'avambracciosinistro' => MetricType.forearmLeftCircumference,
      'forearmrightcircumference' ||
      'avambracciodestro' => MetricType.forearmRightCircumference,
      'forearm' ||
      'avambraccio' => MetricType.forearmRightCircumference, // Default to right
      // Circumferences - Legs (bilateral)
      'thighleftcircumference' ||
      'cosciasinistra' ||
      'gambasinistra' => MetricType.thighLeftCircumference,
      'thighrightcircumference' ||
      'cosciadestra' ||
      'gambadestra' => MetricType.thighRightCircumference,
      'thigh' ||
      'coscia' ||
      'gamba' ||
      'quadricipite' => MetricType.thighRightCircumference, // Default to right
      'calfleftcircumference' ||
      'polpacciosinistro' => MetricType.calfLeftCircumference,
      'calfrightcircumference' ||
      'polpacciodestro' => MetricType.calfRightCircumference,
      'calf' ||
      'polpaccio' => MetricType.calfRightCircumference, // Default to right
      // Vitals
      'bodytemperature' ||
      'temperatura' ||
      'temp' => MetricType.bodyTemperature,
      'watermass' ||
      'acqua' ||
      'idratazione' ||
      'acquacorporea' => MetricType.waterMass,
      'bonemass' || 'massaossea' || 'ossa' => MetricType.boneMass,

      _ => null,
    };
  }
}
