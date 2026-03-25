import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_sync_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

/// Local datasource for health sync data using Hive.
///
/// Manages two Hive boxes:
/// 1. `health_sync_status` - Stores [HealthSyncStatus] per data type
/// 2. `body_measurements` - Stores [BodyMeasurement] list
///
/// **IMPORTANT**: [HealthPermissionStatus] is NOT persisted here.
/// Permission status is always checked at runtime to avoid stale state.
abstract class IHealthLocalDatasource {
  // ============================================================
  // SYNC STATUS MANAGEMENT
  // ============================================================

  /// Saves sync status for a specific health data type.
  ///
  /// Overwrites existing status if present.
  /// Key format: `{dataType.name}` (e.g., "workout", "bodyWeight")
  ///
  /// Example:
  /// ```dart
  /// final status = HealthSyncStatus(
  ///   dataType: HealthDataType.workout,
  ///   lastSyncTime: DateTime.now(),
  ///   lastResult: SyncResult.success,
  /// );
  /// await datasource.saveSyncStatus(status);
  /// ```
  Future<void> saveSyncStatus(HealthSyncStatus status);

  /// Gets the last sync status for a specific data type.
  ///
  /// Returns null if never synced.
  ///
  /// Example:
  /// ```dart
  /// final status = await datasource.getSyncStatus(HealthDataType.workout);
  /// if (status?.shouldAutoSync() ?? true) {
  ///   // Trigger sync
  /// }
  /// ```
  Future<HealthSyncStatus?> getSyncStatus(HealthDataType dataType);

  /// Gets sync history for a data type within a date range.
  ///
  /// Returns list of [HealthSyncStatus] entries sorted by [lastSyncTime] desc.
  /// Used for displaying sync timeline in UI.
  ///
  /// Example:
  /// ```dart
  /// final history = await datasource.getSyncHistory(
  ///   dataType: HealthDataType.bodyWeight,
  ///   since: DateTime.now().subtract(Duration(days: 30)),
  /// );
  /// // Display timeline: "Synced 2h ago", "Failed 1 day ago", etc.
  /// ```
  Future<List<HealthSyncStatus>> getSyncHistory({
    required HealthDataType dataType,
    required DateTime since,
  });

  /// Clears all sync status data from Hive.
  ///
  /// Called when:
  /// - User logs out
  /// - User disables health sync
  /// - Testing/debugging
  ///
  /// Does NOT clear measurements (see [clearMeasurements]).
  Future<void> clearSyncStatuses();

  // ============================================================
  // BODY MEASUREMENTS MANAGEMENT
  // ============================================================

  /// Saves a single body measurement to Hive.
  ///
  /// Appends to existing measurements list.
  /// Duplicates are NOT automatically filtered (caller's responsibility).
  ///
  /// Example:
  /// ```dart
  /// final measurement = BodyMeasurement(
  ///   value: 75.5,
  ///   unit: MeasurementUnit.kilograms,
  ///   recordedAt: DateTime.now(),
  ///   dataType: HealthDataType.bodyWeight,
  ///   source: 'HealthKit',
  /// );
  /// await datasource.saveMeasurement(measurement);
  /// ```
  Future<void> saveMeasurement(BodyMeasurement measurement);

  /// Saves multiple measurements in batch (more efficient than saving one-by-one).
  ///
  /// Used during initial sync when importing large datasets from HealthKit.
  ///
  /// Example:
  /// ```dart
  /// final measurements = [/* 100 weight entries from HealthKit */];
  /// await datasource.saveMeasurements(measurements);
  /// ```
  Future<void> saveMeasurements(List<BodyMeasurement> measurements);

  /// Gets measurements filtered by data type and date range.
  ///
  /// Returns list sorted by [recordedAt] descending (newest first).
  ///
  /// Example:
  /// ```dart
  /// final weights = await datasource.getMeasurements(
  ///   dataType: HealthDataType.bodyWeight,
  ///   startDate: DateTime.now().subtract(Duration(days: 30)),
  ///   endDate: DateTime.now(),
  /// );
  /// // Display weight trend chart
  /// ```
  Future<List<BodyMeasurement>> getMeasurements({
    required HealthDataType dataType,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Gets the most recent measurement for a specific data type.
  ///
  /// Returns null if no measurements exist.
  /// Useful for displaying "Last weight: 75.5 kg (2 days ago)".
  ///
  /// Example:
  /// ```dart
  /// final lastWeight = await datasource.getLatestMeasurement(
  ///   HealthDataType.bodyWeight,
  /// );
  /// if (lastWeight != null) {
  ///   print('Current weight: ${lastWeight.value} ${lastWeight.unit.name}');
  /// }
  /// ```
  Future<BodyMeasurement?> getLatestMeasurement(HealthDataType dataType);

  /// Clears all measurements from Hive.
  ///
  /// Called when user logs out or disables health sync.
  /// Does NOT clear sync status (see [clearSyncStatuses]).
  Future<void> clearMeasurements();

  // ============================================================
  // HIVE BOX MANAGEMENT
  // ============================================================

  /// Initializes Hive boxes for health sync.
  ///
  /// Must be called before any other datasource methods.
  /// Typically called in app initialization (main.dart).
  ///
  /// Boxes created:
  /// - `health_sync_status` - `LazyBox<Map>` (JSON storage)
  /// - `body_measurements` - `LazyBox<List<Map>>` (JSON storage)
  ///
  /// Example:
  /// ```dart
  /// await Hive.initFlutter();
  /// final datasource = HealthLocalDatasourceImpl();
  /// await datasource.init();
  /// ```
  Future<void> init();

  /// Closes all Hive boxes (called on app dispose).
  Future<void> dispose();
}

/// Implementation of [IHealthLocalDatasource] using Hive.
///
/// ✅ REFACTORED: Uses [HiveBoxManagerEnhanced] for lazy box opening.
/// No explicit init() call required - boxes are opened on-demand.
class HealthLocalDatasourceImpl implements IHealthLocalDatasource {
  static const String _syncStatusBoxName = 'health_sync_status';
  static const String _measurementsBoxName = 'body_measurements';

  /// Singleton instance of HiveBoxManagerEnhanced for lazy box opening
  final HiveBoxManagerEnhanced _boxManager = HiveBoxManagerEnhanced();

  /// Lazily opens sync status box on-demand (cached by HiveBoxManagerEnhanced)
  Future<Box<Map<dynamic, dynamic>>> _getSyncStatusBox() async {
    return await _boxManager.openBox<Map<dynamic, dynamic>>(_syncStatusBoxName);
  }

  /// Lazily opens measurements box on-demand (cached by HiveBoxManagerEnhanced)
  Future<Box<List<dynamic>>> _getMeasurementsBox() async {
    return await _boxManager.openBox<List<dynamic>>(_measurementsBoxName);
  }

  String _measurementFingerprint(BodyMeasurement measurement) {
    return [
      measurement.dataType.name,
      measurement.unit.name,
      measurement.recordedAt.toIso8601String(),
      measurement.value.toStringAsFixed(4),
      measurement.source ?? '',
    ].join('|');
  }

  @override
  Future<void> init() async {
    // ✅ No-op: Boxes are opened lazily on-demand via HiveBoxManagerEnhanced.
    // This method is kept for backward compatibility with the interface.
  }

  @override
  Future<void> dispose() async {
    // Close boxes if they were opened
    await _boxManager.closeBox(_syncStatusBoxName);
    await _boxManager.closeBox(_measurementsBoxName);
  }

  // ============================================================
  // SYNC STATUS IMPLEMENTATION
  // ============================================================

  @override
  Future<void> saveSyncStatus(HealthSyncStatus status) async {
    final box = await _getSyncStatusBox();

    final key = status.dataType.name;
    final json = status.toJson();

    await box.put(key, json);
  }

  @override
  Future<HealthSyncStatus?> getSyncStatus(HealthDataType dataType) async {
    final box = await _getSyncStatusBox();

    final key = dataType.name;
    final json = box.get(key);

    if (json == null) return null;

    return HealthSyncStatus.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<List<HealthSyncStatus>> getSyncHistory({
    required HealthDataType dataType,
    required DateTime since,
  }) async {
    // Note: For MVP, we store only the latest status per data type.
    // To implement full history, we'd need a different storage strategy
    // (e.g., list of statuses per key, or timestamped keys).
    //
    // For now, return the single latest status if it exists and matches date range.
    final status = await getSyncStatus(dataType);
    if (status == null) return [];

    if (status.lastSyncTime != null && status.lastSyncTime!.isAfter(since)) {
      return [status];
    }

    return [];
  }

  @override
  Future<void> clearSyncStatuses() async {
    final box = await _getSyncStatusBox();
    await box.clear();
  }

  // ============================================================
  // MEASUREMENTS IMPLEMENTATION
  // ============================================================

  @override
  Future<void> saveMeasurement(BodyMeasurement measurement) async {
    final box = await _getMeasurementsBox();

    final key = measurement.dataType.name;
    final existingList = box.get(key) ?? [];
    final existingFingerprints = existingList
        .map(
          (json) => _measurementFingerprint(
            BodyMeasurement.fromJson(Map<String, dynamic>.from(json as Map)),
          ),
        )
        .toSet();
    final fingerprint = _measurementFingerprint(measurement);

    if (existingFingerprints.contains(fingerprint)) {
      return;
    }

    final updatedList = [...existingList, measurement.toJson()];

    await box.put(key, updatedList);
  }

  @override
  Future<void> saveMeasurements(List<BodyMeasurement> measurements) async {
    final box = await _getMeasurementsBox();

    // Group measurements by data type for efficient batch storage
    final groupedByType = <HealthDataType, List<Map<String, dynamic>>>{};

    for (final measurement in measurements) {
      groupedByType.putIfAbsent(measurement.dataType, () => []);
      groupedByType[measurement.dataType]!.add(measurement.toJson());
    }

    // Batch save per data type
    for (final entry in groupedByType.entries) {
      final key = entry.key.name;
      final existingList = box.get(key) ?? [];
      final seenFingerprints = existingList
          .map(
            (json) => _measurementFingerprint(
              BodyMeasurement.fromJson(Map<String, dynamic>.from(json as Map)),
            ),
          )
          .toSet();
      final dedupedIncoming = <Map<String, dynamic>>[];

      for (final json in entry.value) {
        final measurement = BodyMeasurement.fromJson(json);
        final fingerprint = _measurementFingerprint(measurement);
        if (seenFingerprints.add(fingerprint)) {
          dedupedIncoming.add(json);
        }
      }

      final updatedList = [...existingList, ...dedupedIncoming];

      await box.put(key, updatedList);
    }
  }

  @override
  Future<List<BodyMeasurement>> getMeasurements({
    required HealthDataType dataType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final box = await _getMeasurementsBox();

    final key = dataType.name;
    final jsonList = box.get(key) ?? [];

    final measurements = jsonList
        .map(
          (json) =>
              BodyMeasurement.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .where((m) {
          final recorded = m.recordedAt;
          return recorded.isAfter(startDate) && recorded.isBefore(endDate);
        })
        .toList();

    // Sort by recordedAt descending (newest first)
    measurements.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    return measurements;
  }

  @override
  Future<BodyMeasurement?> getLatestMeasurement(HealthDataType dataType) async {
    final box = await _getMeasurementsBox();

    final key = dataType.name;
    final jsonList = box.get(key) ?? [];

    if (jsonList.isEmpty) return null;

    final measurements = jsonList
        .map(
          (json) =>
              BodyMeasurement.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();

    // Sort by recordedAt descending and return first (newest)
    measurements.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    return measurements.first;
  }

  @override
  Future<void> clearMeasurements() async {
    final box = await _getMeasurementsBox();
    await box.clear();
  }
}
