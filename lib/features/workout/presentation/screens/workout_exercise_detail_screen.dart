import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/tabs/exercise_summary_tab.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/tabs/exercise_history_tab.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/tabs/exercise_instructions_tab.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.onSurface),
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
            onPressed: () {
              // TODO: Implementare share esercizio
              HapticFeedback.lightImpact();
            },
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
              icon: Icon(AppIcons.analytics),
            ),
            Tab(
              text: context.l10n.exerciseDetailHistory,
              icon: Icon(AppIcons.history),
            ),
            Tab(
              text: context.l10n.exerciseDetailInstructions,
              icon: const Icon(AppIcons.menuBookOutlined),
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
