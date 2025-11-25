import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/tabs/exercise_summary_tab.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/tabs/exercise_history_tab.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/tabs/exercise_instructions_tab.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Schermata di dettaglio esercizio con 3 tab: Sommario, Cronologia, Istruzioni
///
/// Accessibile durante il workout per visualizzare:
/// - Sommario: GIF, muscoli, grafico ultimi 3 mesi, record personali, livello di forza
/// - Cronologia: Storico esecuzioni raggruppate per data
/// - Istruzioni: Form cues, warmup protocol, tips
class WorkoutExerciseDetailScreen extends ConsumerStatefulWidget {

  const WorkoutExerciseDetailScreen({
    super.key,
    required this.exerciseName,
  });
  final String exerciseName;

  @override
  ConsumerState<WorkoutExerciseDetailScreen> createState() =>
      _WorkoutExerciseDetailScreenState();
}

class _WorkoutExerciseDetailScreenState
    extends ConsumerState<WorkoutExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Share exercise personal records and stats
  Future<void> _shareExerciseData() async {
    await HapticFeedback.lightImpact();

    // Get exercise history data
    final historyAsync = ref.read(exerciseHistoryDataGroupedProvider(widget.exerciseName));

    await historyAsync.when(
      data: (historyMap) async {
        // Convert map to list of all sets
        final allSets = <ExerciseHistoryData>[];
        historyMap.forEach((date, sets) {
          allSets.addAll(sets);
        });

        if (allSets.isEmpty) {
          // No data to share
          return;
        }

        // Calculate personal records (same logic as ExerciseSummaryTab)
        final records = _calculateRecords(allSets, historyMap);

        // Format share text
        final dateFormatter = DateFormat('dd/MM/yyyy');
        final text = _formatShareText(records, dateFormatter);

        // Share using share_plus
        await Share.share(
          text,
          subject: '🏋️ ${widget.exerciseName} - Personal Records',
        );
      },
      loading: () {
        // Still loading, do nothing
      },
      error: (error, stack) {
        // Error loading data, do nothing
      },
    );
  }

  /// Calculate personal records from exercise history
  _ExerciseRecords _calculateRecords(
    List<ExerciseHistoryData> allSets,
    Map<DateTime, List<ExerciseHistoryData>> historyMap,
  ) {
    // Max Weight
    double maxWeight = 0.0;
    DateTime? maxWeightDate;
    int? maxWeightReps;

    for (final set in allSets) {
      if ((set.weight ?? 0.0) > maxWeight) {
        maxWeight = set.weight!;
        maxWeightDate = set.date;
        maxWeightReps = set.reps;
      }
    }

    // Best 1RM (calculated from weight and reps)
    double best1RM = 0.0;
    DateTime? best1RMDate;
    double? best1RMWeight;
    int? best1RMReps;

    for (final set in allSets) {
      if (set.weight != null && set.reps != null && set.reps! > 0) {
        final calculated1RM = _calculate1RM(set.weight!, set.reps!);
        if (calculated1RM > best1RM) {
          best1RM = calculated1RM;
          best1RMDate = set.date;
          best1RMWeight = set.weight;
          best1RMReps = set.reps;
        }
      }
    }

    // Best Set Volume (weight × reps for single set)
    double bestSetVolume = 0.0;
    DateTime? bestSetVolumeDate;
    double? bestSetVolumeWeight;
    int? bestSetVolumeReps;

    for (final set in allSets) {
      if (set.weight != null && set.reps != null) {
        final volume = set.weight! * set.reps!;
        if (volume > bestSetVolume) {
          bestSetVolume = volume;
          bestSetVolumeDate = set.date;
          bestSetVolumeWeight = set.weight;
          bestSetVolumeReps = set.reps;
        }
      }
    }

    // Total workouts
    final totalWorkouts = historyMap.length;

    return _ExerciseRecords(
      maxWeight: maxWeight,
      maxWeightDate: maxWeightDate,
      maxWeightReps: maxWeightReps,
      best1RM: best1RM,
      best1RMDate: best1RMDate,
      best1RMWeight: best1RMWeight,
      best1RMReps: best1RMReps,
      bestSetVolume: bestSetVolume,
      bestSetVolumeDate: bestSetVolumeDate,
      bestSetVolumeWeight: bestSetVolumeWeight,
      bestSetVolumeReps: bestSetVolumeReps,
      totalWorkouts: totalWorkouts,
    );
  }

  /// Calculate 1RM using Epley formula
  double _calculate1RM(double weight, int reps) {
    if (reps == 1) return weight;
    return weight * (36 / (37 - reps));
  }

  /// Format exercise data as shareable text
  String _formatShareText(_ExerciseRecords records, DateFormat dateFormatter) {
    final buffer = StringBuffer();

    buffer.writeln('🏋️ ${widget.exerciseName}');
    buffer.writeln('');
    buffer.writeln('📊 Personal Records:');
    buffer.writeln('');

    // Max Weight
    buffer.writeln('💪 Max Weight: ${records.maxWeight.toStringAsFixed(1)} kg');
    if (records.maxWeightDate != null) {
      buffer.writeln('   ${records.maxWeightReps} reps • ${dateFormatter.format(records.maxWeightDate!)}');
    }
    buffer.writeln('');

    // Best 1RM
    buffer.writeln('⭐ Best 1RM: ${records.best1RM.toStringAsFixed(1)} kg');
    if (records.best1RMDate != null && records.best1RMWeight != null && records.best1RMReps != null) {
      buffer.writeln('   ${records.best1RMWeight!.toStringAsFixed(1)} kg × ${records.best1RMReps} reps • ${dateFormatter.format(records.best1RMDate!)}');
    }
    buffer.writeln('');

    // Best Set Volume
    buffer.writeln('📈 Best Set Volume: ${records.bestSetVolume.toStringAsFixed(0)} kg');
    if (records.bestSetVolumeDate != null && records.bestSetVolumeWeight != null && records.bestSetVolumeReps != null) {
      buffer.writeln('   ${records.bestSetVolumeWeight!.toStringAsFixed(1)} kg × ${records.bestSetVolumeReps} reps • ${dateFormatter.format(records.bestSetVolumeDate!)}');
    }
    buffer.writeln('');

    // Total workouts
    buffer.writeln('📅 Total Workouts: ${records.totalWorkouts}');
    buffer.writeln('');
    buffer.writeln('Generated by GymBro TrackLog 💪');

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowBack, color: context.colors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.exerciseName,
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(AppIcons.share, color: context.colors.onSurface),
            onPressed: _shareExerciseData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.colors.primary,
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.onSurface.withValues(alpha: 0.6),
          labelStyle: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: context.textTheme.titleSmall,
          tabs: [
            Tab(
              text: context.l10n.exerciseDetailSummary,
              icon: const SemanticIcon(
  icon: AppIcons.analytics,
  semanticLabel: 'Analytics',
),
            ),
            Tab(
              text: context.l10n.exerciseDetailHistory,
              icon: const SemanticIcon(
  icon: AppIcons.history,
  semanticLabel: 'History',
),
            ),
            Tab(
              text: context.l10n.alternativeExercises,
              icon: const SemanticIcon(
  icon: AppIcons.swapHoriz,
  semanticLabel: 'Swap horiz',
),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ExerciseSummaryTab(exerciseName: widget.exerciseName),
          ExerciseHistoryTab(exerciseName: widget.exerciseName),
          ExerciseInstructionsTab(exerciseName: widget.exerciseName),
        ],
      ),
    );
  }
}

/// Data class for exercise personal records
class _ExerciseRecords {
  _ExerciseRecords({
    required this.maxWeight,
    this.maxWeightDate,
    this.maxWeightReps,
    required this.best1RM,
    this.best1RMDate,
    this.best1RMWeight,
    this.best1RMReps,
    required this.bestSetVolume,
    this.bestSetVolumeDate,
    this.bestSetVolumeWeight,
    this.bestSetVolumeReps,
    required this.totalWorkouts,
  });

  final double maxWeight;
  final DateTime? maxWeightDate;
  final int? maxWeightReps;

  final double best1RM;
  final DateTime? best1RMDate;
  final double? best1RMWeight;
  final int? best1RMReps;

  final double bestSetVolume;
  final DateTime? bestSetVolumeDate;
  final double? bestSetVolumeWeight;
  final int? bestSetVolumeReps;

  final int totalWorkouts;
}
