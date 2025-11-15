import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Simplified exercise representation for progression analysis
///
/// Extracts key data (name, sets, date) from completed workouts
/// Used by AnalyzeProgression to detect patterns and suggest improvements
class ExerciseLog {
  const ExerciseLog({
    required this.name,
    required this.sets,
    required this.date,
  });

  final String name;
  final List<ExerciseSet> sets;
  final DateTime date;
}
