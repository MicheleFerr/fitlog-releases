/// Hevy App CSV Parser
///
/// Parses workout data exported from the Hevy app.
///
/// **Hevy CSV Format**:
/// ```csv
/// "title","start_time","end_time","description","exercise_title","superset_id","exercise_notes","set_index","set_type","weight_lbs","reps","distance_miles","duration_seconds","rpe"
/// "Push Day","28 Mar 2025, 17:29","28 Mar 2025, 18:52","","Bench Press",,""0,"normal",175,8,,,
/// ```
///
/// **Notes**:
/// - Date format: "DD Mon YYYY, HH:MM"
/// - Weight can be weight_lbs or weight_kg depending on user settings
/// - Distance can be distance_miles or distance_km
/// - set_type: "normal", "warmup", "dropset", "failure"
library;

import 'package:csv/csv.dart';
import 'package:gymbro_flutter_new/features/import/domain/entities/import_result.dart';

/// Parser for Hevy app CSV export files
class HevyCsvParser {
  /// Parse Hevy CSV content into structured data
  ImportParseResult parse(String csvContent) {
    final List<String> warnings = [];

    // Parse CSV
    final List<List<dynamic>> rows = const CsvToListConverter(
      shouldParseNumbers: false,
      allowInvalid: true,
    ).convert(csvContent);

    if (rows.isEmpty) {
      return const ImportParseResult(
        sourceApp: 'hevy',
        workouts: [],
        unmappedExercises: [],
        autoMappedExercises: {},
        warnings: ['CSV file is empty'],
        totalRows: 0,
        parsedRows: 0,
      );
    }

    // Build column index map
    final headers = rows.first.map((e) => e.toString().trim()).toList();
    final columnMap = _buildColumnMap(headers);

    // Validate required columns
    final validation = _validateHeaders(columnMap);
    if (validation != null) {
      warnings.add(validation);
    }

    // Detect weight/distance units from headers
    final useKg = columnMap.containsKey('weight_kg');
    final useKm = columnMap.containsKey('distance_km');
    final weightCol = useKg ? 'weight_kg' : 'weight_lbs';
    final distanceCol = useKm ? 'distance_km' : 'distance_miles';

    // Parse data rows
    final Map<String, _WorkoutBuilder> workoutBuilders = {};
    final Map<String, int> exerciseOccurrences = {};
    int parsedRows = 0;

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((cell) => cell.toString().trim().isEmpty)) {
        continue;
      }

      try {
        final parsed = _parseRow(
          row,
          columnMap,
          i,
          weightCol: weightCol,
          distanceCol: distanceCol,
          convertLbsToKg: !useKg,
          convertMilesToKm: !useKm,
        );
        if (parsed == null) continue;

        // Group by workout (start_time + title)
        final workoutKey =
            '${parsed.startTime.toIso8601String()}_${parsed.title}';

        workoutBuilders.putIfAbsent(
          workoutKey,
          () => _WorkoutBuilder(
            name: parsed.title,
            date: parsed.startTime,
            endTime: parsed.endTime,
            notes: parsed.description,
          ),
        );

        workoutBuilders[workoutKey]!.addSet(
          exerciseName: parsed.exerciseTitle,
          set: ParsedSet(
            setNumber: parsed.setIndex + 1, // Hevy uses 0-based index
            weight: parsed.weight,
            reps: parsed.reps,
            seconds: parsed.durationSeconds,
            distance: parsed.distance,
            rpe: parsed.rpe,
            notes: parsed.exerciseNotes,
          ),
        );

        exerciseOccurrences[parsed.exerciseTitle] =
            (exerciseOccurrences[parsed.exerciseTitle] ?? 0) + 1;

        parsedRows++;
      } catch (e) {
        warnings.add('Row $i: $e');
      }
    }

    // Convert builders to ParsedWorkout
    final workouts =
        workoutBuilders.values.map((builder) => builder.build()).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    // Create unmapped exercises list
    final unmappedExercises =
        exerciseOccurrences.entries
            .map(
              (e) => UnmappedExercise(
                originalName: e.key,
                occurrences: e.value,
                suggestions: [],
              ),
            )
            .toList()
          ..sort((a, b) => b.occurrences.compareTo(a.occurrences));

    return ImportParseResult(
      sourceApp: 'hevy',
      workouts: workouts,
      unmappedExercises: unmappedExercises,
      autoMappedExercises: {},
      warnings: warnings,
      totalRows: rows.length - 1,
      parsedRows: parsedRows,
    );
  }

  String? _validateHeaders(Map<String, int> columnMap) {
    final requiredColumns = ['title', 'start_time', 'exercise_title'];
    final missing =
        requiredColumns.where((col) => !columnMap.containsKey(col)).toList();

    if (missing.isNotEmpty) {
      return 'Missing required columns: ${missing.join(', ')}. '
          'Make sure CSV is exported from Hevy.';
    }

    // Check for weight column (either kg or lbs)
    if (!columnMap.containsKey('weight_kg') &&
        !columnMap.containsKey('weight_lbs')) {
      return 'Missing weight column (weight_kg or weight_lbs).';
    }

    return null;
  }

  Map<String, int> _buildColumnMap(List<String> headers) {
    final map = <String, int>{};
    for (var i = 0; i < headers.length; i++) {
      map[headers[i].toLowerCase().trim()] = i;
    }
    return map;
  }

  _ParsedRow? _parseRow(
    List<dynamic> row,
    Map<String, int> columnMap,
    int rowIndex, {
    required String weightCol,
    required String distanceCol,
    required bool convertLbsToKg,
    required bool convertMilesToKm,
  }) {
    String getValue(String column) {
      final index = columnMap[column.toLowerCase()];
      if (index == null || index >= row.length) return '';
      return row[index].toString().trim();
    }

    final title = getValue('title');
    final startTimeStr = getValue('start_time');
    final exerciseTitle = getValue('exercise_title');

    if (title.isEmpty || startTimeStr.isEmpty || exerciseTitle.isEmpty) {
      return null;
    }

    final startTime = _parseHevyDate(startTimeStr);
    if (startTime == null) {
      throw FormatException('Invalid date format: $startTimeStr');
    }

    final endTimeStr = getValue('end_time');
    final endTime =
        endTimeStr.isNotEmpty ? _parseHevyDate(endTimeStr) : null;

    // Parse weight, convert lbs to kg if needed
    var weight = double.tryParse(getValue(weightCol));
    if (weight != null && convertLbsToKg) {
      weight = weight * 0.453592;
    }

    // Parse distance, convert miles to km if needed
    var distance = double.tryParse(getValue(distanceCol));
    if (distance != null && convertMilesToKm) {
      distance = distance * 1.60934;
    }

    return _ParsedRow(
      title: title,
      startTime: startTime,
      endTime: endTime,
      description: getValue('description'),
      exerciseTitle: exerciseTitle,
      setIndex: int.tryParse(getValue('set_index')) ?? 0,
      weight: weight,
      reps: int.tryParse(getValue('reps')),
      durationSeconds: int.tryParse(getValue('duration_seconds')),
      distance: distance,
      rpe: int.tryParse(getValue('rpe')),
      exerciseNotes: getValue('exercise_notes'),
    );
  }

  /// Parse Hevy date format: "28 Mar 2025, 17:29"
  DateTime? _parseHevyDate(String dateStr) {
    // Try standard ISO format first
    try {
      return DateTime.parse(dateStr);
    } catch (_) {}

    // Hevy format: "28 Mar 2025, 17:29"
    final hevyPattern = RegExp(
      r'(\d{1,2})\s+(\w{3})\s+(\d{4}),?\s+(\d{1,2}):(\d{2})',
    );
    final match = hevyPattern.firstMatch(dateStr);
    if (match != null) {
      final day = int.parse(match.group(1)!);
      final monthStr = match.group(2)!.toLowerCase();
      final year = int.parse(match.group(3)!);
      final hour = int.parse(match.group(4)!);
      final minute = int.parse(match.group(5)!);

      final month = _monthMap[monthStr];
      if (month != null) {
        return DateTime(year, month, day, hour, minute);
      }
    }

    return null;
  }

  static const _monthMap = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4,
    'may': 5, 'jun': 6, 'jul': 7, 'aug': 8,
    'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };
}

/// Internal class for building workouts from Hevy data
class _WorkoutBuilder {
  _WorkoutBuilder({
    required this.name,
    required this.date,
    this.endTime,
    this.notes,
  });

  final String name;
  final DateTime date;
  final DateTime? endTime;
  final String? notes;
  final Map<String, List<ParsedSet>> _exerciseSets = {};

  void addSet({required String exerciseName, required ParsedSet set}) {
    _exerciseSets.putIfAbsent(exerciseName, () => []);
    _exerciseSets[exerciseName]!.add(set);
  }

  ParsedWorkout build() {
    final exercises = _exerciseSets.entries
        .map(
          (e) => ParsedExercise(
            originalName: e.key,
            sets: e.value..sort((a, b) => a.setNumber.compareTo(b.setNumber)),
          ),
        )
        .toList();

    // Calculate duration from start/end time
    int? durationMinutes;
    if (endTime != null) {
      durationMinutes = endTime!.difference(date).inMinutes;
    }

    return ParsedWorkout(
      name: name,
      date: date,
      durationMinutes: durationMinutes,
      notes: notes?.isNotEmpty == true ? notes : null,
      exercises: exercises,
    );
  }
}

/// Internal parsed row data for Hevy
class _ParsedRow {
  _ParsedRow({
    required this.title,
    required this.startTime,
    this.endTime,
    this.description,
    required this.exerciseTitle,
    required this.setIndex,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.distance,
    this.rpe,
    this.exerciseNotes,
  });

  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String? description;
  final String exerciseTitle;
  final int setIndex;
  final double? weight;
  final int? reps;
  final int? durationSeconds;
  final double? distance;
  final int? rpe;
  final String? exerciseNotes;
}
