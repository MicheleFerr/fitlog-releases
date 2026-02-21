import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/tabs/exercise_summary_tab.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/tabs/exercise_history_tab.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/tabs/exercise_alternatives_tab.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/features/workout/services/pdf_exercise_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';

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
    this.exerciseId,
  });
  final String exerciseName;

  /// Optional exercise database ID for strength standards lookup.
  /// If provided, enables accurate mapping to strength standards.
  final String? exerciseId;

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

  /// Share exercise personal records and stats as PDF
  Future<void> _shareExerciseData() async {
    await HapticFeedback.lightImpact();

    // Get exercise history data
    final historyAsync = ref.read(
      exerciseHistoryDataGroupedProvider(widget.exerciseName),
    );

    await historyAsync.when(
      data: (historyMap) async {
        // Convert map to list of all sets
        final allSets = <ExerciseHistoryData>[];
        historyMap.forEach((date, sets) {
          allSets.addAll(sets);
        });

        if (allSets.isEmpty) {
          // No data to share
          if (mounted) {
            SnackBarService.showWarning(context, context.l10n.noDataToShare);
          }
          return;
        }

        // Calculate personal records
        final records = _calculateRecords(allSets, historyMap);

        // Create PDF data
        final pdfData = ExerciseRecordsData(
          exerciseName: widget.exerciseName,
          maxWeight: records.maxWeight,
          maxWeightDate: records.maxWeightDate,
          maxWeightReps: records.maxWeightReps,
          best1RM: records.best1RM,
          best1RMDate: records.best1RMDate,
          best1RMWeight: records.best1RMWeight,
          best1RMReps: records.best1RMReps,
          bestSetVolume: records.bestSetVolume,
          bestSetVolumeDate: records.bestSetVolumeDate,
          bestSetVolumeWeight: records.bestSetVolumeWeight,
          bestSetVolumeReps: records.bestSetVolumeReps,
          totalWorkouts: records.totalWorkouts,
          historyData: historyMap,
        );

        // Share as PDF
        try {
          await PdfExerciseService.shareExercisePdf(pdfData);
        } catch (e) {
          if (mounted) {
            SnackBarService.showError(context, context.l10n.errorSharingPdf);
          }
        }
      },
      loading: () {
        if (mounted) {
          SnackBarService.showInfo(context, context.l10n.dataStillLoading);
        }
      },
      error: (error, stack) {
        // Error loading data
        if (mounted) {
          SnackBarService.showError(context, context.l10n.errorLoadingData);
        }
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
        final calculated1RM = OneRMCalculator.calculateBrzycki(
          set.weight!,
          set.reps!,
        );
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
          ExerciseSummaryTab(
            exerciseName: widget.exerciseName,
            exerciseId: widget.exerciseId,
          ),
          ExerciseHistoryTab(exerciseName: widget.exerciseName),
          ExerciseAlternativesTab(exerciseName: widget.exerciseName),
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
