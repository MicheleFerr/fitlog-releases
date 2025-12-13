/// Strong App CSV Parser
///
/// Parses workout data exported from the Strong app.
///
/// **Strong CSV Format** (must be exported in English):
/// ```csv
/// Date,Workout Name,Duration,Exercise Name,Set Order,Weight,Reps,Distance,Seconds,Notes,Workout Notes
/// 2024-01-15 10:30:00,Push Day,45:00,Bench Press,1,80,8,,,Good form,Great workout
/// ```
///
/// **Notes**:
/// - Date format: "YYYY-MM-DD HH:MM:SS"
/// - Duration format: "MM:SS" or "HH:MM:SS"
/// - Weight unit: depends on user's Strong settings (lbs or kg)
/// - Empty fields are allowed
library;

import 'package:csv/csv.dart';
import 'package:gymbro_flutter_new/features/import/domain/entities/import_result.dart';

/// Parser for Strong app CSV export files
class StrongCsvParser {
  /// Expected column headers (Strong exports in English)
  static const List<String> expectedHeaders = [
    'Date',
    'Workout Name',
    'Duration',
    'Exercise Name',
    'Set Order',
    'Weight',
    'Reps',
    'Distance',
    'Seconds',
    'Notes',
    'Workout Notes',
  ];

  /// Parse Strong CSV content into structured data
  ///
  /// Returns [ImportParseResult] with parsed workouts and any warnings.
  ImportParseResult parse(String csvContent) {
    final List<String> warnings = [];

    // Parse CSV
    final List<List<dynamic>> rows = const CsvToListConverter(
      shouldParseNumbers: false, // Keep as strings for controlled parsing
      allowInvalid: true,
    ).convert(csvContent);

    if (rows.isEmpty) {
      return const ImportParseResult(
        sourceApp: 'strong',
        workouts: [],
        unmappedExercises: [],
        autoMappedExercises: {},
        warnings: ['CSV file is empty'],
        totalRows: 0,
        parsedRows: 0,
      );
    }

    // Validate headers
    final headers = rows.first.map((e) => e.toString().trim()).toList();
    final headerValidation = _validateHeaders(headers);
    if (headerValidation != null) {
      warnings.add(headerValidation);
    }

    // Build column index map for flexible parsing
    final columnMap = _buildColumnMap(headers);

    // Parse data rows
    final Map<String, _WorkoutBuilder> workoutBuilders = {};
    final Map<String, int> exerciseOccurrences = {};
    int parsedRows = 0;

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((cell) => cell.toString().trim().isEmpty)) {
        continue; // Skip empty rows
      }

      try {
        final parsedRow = _parseRow(row, columnMap, i);
        if (parsedRow != null) {
          // Group by workout (date + name)
          final workoutKey = '${parsedRow.date.toIso8601String()}_${parsedRow.workoutName}';

          workoutBuilders.putIfAbsent(
            workoutKey,
            () => _WorkoutBuilder(
              name: parsedRow.workoutName,
              date: parsedRow.date,
              durationMinutes: parsedRow.durationMinutes,
              notes: parsedRow.workoutNotes,
            ),
          );

          workoutBuilders[workoutKey]!.addSet(
            exerciseName: parsedRow.exerciseName,
            set: ParsedSet(
              setNumber: parsedRow.setOrder,
              weight: parsedRow.weight,
              reps: parsedRow.reps,
              seconds: parsedRow.seconds,
              distance: parsedRow.distance,
              notes: parsedRow.setNotes,
            ),
          );

          // Track exercise occurrences
          exerciseOccurrences[parsedRow.exerciseName] =
              (exerciseOccurrences[parsedRow.exerciseName] ?? 0) + 1;

          parsedRows++;
        }
      } catch (e) {
        warnings.add('Row $i: $e');
      }
    }

    // Convert builders to ParsedWorkout
    final workouts = workoutBuilders.values
        .map((builder) => builder.build())
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Newest first

    // Create unmapped exercises list (all exercises need mapping initially)
    final unmappedExercises = exerciseOccurrences.entries
        .map((e) => UnmappedExercise(
              originalName: e.key,
              occurrences: e.value,
              suggestions: [], // Will be filled by mapper
            ))
        .toList()
      ..sort((a, b) => b.occurrences.compareTo(a.occurrences)); // Most common first

    return ImportParseResult(
      sourceApp: 'strong',
      workouts: workouts,
      unmappedExercises: unmappedExercises,
      autoMappedExercises: {},
      warnings: warnings,
      totalRows: rows.length - 1, // Exclude header
      parsedRows: parsedRows,
    );
  }

  /// Validate CSV headers match Strong format
  String? _validateHeaders(List<String> headers) {
    // Check for required columns
    final requiredColumns = ['Date', 'Workout Name', 'Exercise Name', 'Weight', 'Reps'];
    final missingColumns = requiredColumns
        .where((col) => !headers.any((h) => h.toLowerCase() == col.toLowerCase()))
        .toList();

    if (missingColumns.isNotEmpty) {
      return 'Missing required columns: ${missingColumns.join(', ')}. '
          'Make sure CSV is exported from Strong in English.';
    }
    return null;
  }

  /// Build flexible column index map
  Map<String, int> _buildColumnMap(List<String> headers) {
    final map = <String, int>{};
    for (var i = 0; i < headers.length; i++) {
      map[headers[i].toLowerCase().trim()] = i;
    }
    return map;
  }

  /// Parse a single CSV row
  _ParsedRow? _parseRow(List<dynamic> row, Map<String, int> columnMap, int rowIndex) {
    String getValue(String column) {
      final index = columnMap[column.toLowerCase()];
      if (index == null || index >= row.length) return '';
      return row[index].toString().trim();
    }

    // Required fields
    final dateStr = getValue('date');
    final workoutName = getValue('workout name');
    final exerciseName = getValue('exercise name');

    if (dateStr.isEmpty || workoutName.isEmpty || exerciseName.isEmpty) {
      return null;
    }

    // Parse date (Strong format: "2024-01-15 10:30:00")
    final date = _parseDate(dateStr);
    if (date == null) {
      throw FormatException('Invalid date format: $dateStr');
    }

    // Parse duration (format: "45:00" or "1:30:00")
    final durationStr = getValue('duration');
    final durationMinutes = _parseDuration(durationStr);

    // Parse numeric fields
    final setOrder = int.tryParse(getValue('set order')) ?? 1;
    final weight = double.tryParse(getValue('weight'));
    final reps = int.tryParse(getValue('reps'));
    final seconds = int.tryParse(getValue('seconds'));
    final distance = double.tryParse(getValue('distance'));

    return _ParsedRow(
      date: date,
      workoutName: workoutName,
      durationMinutes: durationMinutes,
      exerciseName: exerciseName,
      setOrder: setOrder,
      weight: weight,
      reps: reps,
      seconds: seconds,
      distance: distance,
      setNotes: getValue('notes'),
      workoutNotes: getValue('workout notes'),
    );
  }

  /// Parse Strong date format
  DateTime? _parseDate(String dateStr) {
    // Try standard format first: "2024-01-15 10:30:00"
    try {
      return DateTime.parse(dateStr);
    } catch (_) {}

    // Try alternative formats
    final patterns = [
      RegExp(r'(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2}):(\d{2})'),
      RegExp(r'(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2})'),
      RegExp(r'(\d{4})-(\d{2})-(\d{2})'),
      RegExp(r'(\d{2})/(\d{2})/(\d{4})'), // US format
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(dateStr);
      if (match != null) {
        try {
          if (pattern.pattern.contains('/')) {
            // US format: MM/DD/YYYY
            return DateTime(
              int.parse(match.group(3)!),
              int.parse(match.group(1)!),
              int.parse(match.group(2)!),
            );
          } else {
            return DateTime(
              int.parse(match.group(1)!),
              int.parse(match.group(2)!),
              int.parse(match.group(3)!),
              match.groupCount >= 4 ? int.parse(match.group(4)!) : 0,
              match.groupCount >= 5 ? int.parse(match.group(5)!) : 0,
              match.groupCount >= 6 ? int.parse(match.group(6)!) : 0,
            );
          }
        } catch (_) {}
      }
    }

    return null;
  }

  /// Parse duration string to minutes
  int? _parseDuration(String durationStr) {
    if (durationStr.isEmpty) return null;

    final parts = durationStr.split(':').map((p) => int.tryParse(p) ?? 0).toList();

    if (parts.length == 2) {
      // MM:SS
      return parts[0];
    } else if (parts.length == 3) {
      // HH:MM:SS
      return parts[0] * 60 + parts[1];
    }

    return null;
  }
}

/// Internal class for building workouts
class _WorkoutBuilder {
  _WorkoutBuilder({
    required this.name,
    required this.date,
    this.durationMinutes,
    this.notes,
  });

  final String name;
  final DateTime date;
  final int? durationMinutes;
  final String? notes;
  final Map<String, List<ParsedSet>> _exerciseSets = {};

  void addSet({required String exerciseName, required ParsedSet set}) {
    _exerciseSets.putIfAbsent(exerciseName, () => []);
    _exerciseSets[exerciseName]!.add(set);
  }

  ParsedWorkout build() {
    final exercises = _exerciseSets.entries
        .map((e) => ParsedExercise(
              originalName: e.key,
              sets: e.value..sort((a, b) => a.setNumber.compareTo(b.setNumber)),
            ))
        .toList();

    return ParsedWorkout(
      name: name,
      date: date,
      durationMinutes: durationMinutes,
      notes: notes?.isNotEmpty == true ? notes : null,
      exercises: exercises,
    );
  }
}

/// Internal parsed row data
class _ParsedRow {
  _ParsedRow({
    required this.date,
    required this.workoutName,
    this.durationMinutes,
    required this.exerciseName,
    required this.setOrder,
    this.weight,
    this.reps,
    this.seconds,
    this.distance,
    this.setNotes,
    this.workoutNotes,
  });

  final DateTime date;
  final String workoutName;
  final int? durationMinutes;
  final String exerciseName;
  final int setOrder;
  final double? weight;
  final int? reps;
  final int? seconds;
  final double? distance;
  final String? setNotes;
  final String? workoutNotes;
}
